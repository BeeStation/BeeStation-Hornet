/// How many seconds between each fuel depletion tick ("use" proc)
#define WELDER_FUEL_BURN_INTERVAL 9
/obj/item/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by Nanotrasen."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	worn_icon_state = "welder"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 5
	hitsound = "swing_hit"
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	drop_sound = 'sound/items/handling/weldingtool_drop.ogg'
	pickup_sound =  'sound/items/handling/weldingtool_pickup.ogg'
	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.75
	light_on = FALSE
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/item_weldingtool
	resistance_flags = FIRE_PROOF

	custom_materials = list(/datum/material/iron=70, /datum/material/glass=30)
	///Whether the welding tool is on or off.
	var/welding = FALSE
	var/status = TRUE 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/change_icons = 1
	var/can_off_process = 0
	light_color = LIGHT_COLOR_FIRE
	var/progress_flash_divisor = 10
	var/burned_fuel_for = 0	//when fuel was last removed
	var/light_intensity = 2
	var/disabled_time = 0 //Used by the cyborg welders to determine how long they remain off after getting hit by a nightmare
	heat = 3800
	tool_behaviour = TOOL_WELDER
	toolspeed = 1


/datum/armor/item_weldingtool
	fire = 100
	acid = 30

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	update_icon()


/obj/item/weldingtool/update_icon_state()
	if(welding)
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"
	return ..()

/obj/item/weldingtool/update_overlays()
	. = ..()
	if(change_icons)
		var/ratio = get_fuel() / max_fuel
		ratio = CEILING(ratio*4, 1) * 25
		. += "[initial(icon_state)][ratio]"
	if(welding)
		. += "[initial(icon_state)]-on"


/obj/item/weldingtool/process(delta_time)
	if(welding)
		force = 15
		damtype = BURN
		burned_fuel_for += delta_time
		if(burned_fuel_for >= WELDER_FUEL_BURN_INTERVAL)
			use(TRUE)
		update_appearance()

	//Welders left on now use up fuel, but lets not have them run out quite that fast
	else
		force = 3
		damtype = BRUTE
		update_appearance()
		if(!can_off_process)
			STOP_PROCESSING(SSobj, src)
		return

	//This is to start fires. process() is only called if the welder is on.
	open_flame()


/obj/item/weldingtool/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] welds [user.p_their()] every orifice closed! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS


/obj/item/weldingtool/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		flamethrower_screwdriver(I, user)
	else if(istype(I, /obj/item/stack/rods))
		flamethrower_rods(I, user)
	else
		. = ..()
	update_icon()

/obj/item/weldingtool/proc/explode()
	var/turf/T = get_turf(loc)
	var/plasmaAmount = reagents.get_reagent_amount(/datum/reagent/toxin/plasma)
	dyn_explosion(T, plasmaAmount/5)//20 plasma in a standard welder has a 4 power explosion. no breaches, but enough to kill/dismember holder
	qdel(src)

/obj/item/weldingtool/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks)
	target.add_overlay(GLOB.welding_sparks)
	. = ..()
	target.cut_overlay(GLOB.welding_sparks)

/obj/item/weldingtool/afterattack(atom/attacked_atom, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isOn())
		handle_fuel_and_temps(1, user)

		if (!QDELETED(attacked_atom) && isliving(attacked_atom)) // can't ignite something that doesn't exist
			handle_fuel_and_temps(1, user)
			var/mob/living/attacked_mob = attacked_atom
			if(attacked_mob.IgniteMob())
				message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(attacked_mob)] on fire with [src] at [AREACOORD(user)]")
				log_game("[key_name(user)] set [key_name(attacked_mob)] on fire with [src] at [AREACOORD(user)]")

	if(!status && attacked_atom.is_refillable())
		reagents.trans_to(attacked_atom, reagents.total_volume, transfered_by = user)
		to_chat(user, span_notice("You empty [src]'s fuel tank into [attacked_atom]."))
		update_appearance()

