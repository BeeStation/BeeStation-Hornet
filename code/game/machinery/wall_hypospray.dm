
///Which chemicals to use? Synthesized medicines or inserted bottle?
#define PLUMBING "plumbing"
#define STORAGE  "storage"
#define BOTTLE   "handle"

///What caused the handle to snap back?
#define SNAP_DROP       0
#define SNAP_OVEREXTEND 1
#define SNAP_INTERACT   2

/datum/component/plumbing/wallmount_hypospray
	demand_connects = SOUTH

//Code based on defibrillator, sleeper and chemical synthesizer
/obj/machinery/wall/hypospray
	name = "wall-mounted hypospray"
	desc = "A wall-mounted machine capable of synthesizing common medicines, with a handle for easy application."
	icon = 'icons/obj/machines/wallmount_hypospray.dmi'
	icon_state = "wallmount_hypospray"
	circuit = /obj/item/circuitboard/machine/wall/hypospray
	req_access = list(ACCESS_MEDICAL)

	pixel_shift = 32 // Centered on the tile so it looks right without rotation and with plumbing

	var/obj/item/hypospray_handle/handle
	var/in_use = FALSE
	var/locked = TRUE

	var/chem_source = STORAGE

	var/obj/item/storage/bag/chemistry/chemistry_bag = null
	var/datum/weakref/selected_storage = null

	var/atom/movable/plumbing_handler
	var/datum/component/plumbing/plumbing_component

	var/last_plumbing_volume // Used to only update UI when amount changes

/obj/machinery/wall/hypospray/examine(mob/user)
	. = ..()

	. += "<span class='notice'>It is set to draw from the [chem_source].</span>"

	if(chemistry_bag)
		. += "<span class='notice'>It has [chemistry_bag] attached.</span>"

/obj/machinery/wall/hypospray/Initialize()
	. = ..()

	if(. == INITIALIZE_HINT_NORMAL)
		. = INITIALIZE_HINT_LATELOAD

/obj/machinery/wall/hypospray/LateInitialize()
	. = ..()

	handle = new(src)
	layer++ // Need to bump up a layer so ducts can show up on top of wall but under hypospray

	plumbing_handler = new(get_step(src, turn(dir, 180))) //TODO: Relay some plumbing actions to plumbing_handler
	plumbing_handler.setDir(dir)
	plumbing_handler.invisibility = INVISIBILITY_ABSTRACT
	plumbing_handler.anchored = TRUE
	plumbing_handler.layer++
	plumbing_handler.create_reagents(30, TRANSPARENT)
	plumbing_component = plumbing_handler.AddComponent(/datum/component/plumbing/wallmount_hypospray, TRUE)

	reagents = plumbing_handler.reagents
	update_icon()

/obj/machinery/wall/hypospray/Destroy()
	QDEL_NULL(handle)
	QDEL_NULL(plumbing_handler)
	plumbing_component = null // Redundant reference for convenience
	reagents = null // Shared with plumbing_handler
	. = ..()

/obj/machinery/wall/hypospray/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()

	if(!.)
		if(reagents && reagents.total_volume != last_plumbing_volume)
			last_plumbing_volume = reagents.total_volume
			. = TRUE

/obj/machinery/wall/hypospray/on_deconstruction()
	. = ..()

	if(chemistry_bag)
		chemistry_bag.forceMove(loc)
		chemistry_bag = null

