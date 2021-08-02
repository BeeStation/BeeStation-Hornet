
///Which chemicals to use? Synthesized medicines or inserted bottle?
#define SYNTHESIZER "synthesizer"
#define BOTTLE      "bottle"

///What caused the handle to snap back?
#define SNAP_DROP       0
#define SNAP_OVEREXTEND 1
#define SNAP_INTERACT   2

//Code based on defibrillator, sleeper and chemical synthesizer
/obj/machinery/wall/hypospray
	name = "wall-mounted hypospray"
	desc = "A wall-mounted machine capable of synthesizing common medicines, with a handle for easy application."
	icon = 'icons/obj/machines/wallmount_hypospray.dmi'
	icon_state = "wallmount_hypospray"
	circuit = /obj/item/circuitboard/machine/wall/hypospray
	req_access = list(ACCESS_MEDICAL)

	pixel_shift = 26

	var/efficiency = 0.2
	var/charge_speed = 4
	var/charge = 100
	var/max_charge = 100
	var/charge_counter = 0

	var/obj/item/hypospray_handle/handle
	var/in_use = FALSE
	var/locked = TRUE

	var/chem_source = SYNTHESIZER
	var/obj/item/reagent_containers/storage

	var/datum/reagent/selected_chem
	var/list/available_chems
	var/list/possible_chems = list(
		list(/datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane),
		list(/datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate),
		list(/datum/reagent/medicine/mannitol),
		list(/datum/reagent/medicine/tricordrazine)
	)

/obj/machinery/wall/hypospray/examine(mob/user)
	. = ..()

	. += "<span class='notice'>It is set to draw from the [chem_source].</span>"

	if(storage)
		. += "<span class='notice'>There's \a [storage] inside.</span>"

/obj/machinery/wall/hypospray/Initialize()
	. = ..()
	handle = new(src)

/obj/machinery/wall/hypospray/Destroy()
	QDEL_NULL(handle)
	. = ..()

/obj/machinery/wall/hypospray/on_deconstruction()
	. = ..()

	if(storage)
		storage.forceMove(loc)
		storage = null

/obj/machinery/wall/hypospray/RefreshParts()
	var/bin_rating
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		bin_rating += B.rating

	var/cap_rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		cap_rating += C.rating

	var/manip_rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manip_rating += M.rating

	efficiency = initial(efficiency) * bin_rating
	charge_speed = initial(charge_speed) * cap_rating
	available_chems = list()
	for(var/i in 1 to min(manip_rating, length(possible_chems)))
		available_chems |= possible_chems[i]

	if(available_chems && available_chems.len && (!selected_chem || !(selected_chem in available_chems)))
		selected_chem = available_chems[1]

	ui_update() //Available chems list

/obj/machinery/wall/hypospray/screwdriver_act(mob/living/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "panel_open", "wallmount_hypospray", I))
		return TRUE

	. = ..()

/obj/machinery/wall/hypospray/update_overlays()
	. = ..()

	if(is_operational())
		if(locked)
			. += "screen_yellow"
		else
			. += "screen_green"

	if(!in_use)
		. += "handle"

/obj/machinery/wall/hypospray/update_icon_state()
	if(panel_open)
		icon_state = "panel_open"
	else
		icon_state = initial(icon_state)

/obj/machinery/wall/hypospray/process(delta_time)
	if (charge_counter >= 8)
		charge_counter -= 8
		if(!is_operational())
			return
		var/charge_amount = min(max_charge-charge, charge_speed)
		if(charge_amount > 0)
			use_power(250*charge_amount)
			charge += charge_amount
			ui_update() //Charge level display
		return
	charge_counter += delta_time

/obj/machinery/wall/hypospray/power_change()
	. = ..()
	update_icon()

/obj/machinery/wall/hypospray/proc/use_charge(volume)
	var/power_use = volume/efficiency

	if(!is_operational())
		return FALSE

	if(charge < power_use)
		return FALSE

	charge -= power_use
	ui_update() //Charge level display
	return TRUE

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

/obj/machinery/wall/hypospray/proc/inject(mob/living/target, mob/user, amount)

	//Always log attemped injects for admins
	var/list/injected = list()
	switch(chem_source)
		if(SYNTHESIZER)
			if(!use_charge(amount))
				to_chat(user, "<span class='warning'>[src] is out of power!</span>")
				return
			injected += initial(selected_chem.name)
		if(BOTTLE)
			if(!storage)
				to_chat(user, "<span class='warning'>[src] has no bottle attached!</span>")
				return
			if(!storage.reagents.total_volume)
				to_chat(user, "<span class='warning'>[src] hisses but nothing comes out. The attached bottle is empty!</span>")
				return
			for(var/datum/reagent/R in storage.reagents.reagent_list)
				injected += R.name

	var/contained = english_list(injected)
	log_combat(user, target, "attempted to inject", handle, "([contained])")

	if(target.can_inject(user, 1))
		to_chat(target, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [target] with [handle].</span>")
		playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

		switch(chem_source)
			if(SYNTHESIZER)
				target.reagents.add_reagent(selected_chem, amount)
			if(BOTTLE)
				var/datum/reagents/_reagents = storage.reagents
				var/fraction = min(amount/_reagents.total_volume, 1)
				_reagents.reaction(target, INJECT, fraction)
				_reagents.trans_to(target, amount, transfered_by = user)

				to_chat(user, "<span class='notice'>[_reagents.total_volume] unit\s remaining in [storage].</span>")
				ui_update() // Bottle fill display

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

/obj/machinery/wall/hypospray/proc/interact_storage(mob/user, obj/item/reagent_containers/new_beaker = null)
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

	//update_icon()

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

	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/beaker = I

		if(interact_storage(user, beaker))
			ui_update() //Bottle holder button
			return TRUE

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

	if(selected_chem)
		var/datum/reagent/chem = GLOB.chemical_reagents_list[selected_chem]
		data["selected_chem"] = chem.name

	data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(list("name" = R.name, "id" = R.type))

	data["bottle"] = storage?.name
	data["bottle_volume"] = storage?.reagents?.total_volume
	data["bottle_max_volume"] = storage?.volume

	data["chem_source"] = chem_source
	data["storage"] = storage?.name
	data["locked"] = locked
	data["charge"] = charge
	data["max_charge"] = max_charge
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
					if(SYNTHESIZER)
						chem_source = SYNTHESIZER
					if(BOTTLE)
						chem_source = BOTTLE
					else
						return
				. = TRUE

			if("select_chem")
				var/target = text2path(params["target"])
				if(target && (target in available_chems))
					selected_chem = target
					. = TRUE

			if("interact_handle")
				. = interact_handle(usr)

			if("interact_storage")
				. = interact_storage(usr)

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

	var/mob/listeningTo

/obj/item/hypospray_handle/examine(mob/user)
	. = ..()

	. += "<span class='notice'>It is set to inject [inject_amount] unit\s.</span>"

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

#undef SYNTHESIZER
#undef BOTTLE

#undef SNAP_DROP
#undef SNAP_OVEREXTEND
#undef SNAP_INTERACT