/obj/item/weldingtool/attack_qdeleted(atom/attacked_atom, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isOn())
		handle_fuel_and_temps(1, user)

		if(!QDELETED(attacked_atom) && isliving(attacked_atom)) // can't ignite something that doesn't exist
			var/mob/living/attacked_mob = attacked_atom
			if(attacked_mob.IgniteMob())
				message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(attacked_mob)] on fire with [src] at [AREACOORD(user)].")
				log_game("set [key_name(attacked_mob)] on fire with [src]")


/obj/item/weldingtool/attack_self(mob/user)
	if(src.reagents.has_reagent(/datum/reagent/toxin/plasma))
		message_admins("[ADMIN_LOOKUPFLW(user)] activated a rigged welder at [AREACOORD(user)].")
		log_game("activated a rigged welder", LOG_ATTACK)
		explode()
	switched_on(user)

	update_appearance()

// Ah fuck, I can't believe you've done this
/obj/item/weldingtool/proc/handle_fuel_and_temps(used = 0, mob/living/user)
	use(used)
	var/turf/location = get_turf(user)
	location.hotspot_expose(700, 50, 1)

// Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount(/datum/reagent/fuel)


// Uses fuel from the welding tool.
/obj/item/weldingtool/use(used = 0)
	if(!isOn() || !check_fuel())
		return FALSE

	if(used > 0)
		burned_fuel_for = 0

	if(get_fuel() >= used)
		reagents.remove_reagent(/datum/reagent/fuel, used)
		check_fuel()
		return TRUE
	else
		return FALSE


//Toggles the welding value.
/obj/item/weldingtool/proc/set_welding(new_value)
	if(welding == new_value)
		return
	. = welding
	welding = new_value
	set_light_on(welding)


//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		set_light_on(FALSE)
		switched_on(user)
		update_icon()
		return 0
	return 1

//Switches the welder on
/obj/item/weldingtool/proc/switched_on(mob/user)
	if(!status)
		balloon_alert(user, "You try to turn [src] on, but it's unsecured!")
		return
	if(world.time < disabled_time)
		balloon_alert(user, "You try to turn [src] on, but nothing happens!")
		return
	set_welding(!welding)
	if(welding)
		if(get_fuel() >= 1)
			balloon_alert(user, "You turn [src] on.")
			playsound(loc, acti_sound, 50, 1)
			force = 15
			damtype = BURN
			hitsound = 'sound/items/welder.ogg'
			update_icon()
			START_PROCESSING(SSobj, src)
		else
			balloon_alert(user, "The [src] is empty!")
			switched_off(user)
	else
		balloon_alert(user, "You turn [src] off.")
		playsound(loc, deac_sound, 50, 1)
		switched_off(user)

//Switches the welder off
/obj/item/weldingtool/proc/switched_off(mob/user)
	set_welding(FALSE)

	force = 3
	damtype = BRUTE
	hitsound = "swing_hit"
	update_icon()


/obj/item/weldingtool/examine(mob/user)
	. = ..()
	. += "It contains [get_fuel()] unit\s of fuel out of [max_fuel]."

/obj/item/weldingtool/is_hot()
	return welding * heat

//Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return welding

// When welding is about to start, run a normal tool_use_check, then flash a mob if it succeeds.
/obj/item/weldingtool/tool_start_check(mob/living/user, amount=0)
	. = tool_use_check(user, amount)
	if(. && user)
		user.flash_act(light_intensity)

// Flash the user during welding progress
/obj/item/weldingtool/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..()
	if(. && user)
		if (progress_flash_divisor == 0)
			user.flash_act(min(light_intensity,1))
			progress_flash_divisor = initial(progress_flash_divisor)
		else
			progress_flash_divisor--

// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/weldingtool/tool_use_check(mob/living/user, amount)
	if(!isOn() || !check_fuel())
		balloon_alert(user, "You need to turn [src] on to do that.")
		return FALSE

	if(get_fuel() >= amount)
		return TRUE
	else
		balloon_alert(user, "The [src] doesn't have enough fuel to complete this task.")
		return FALSE


/obj/item/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		balloon_alert(user, "You should turn [src] off before doing this...")
		return
	status = !status
	if(status)
		balloon_alert(user, "You close the fuel tank.")
		DISABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	else
		balloon_alert(user, "You can now attach, modify and refuel [src].")
		ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	add_fingerprint(user)

/obj/item/weldingtool/proc/flamethrower_rods(obj/item/I, mob/user)
	if(!status)
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/flamethrower/F = new /obj/item/flamethrower(user.loc)
			if(!remove_item_from_storage(F))
				user.transferItemToLoc(src, F, TRUE)
			F.weldtool = src
			add_fingerprint(user)
			balloon_alert(user, "You start bulding a flamethrower...")
			user.put_in_hands(F)
			log_crafting(user, F, TRUE)
		else
			balloon_alert(user, "You need one rod to build a flamethrower!")

/obj/item/weldingtool/ignition_effect(atom/A, mob/user)
	if(use_tool(A, user, 0, amount=1))
		return span_notice("[user] casually lights [A] with [src], what a badass.")
	else
		return ""

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	custom_materials = list(/datum/material/glass=60)

/obj/item/weldingtool/largetank/flamethrower_screwdriver()
	return

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	change_icons = 0

/obj/item/weldingtool/mini/flamethrower_screwdriver()
	return

/obj/item/weldingtool/cyborg
	name = "integrated welding tool"
	desc = "An advanced welder designed to be used in robotic systems. Custom framework doubles the speed of welding."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	toolspeed = 0.5
	max_fuel = 40
	custom_materials = list(/datum/material/glass=60)

/obj/item/weldingtool/cyborg/cyborg_unequip(mob/user)
	if(!isOn())
		return
	switched_on(user)

/obj/item/weldingtool/cyborg/flamethrower_screwdriver()
	return

///This gets called by the lighteater to temporarity disable it
/obj/item/weldingtool/cyborg/proc/disable()
	disabled_time = world.time + 30 SECONDS
	switched_off(usr)
	playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)


/obj/item/weldingtool/cyborg/mini
	name = "integrated emergency welding tool"
	desc = "A miniature integrated welder used during emergencies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	change_icons = 0

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	toolspeed = 0.1
	light_system = NO_LIGHT_SUPPORT
	light_range = 0
	light_intensity = 0
	change_icons = 0

/obj/item/weldingtool/abductor/process()
	if(get_fuel() <= max_fuel)
		reagents.add_reagent(/datum/reagent/fuel, 1)
	..()

/obj/item/weldingtool/hugetank
	name = "upgraded industrial welding tool"
	desc = "An upgraded welder based of the industrial welder."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	max_fuel = 80
	custom_materials = list(/datum/material/iron=70, /datum/material/glass=120)

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	item_state = "exwelder"
	max_fuel = 40
	custom_materials = list(/datum/material/iron=70, /datum/material/glass=120)
	var/last_gen = 0
	change_icons = 0
	can_off_process = 1
	light_intensity = 1
	toolspeed = 0.5
	var/nextrefueltick = 0

/obj/item/weldingtool/experimental/brass
	name = "brass welding tool"
	desc = "A brass welder that seems to constantly refuel itself. It is faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "brasswelder"
	item_state = "brasswelder"
	light_intensity = 1

/obj/item/weldingtool/experimental/process(delta_time)
	..()
	if(get_fuel() < max_fuel && nextrefueltick < world.time)
		nextrefueltick = world.time + 10
		reagents.add_reagent(/datum/reagent/fuel, 0.5*delta_time)

#undef WELDER_FUEL_BURN_INTERVAL