/obj/machinery/wall/hypospray/screwdriver_act(mob/living/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return TRUE

	. = ..()

/obj/machinery/wall/hypospray/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

	. = ..()

/obj/machinery/wall/hypospray/update_overlays()
	. = ..()

	if(plumbing_handler)
		. += plumbing_handler

	if(is_operational() && !panel_open)
		if(locked)
			. += "screen-yellow"
		else
			. += "screen-green"

	if(!in_use)
		. += "[initial(icon_state)]-handle"

	if(chemistry_bag)
		. += "[initial(icon_state)]-bag"

/obj/machinery/wall/hypospray/power_change()
	. = ..()
	update_icon()

/obj/machinery/wall/hypospray/proc/snap_handle(cause = SNAP_DROP, silent = FALSE)
	if(!handle)
		return
	if(ismob(handle.loc))
		var/mob/M = handle.loc
		M.transferItemToLoc(handle, src)
		if(!silent)
			switch(cause)
				if(SNAP_DROP)
					to_chat(M, "<span class='notice'>The handle snaps back into the main unit.</span>")
				if(SNAP_OVEREXTEND)
					to_chat(M, "<span class='warning'>[src]'s handle overextends and comes out of your hand!</span>")
				if(SNAP_INTERACT)
					to_chat(M, "<span class='notice'>You put back [handle] into [src]</span>")
	else
		if(!silent)
			visible_message("<span class='notice'>[handle] snaps back into [src].</span>")
		handle.forceMove(src)
	in_use = FALSE
	update_icon()
	ui_update()

/obj/machinery/wall/hypospray/proc/get_reagents_source()
	switch(chem_source)
		if(STORAGE)
			if(!selected_storage)
				return null
			var/obj/item/reagent_containers/selected_item = selected_storage.resolve()
			if(!selected_item || !(selected_item in chemistry_bag.contents) || !(selected_item.reagent_flags & DRAINABLE))
				selected_storage = null
				return null
			return selected_item.reagents
		if(BOTTLE)
			if(handle && handle.storage)
				return handle.storage.reagents
		if(PLUMBING)
			if(plumbing_handler)
				return plumbing_handler.reagents

/obj/machinery/wall/hypospray/proc/inject(mob/living/target, mob/user, amount)

	//Always log attemped injects for admins
	var/list/injected = list()

	var/datum/reagents/source = get_reagents_source()
	if(!source)
		balloon_alert(user, "Nothing to draw from!")
		return

	if(!source.total_volume)
		balloon_alert(user, "It's empty!")
		return

	for(var/datum/reagent/R in source.reagent_list)
		injected += R.name

	var/contained = english_list(injected)
	log_combat(user, target, "attempted to inject", handle, "([contained])")

	if(target.can_inject(user, 1))
		to_chat(target, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [target] with [handle].</span>")
		playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

		var/fraction = min(amount/source.total_volume, 1)
		source.reaction(target, INJECT, fraction)
		source.trans_to(target, amount, transfered_by = user)

		balloon_alert(user, "[source.total_volume]U\s remaining")
		ui_update()

		log_combat(user, target, "injected", handle, "([contained])")

/obj/machinery/wall/hypospray/proc/interact_handle(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>[src] is locked!</span>")
		return FALSE

	if(in_use)
		if(handle.loc == user)
			snap_handle(cause=SNAP_INTERACT)
			. = TRUE
		else
			to_chat(user, "<span class='warning'>Somebody's currently using the handle!</span>")
	else if(user.put_in_hands(handle))
		in_use = TRUE
		. = TRUE

	if(.)
		update_icon()

/obj/machinery/wall/hypospray/proc/interact_bag(mob/user, obj/item/storage/bag/chemistry/new_bag = null)
	if(new_bag && chemistry_bag)
		to_chat(user, "<span class='warning'>[src] already has \a [chemistry_bag]!</span>")
		return FALSE

	if(locked)
		if(chemistry_bag)
			to_chat(user, "<span class='warning'>[src] is locked, its clamps holding [chemistry_bag]'s strap tight!</span>")
		else if(new_bag)
			to_chat(user, "<span class='warning'>[src] is locked, it won't accept [new_bag]!</span>")
		return FALSE

	if(chemistry_bag)
		chemistry_bag.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(chemistry_bag)
		user.visible_message("<span class='notice'>[user] unhooks [src]'s bag.</span>", \
		                     "<span class='notice'>You unhook [chemistry_bag] from [src].</span>")
		chemistry_bag = null
		update_icon()
		return TRUE
	if(new_bag)
		if(!user.transferItemToLoc(new_bag, src))
			//to_chat(user, "<span class='warning'>You can't attach [chemistry_bag] to [src]</span>")
			return FALSE

		user.visible_message("<span class='notice'>[user] hooks a bag onto [src].</span>", \
		                     "<span class='notice'>You hook [new_bag] onto [src].</span>")

		chemistry_bag = new_bag
		update_icon()
		return TRUE

/obj/machinery/wall/hypospray/proc/toggle_lock(mob/living/user, obj/item/held_item = null)
	if(stat & (BROKEN|MAINT))
		to_chat(user, "<span class='warning'>[src] doesn't respond!</span>")
	else if(in_use)
		to_chat(user, "<span class='warning'>You must put back [handle] before you can lock [src]!</span>")
	else
		if(GLOB.security_level >= SEC_LEVEL_RED || (held_item?.GetID() ? check_access(held_item) : allowed(usr)))
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] [src].</span>")
			update_icon()
			return TRUE
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/wall/hypospray/CtrlClick(mob/user)
	if(!user.canUseTopic(src, TRUE, FALSE, TRUE) || !isturf(loc))
		return

	if(interact_handle(user))
		ui_update() //Handle button
		return TRUE

	return ..()

/obj/machinery/wall/hypospray/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user), TRUE, TRUE) || !isturf(loc))
		return
	
	if(toggle_lock(user))
		ui_update() //Interface lock
		return TRUE

	return ..()

