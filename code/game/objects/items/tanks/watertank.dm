//Hydroponics tank and base code
/obj/item/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)
	max_integrity = 200
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30, STAMINA = 0)
	resistance_flags = FIRE_PROOF

	var/obj/item/noz
	var/volume = 500

	var/list/fill_icon_thresholds = list(1, 20, 30, 40, 50, 60, 70, 80, 90)

/obj/item/watertank/Initialize(mapload)
	. = ..()
	create_reagents(volume, OPENCONTAINER)
	noz = make_noz()
	update_icon()

/obj/item/watertank/ui_action_click(mob/user)
	toggle_mister(user)

/obj/item/watertank/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return 1

/obj/item/watertank/update_overlays()
	. = ..()
	var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "waterbackpack[fill_icon_thresholds[1]]")

	var/percent = round(((reagents.total_volume / volume) * 100), 1)
	for(var/i in 1 to length(fill_icon_thresholds))
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == length(fill_icon_thresholds)) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "waterbackpack[fill_icon_thresholds[i]]"

	filling.color = get_reagents_color()
	. += filling

/obj/item/watertank/proc/get_reagents_color()
	return mix_color_from_reagents(reagents.reagent_list)


/obj/item/watertank/proc/toggle_mister(mob/living/user)
	if(!istype(user))
		return
	if(user.get_item_by_slot(user.getBackSlot()) != src)
		to_chat(user, "<span class='warning'>The watertank must be worn properly to use!</span>")
		return
	if(user.incapacitated())
		return

	if(QDELETED(noz))
		noz = make_noz()
	if(noz in src)
		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			to_chat(user, "<span class='warning'>You need a free hand to hold the mister!</span>")
			return
		update_icon()
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()

/obj/item/watertank/verb/toggle_mister_verb()
	set name = "Toggle Mister"
	set category = "Object"
	toggle_mister(usr)

/obj/item/watertank/proc/make_noz()
	update_icon()
	return new /obj/item/reagent_containers/spray/mister(src)

/obj/item/watertank/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_BACK)
		remove_noz()

/obj/item/watertank/proc/remove_noz()
	if(!QDELETED(noz))
		if(ismob(noz.loc))
			var/mob/M = noz.loc
			M.temporarilyRemoveItemFromInventory(noz, TRUE)
		noz.forceMove(src)
		update_icon()

/obj/item/watertank/Destroy()
	QDEL_NULL(noz)
	return ..()

/obj/item/watertank/attack_hand(mob/user)
	if (user.get_item_by_slot(user.getBackSlot()) == src)
		toggle_mister(user)
	else
		return ..()

/obj/item/watertank/MouseDrop(obj/over_object)
	var/mob/M = loc
	if(istype(M) && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
		update_icon()
	return ..()

/obj/item/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return 1
	else
		return ..()

/obj/item/watertank/dropped(mob/user)
	..()
	remove_noz()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	item_state = "mister"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	item_flags = NOBLUDGEON | ABSTRACT | ISWEAPON  // don't put in storage
	slot_flags = 0

	var/obj/item/watertank/tank

/obj/item/reagent_containers/spray/mister/Initialize(mapload)
	. = ..()
	tank = loc
	if(!istype(tank))
		return INITIALIZE_HINT_QDEL
	reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents

/obj/item/reagent_containers/spray/mister/attack_self()
	return

/obj/item/reagent_containers/spray/mister/doMove(atom/destination)
	if(destination && (destination != tank.loc || !ismob(destination)))
		if (loc != tank)
			to_chat(tank.loc, "<span class='notice'>The mister snaps back onto the watertank.</span>")
		destination = tank
		tank.update_icon()
	..()

/obj/item/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it
		return
	if(..())
		tank.update_icon()

//Janitor tank
/obj/item/watertank/janitor
	name = "backpack cleaner tank"
	desc = "A janitorial cleaner backpack with nozzle to clean blood and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"
	custom_price = 100

/obj/item/watertank/janitor/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/space_cleaner, 500)

/obj/item/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()

/obj/item/watertank/janitor/make_noz()
	return new /obj/item/reagent_containers/spray/mister/janitor(src)