/obj/machinery/wall/hypospray/attackby(obj/item/I, mob/living/user, params)
	if(I == handle)
		snap_handle(cause=SNAP_INTERACT)
		ui_update() //Handle button
		return TRUE

	//TODO: Swiping ID card directly

	if(istype(I, /obj/item/hypospray_handle))
		to_chat(user, "<span class='warning'>The [I] belongs to another wallmount!</span>")
		return FALSE

	if(istype(I, /obj/item/storage/bag/chemistry))
		var/obj/item/storage/bag/chemistry/bag = I

		if(interact_bag(user, bag))
			ui_update() //Available chems
			return TRUE

	if(istype(I, /obj/item/plunger))
		return plumbing_handler.attackby(I, user, params)

	return ..()

/obj/machinery/wall/hypospray/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WallHypospray")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/wall/hypospray/ui_data(mob/user)
	. = ..()
	var/list/data = .

	if(chemistry_bag)
		data["bag"] = "[chemistry_bag.name]"
		data["bag_contents"] = list()
		for(var/obj/item/reagent_containers/item in chemistry_bag.contents)
			if(item.reagent_flags & DRAINABLE)
				data["bag_contents"] += list(list(
						name = item.name,
						id = REF(item),
						volume = item.reagents.total_volume,
						max_volume = item.volume
					))
		var/obj/item/reagent_containers/selected_item = selected_storage?.resolve()
		if(selected_item)
			data["selected"] = REF(selected_item)
			data["selected_data"] = list(
				name = "[selected_item]",
				volume = selected_item.reagents.total_volume,
				max_volume = selected_item.volume)

	if(handle && handle.storage)
		data["bottle"] = "[handle.storage.name]"
		data["bottle_data"] = list(
			volume = handle.storage.reagents.total_volume,
			max_volume = handle.storage.volume)

	if(plumbing_handler)
		data["plumbing_data"] = list(
			volume = plumbing_handler.reagents.total_volume,
			max_volume = plumbing_handler.reagents.maximum_volume)

	data["chem_source"] = chem_source
	data["locked"] = locked
	data["handle"] = in_use ? null : handle?.name

/obj/machinery/wall/hypospray/ui_act(action, list/params)
	if(..())
		return
	
	switch(action)
		if("toggle_locked")
			. = toggle_lock(usr)

	if(!locked)
		switch(action)
			if("select_source")
				switch(params["target"])
					if(PLUMBING)
						chem_source = PLUMBING
					if(STORAGE)
						chem_source = STORAGE
					if(BOTTLE)
						chem_source = BOTTLE
					else
						return
				. = TRUE

			if("select_storage")
				if(!chemistry_bag)
					return
				var/obj/item/reagent_containers/target = locate(params["target"])
				if(target && istype(target) && (target.reagent_flags & DRAINABLE) && (target in chemistry_bag.contents))
					selected_storage = WEAKREF(target)
					. = TRUE

			if("interact_handle")
				. = interact_handle(usr)

			if("interact_bag")
				. = interact_bag(usr)