/obj/item/reagent_containers/spray/mister/janitor/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define RESIN_LAUNCHER 1
#define RESIN_FOAM 2
#define FIREPACK_UPGRADE_SMARTFOAM (1<<0)
#define FIREPACK_UPGRADE_EFFICIENCY (1<<1)

/obj/item/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refrigerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, resin launcher and a smaller scale resin foamer."
	icon = 'icons/obj/atmospherics/equipment.dmi'
	item_state = "waterbackpackatmos"
	icon_state = "waterbackpackatmos"
	volume = 200
	slowdown = 0
	var/nozzle_cooldown = 8 SECONDS //Delay between the uses of launcher and foamer mode, all of these are used for the nozzle
	var/resin_cost = 100 //How many reagents are used per resin launch
	var/upgrade_flags = FALSE
	var/max_foam = 5//Controls the amout of foam the nozzle can output at once

/obj/item/watertank/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, 200)
	update_icon()

/obj/item/watertank/atmos/make_noz()
	update_icon()
	return new /obj/item/extinguisher/mini/nozzle(src)

/obj/item/watertank/atmos/dropped(mob/user)
	..()
	if(istype(noz, /obj/item/extinguisher/mini/nozzle))
		var/obj/item/extinguisher/mini/nozzle/N = noz
		N.update_nozzle_stats()
		N.nozzle_mode = EXTINGUISHER
	update_icon()

/obj/item/watertank/atmos/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/firepack_upgrade))
		install_upgrade(W, user)
		return TRUE
	return ..()

/obj/item/watertank/atmos/update_overlays()
	. = ..()
	if(noz && !locate(noz) in src)//Nozzle exists but it's not in the backpack
		var/obj/item/extinguisher/mini/nozzle/sprayer = noz
		. += "mode_overlay[sprayer.nozzle_mode]"

/obj/item/watertank/atmos/get_reagents_color()
	if(noz)
		var/obj/item/extinguisher/mini/nozzle/sprayer = noz
		if(sprayer.toggled)
			return "#F46402"
	return "#0066FF"


/obj/item/watertank/atmos/proc/install_upgrade(obj/item/firepack_upgrade/frp_up, mob/user)
	if(noz && !locate(noz) in src)
		to_chat(user, "<span class='warning'>[src] can only have upgrades installed while the nozzle is retracted!</span>")
		return
	if(frp_up.upgrade_flags & upgrade_flags)
		to_chat(user, "<span class='warning'>[src] already has this upgrade installed!</span>")
		return
	if(frp_up.upgrade_flags & FIREPACK_UPGRADE_EFFICIENCY)
		volume = 400
		reagents.maximum_volume = 400
		max_foam = 10
		nozzle_cooldown = 4 SECONDS
		resin_cost = 50
		icon_state = "waterbackpackatmos_upgraded"
	upgrade_flags |= frp_up.upgrade_flags
	var/obj/item/extinguisher/mini/nozzle/N = noz
	N.update_nozzle_stats()
	update_icon()
	to_chat(user, "<span class='notice'>You install this upgrade into [src].</span>")
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(frp_up)

/obj/item/watertank/atmos/toggle_mister(mob/living/user)
	if(!istype(user))
		return
	if(user.get_item_by_slot(user.getBackSlot()) != src)
		to_chat(user, "<span class='warning'>The watertank must be worn properly to use!</span>")
		return
	if(user.incapacitated())
		return

	if(QDELETED(noz))
		noz = make_noz()
	if(noz in src)
		//Detach the nozzle into the user's hands
		var/obj/item/extinguisher/mini/nozzle/N = noz
		N.update_nozzle_stats()
		update_icon()
		if(!user.put_in_hands(noz))
			to_chat(user, "<span class='warning'>You need a free hand to hold the mister!</span>")
			return
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()

/obj/item/watertank/atmos/examine(mob/user)
	. = ..()
	if(upgrade_flags & FIREPACK_UPGRADE_EFFICIENCY)
		. += "Its maximum tank volume was increased."

/obj/item/firepack_upgrade
	name = "Backpack Firefighter Tank upgrade disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk4"
	w_class = WEIGHT_CLASS_SMALL
	var/upgrade_flags

/obj/item/firepack_upgrade/smartfoam
	desc = "It upgrades the maximum volume of the tank, increasing the amount of reagents and resin foam mix it can hold"
	upgrade_flags = FIREPACK_UPGRADE_SMARTFOAM

/obj/item/firepack_upgrade/efficiency
	desc = "It improves the nozzle of the firepack, increasing its efficiency and decreasing the downtime between uses"
	icon = 'icons/obj/atmospherics/equipment.dmi'
	icon_state = "efficiency_upgrade"
	upgrade_flags = FIREPACK_UPGRADE_EFFICIENCY

/obj/item/extinguisher/mini/nozzle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon = 'icons/obj/atmospherics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	safety = 0
	max_water = 200
	power = 8
	force = 10
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | ISWEAPON  // don't put in storage
	var/obj/item/watertank/atmos/tank
	var/nozzle_mode = 0
	var/resin_synthesis_cooldown = 0
	var/nozzle_cooldown //Delay between the uses of launcher and foamer mode
	var/resin_cost //How many reagents are used per resin launch
	var/max_foam //Controls the amout of foam the nozzle can output at once
	var/toggled = FALSE //Used for the advanced resin
	COOLDOWN_DECLARE(resin_cooldown)

/obj/item/extinguisher/mini/nozzle/Initialize(mapload)
	. = ..()
	tank = loc
	if (!istype(tank))
		return INITIALIZE_HINT_QDEL
	update_nozzle_stats()
	update_icon()

/obj/item/extinguisher/mini/nozzle/update_overlays()
	. = ..()
	var/fill_icon = "nozzle_overlay"
	if(tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM)
		. += "upgraded_handle_overlay[toggled]"
		if(toggled)
			fill_icon = "nozzle_overlay_on"
	else
		. += "handle_overlay"

	var/mutable_appearance/filling = mutable_appearance('icons/obj/atmospherics/equipment.dmi', "[fill_icon][tank.fill_icon_thresholds[1]]")

	var/percent = round(((tank.reagents.total_volume / tank.volume) * 100), 1)
	for(var/i in 1 to length(tank.fill_icon_thresholds))
		var/threshold = tank.fill_icon_thresholds[i]
		var/threshold_end = (i == length(tank.fill_icon_thresholds)) ? INFINITY : tank.fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_icon][tank.fill_icon_thresholds[i]]"
	. += filling


/obj/item/extinguisher/mini/nozzle/AltClick(mob/user)
	if(tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM)
		toggled = !toggled
		playsound(src, 'sound/machines/click.ogg', 50)
		update_icon()
		tank.update_icon()

/obj/item/extinguisher/mini/nozzle/proc/update_nozzle_stats()
	max_water = tank.volume
	reagents.maximum_volume = tank.reagents.maximum_volume
	reagents = tank.reagents
	nozzle_cooldown = tank.nozzle_cooldown
	resin_cost = tank.resin_cost
	max_foam = tank.max_foam
	if(tank.upgrade_flags & FIREPACK_UPGRADE_EFFICIENCY)
		icon_state = "atmos_nozzle_upgraded"
	update_icon()

/obj/item/extinguisher/mini/nozzle/Destroy()
	reagents = null
	tank = null
	return ..()

/obj/item/extinguisher/mini/nozzle/doMove(atom/destination)
	if(destination && (destination != tank.loc || !ismob(destination)))
		if(loc != tank)
			to_chat(tank.loc, "<span class='notice'>The nozzle snaps back onto the tank!</span>")
		destination = tank
	..()