//Code based on defibrillator and hypospray
/obj/item/hypospray_handle
	name = "hypospray handle"
	desc = "The handle of a nearby wall-mounted hypospray. Use to apply medicines to nearby people."

	var/obj/machinery/wall/hypospray/mount

	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE

	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "hypo"

	var/inject_amount = 5
	var/list/possible_inject_amounts = list(1, 5)

	var/obj/item/reagent_containers/storage
	var/mob/listeningTo

/obj/item/hypospray_handle/examine(mob/user)
	. = ..()

	. += "<span class='notice'>It is set to inject [inject_amount] unit\s.</span>"

	if(storage)
		var/datum/reagents/_reagents = storage.reagents
		. += "<span class='notice'>It has [_reagents.total_volume] unit\s in \the attached [storage].</span>"

/obj/item/hypospray_handle/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STORAGE_INSERT, GENERIC_ITEM_TRAIT)

	if (!loc || !istype(loc, /obj/machinery/wall/hypospray)) //To avoid weird issues from admin spawns
		return INITIALIZE_HINT_QDEL

	mount = loc

/obj/item/hypospray_handle/Destroy()
	if(mount)
		mount.handle = null
		mount = null

	if(storage)
		storage.forceMove(get_turf(src))
		storage = null

	. = ..()

/obj/item/hypospray_handle/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/hypospray_handle/attack(mob/living/M, mob/user)
	if(!iscarbon(M))
		return

	mount.inject(M, user, inject_amount)

/obj/item/hypospray_handle/attack_self(mob/user)
	if(possible_inject_amounts.len)
		var/i=0
		for(var/A in possible_inject_amounts)
			i++
			if(A == inject_amount)
				if(i<possible_inject_amounts.len)
					inject_amount = possible_inject_amounts[i+1]
				else
					inject_amount = possible_inject_amounts[1]
				balloon_alert(user, "Transferring [inject_amount]u")
				return

/obj/item/hypospray_handle/attackby(obj/item/I, mob/living/user, params)
	
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/bottle = I

		if(interact_storage(user, bottle))
			return TRUE

	return ..()

/obj/item/hypospray_handle/proc/interact_storage(mob/user, obj/item/reagent_containers/new_beaker = null)
	if(new_beaker && !(new_beaker.reagent_flags & DRAINABLE))
		return FALSE

	var/obj/item/reagent_containers/old_storage
	if(storage)
		storage.forceMove(drop_location())
		old_storage = storage
		. = TRUE
	else
		// When activated from UI, only insert new beaker if there wasn't one already
		if(!new_beaker)
			var/obj/item/potential_new_beaker = user.get_active_held_item()
			if(istype(potential_new_beaker, /obj/item/reagent_containers))
				new_beaker = potential_new_beaker

	if(new_beaker && user.transferItemToLoc(new_beaker, src))
		storage = new_beaker
		. = TRUE
	else
		storage = null

	//Do this here for swapping with both hands busy
	if(old_storage && user && Adjacent(user) && !issiliconoradminghost(user))
		user.put_in_hands(storage)

	if(.)
		mount?.ui_update()
		update_icon()

/obj/item/hypospray_handle/equipped(mob/user, slot)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/check_range)
	listeningTo = user

/obj/item/hypospray_handle/dropped(mob/user)
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
		. = TRUE
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		if(isturf(loc) || (user != loc && mount != loc))
			mount.snap_handle(cause=SNAP_OVEREXTEND)
			. = TRUE
		else
			. = !check_range()
	if(!.)
		. = ..()

/obj/item/hypospray_handle/Moved()
	. = ..()
	check_range()

/obj/item/hypospray_handle/proc/check_range()
	SIGNAL_HANDLER

	. = TRUE

	if(!mount)
		return
	if(!in_range(src, mount))
		mount.snap_handle(cause=SNAP_OVEREXTEND)
		return FALSE

#undef PLUMBING
#undef STORAGE
#undef BOTTLE

#undef SNAP_DROP
#undef SNAP_OVEREXTEND
#undef SNAP_INTERACT