/obj/item/extinguisher/mini/nozzle/attack_self(mob/user)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = RESIN_LAUNCHER
			tank.update_icon()
			to_chat(user, "Swapped to resin launcher")
			return
		if(RESIN_LAUNCHER)
			nozzle_mode = RESIN_FOAM
			tank.update_icon()
			to_chat(user, "Swapped to resin foamer")
			return
		if(RESIN_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.update_icon()
			to_chat(user, "Swapped to water extinguisher")
			return
	return

/obj/item/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)
		tank.update_icon()
		update_icon()
	if(nozzle_mode == RESIN_LAUNCHER)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < resin_cost)
			to_chat(user, "<span class='warning'>You need at least [resin_cost] units of water to use the resin launcher!</span>")
			return
		if(!COOLDOWN_FINISHED(src, resin_cooldown))
			to_chat(user, "<span class='warning'>Resin launcher is still recharging...</span>")
			return
		COOLDOWN_START(src, resin_cooldown, nozzle_cooldown)
		R.remove_any(resin_cost)
		var/resin_projectile = new /obj/effect/resin_container(get_turf(src))
		if(tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM)
			QDEL_NULL(resin_projectile)
			resin_projectile = new /obj/effect/resin_container/chainreact(get_turf(src))
		var/delay = 2
		var/timeout = 10
		if(tank.upgrade_flags & FIREPACK_UPGRADE_EFFICIENCY)
			delay = 1.5
			timeout = 15
			var/obj/effect/resin_container/resin = resin_projectile
			resin.smoke_amount = 6
		playsound(src,'sound/items/syringeproj.ogg',40,1)
		var/datum/move_loop/loop = SSmove_manager.move_towards(resin_projectile, target, delay, timeout = timeout, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, extra_info = target)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(resin_stop_check))
		RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(resin_landed))
		if(tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM)
			RegisterSignal(loop, COMSIG_MOVELOOP_REACHED_TARGET, PROC_REF(resin_landed))

		log_game("[key_name(user)] used \the [tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM ? "Advanced" : ""] Resin Launcher at [AREACOORD(user)].")
		tank.update_icon()
		update_icon()
		return

	if(nozzle_mode == RESIN_FOAM)
		if(!Adj|| !isturf(target))
			return
		for(var/S in target)
			if(istype(S, /obj/effect/particle_effect/foam/metal/resin) || istype(S, /obj/structure/foamedmetal/resin))
				to_chat(user, "<span class='warning'>There's already resin here!</span>")
				return
		if(resin_synthesis_cooldown < max_foam)
			if(tank.upgrade_flags & FIREPACK_UPGRADE_SMARTFOAM)
				var/obj/effect/particle_effect/foam/metal/chainreact_resin/foam = new (get_turf(target))
				foam.amount = 0
			else
				var/obj/effect/particle_effect/foam/metal/resin/foam = new (get_turf(target))
				foam.amount = 0
			resin_synthesis_cooldown++
			addtimer(CALLBACK(src, PROC_REF(reduce_metal_synth_cooldown)), 10 SECONDS)
			tank.update_icon()
			update_icon()
		else
			to_chat(user, "<span class='warning'>The resin foam mix is still being synthesized...</span>")
			return

/obj/item/extinguisher/mini/nozzle/proc/resin_stop_check(datum/move_loop/source, succeeded)
	SIGNAL_HANDLER
	if(succeeded)
		return
	resin_landed(source)
	qdel(source)

/obj/item/extinguisher/mini/nozzle/proc/resin_landed(datum/move_loop/source)
	SIGNAL_HANDLER
	if(!istype(source.moving, /obj/effect/resin_container) || QDELETED(source.moving))
		return
	var/obj/effect/resin_container/resin = source.moving
	resin.Smoke()

/obj/item/extinguisher/mini/nozzle/proc/reduce_metal_synth_cooldown()
	resin_synthesis_cooldown--

/obj/item/extinguisher/mini/nozzle/examine(mob/user)
	. = ..()
	if(nozzle_mode == RESIN_LAUNCHER)
		. += "It uses [resin_cost] units of reagents per resin launch"

/obj/effect/resin_container
	name = "resin container"
	desc = "A compacted ball of expansive resin, used to repair the atmosphere in a room, or seal off breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE
	anchored = TRUE
	var/smoke_amount = 4

/obj/effect/resin_container/proc/Smoke()
	var/obj/effect/particle_effect/foam/metal/resin/S = new /obj/effect/particle_effect/foam/metal/resin(get_turf(loc))
	S.amount = smoke_amount
	playsound(src,'sound/effects/bamf.ogg',100,1)
	qdel(src)

/obj/effect/resin_container/newtonian_move(direction, instant = FALSE) // Please don't spacedrift thanks
	return TRUE

/obj/effect/resin_container/chainreact
	name = "advanced resin container"
	desc = "A compacted ball of expansive resin, used to repair the atmosphere in a room, or seal off breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule_chainreact"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE | PASSFOAM
	anchored = TRUE

/obj/effect/resin_container/chainreact/Smoke()
	if(locate(/obj/effect/particle_effect/foam/metal/chainreact_resin) in get_turf(src) || locate(/obj/effect/particle_effect/foam/metal/resin) in get_turf(src))
		qdel(src)
		return
	var/obj/effect/particle_effect/foam/metal/chainreact_resin/S = new /obj/effect/particle_effect/foam/metal/chainreact_resin(get_turf(loc))
	S.amount = smoke_amount
	playsound(src,'sound/effects/bamf.ogg',100,1)
	qdel(src)

/obj/effect/resin_container/chainreact/Initialize(mapload)
	. = ..()


#undef EXTINGUISHER
#undef RESIN_LAUNCHER
#undef RESIN_FOAM
#undef FIREPACK_UPGRADE_SMARTFOAM
#undef FIREPACK_UPGRADE_EFFICIENCY

/obj/item/reagent_containers/chemtank
	name = "backpack chemical injector"
	desc = "A chemical autoinjector that can be carried on your back."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpackchem"
	item_state = "waterbackpackchem"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/activate_injector)

	var/on = FALSE
	volume = 300
	var/usage_ratio = 5 //5 unit added per 1 removed
	/// How much to inject per second
	var/injection_amount = 0.5
	amount_per_transfer_from_this = 5
	reagent_flags = OPENCONTAINER
	spillable = FALSE
	possible_transfer_amounts = list(5,10,15)
	fill_icon_thresholds = list(0, 15, 60)
	fill_icon_state = "backpack"

/obj/item/reagent_containers/chemtank/ui_action_click()
	toggle_injection()

/obj/item/reagent_containers/chemtank/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_BACK)
		return 1

/obj/item/reagent_containers/chemtank/proc/toggle_injection()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if (user.get_item_by_slot(ITEM_SLOT_BACK) != src)
		to_chat(user, "<span class='warning'>The chemtank needs to be on your back before you can activate it!</span>")
		return
	if(on)
		turn_off()
	else
		turn_on()

//Todo : cache these.
/obj/item/reagent_containers/chemtank/worn_overlays(mutable_appearance/standing, isinhands = FALSE) //apply chemcolor and level
	. = list()
	//inhands + reagent_filling
	if(!isinhands && reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "backpackmob-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 15)
				filling.icon_state = "backpackmob-10"
			if(16 to 60)
				filling.icon_state = "backpackmob50"
			if(61 to INFINITY)
				filling.icon_state = "backpackmob100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/reagent_containers/chemtank/proc/turn_on()
	on = TRUE
	START_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] turns on.</span>")

/obj/item/reagent_containers/chemtank/proc/turn_off()
	on = FALSE
	STOP_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] turns off.</span>")

/obj/item/reagent_containers/chemtank/process(delta_time)
	if(!ishuman(loc))
		turn_off()
		return
	if(!reagents.total_volume)
		turn_off()
		return
	var/mob/living/carbon/human/user = loc
	if(user.back != src)
		turn_off()
		return

	var/used_amount = (injection_amount * delta_time) /usage_ratio
	reagents.reaction(user, INJECT,injection_amount,0)
	reagents.trans_to(user,used_amount,multiplier=usage_ratio)
	update_icon()
	user.update_inv_back() //for overlays update

//Operator backpack spray
/obj/item/watertank/op
	name = "backpack water tank"
	desc = "A New Russian backpack spray for systematic cleansing of carbon lifeforms."
	icon_state = "waterbackpackop"
	item_state = "waterbackpackop"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 2000
	slowdown = 0

/obj/item/watertank/op/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/mutagen,350)
	reagents.add_reagent(/datum/reagent/napalm,125)
	reagents.add_reagent(/datum/reagent/fuel,125)
	reagents.add_reagent(/datum/reagent/clf3,300)
	reagents.add_reagent(/datum/reagent/cryptobiolin,350)
	reagents.add_reagent(/datum/reagent/toxin/plasma,250)
	reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin,500)

/obj/item/reagent_containers/spray/mister/op
	desc = "A mister nozzle attached to several extended water tanks. It suspiciously has a compressor in the system and is labelled entirely in New Cyrillic."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterop"
	item_state = "misterop"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 100
	possible_transfer_amounts = list(75,100,150)

/obj/item/watertank/op/make_noz()
	return new /obj/item/reagent_containers/spray/mister/op(src)
