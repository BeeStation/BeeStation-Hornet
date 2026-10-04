//A regular hamsterwheel, with a small dynamo attached
//Able to generate 50W of power (100 times more than what is realistic IRL, but we don't want thousands of these)
/obj/machinery/power/port_gen/hamster_wheel
	name = "\improper Hamster wheel"
	desc = "An ordinary hamster wheel, rigged with an old bicycle dynamo to produce a small amount of power."
	icon = 'icons/obj/machines/power/hamster.dmi'
	icon_state = "hamster_wheel"
	base_icon_state = "hamster_wheel"
	density = FALSE
	power_gen = 50 WATT
	var/power_amplifier = 1
	can_buckle = FALSE

/obj/machinery/power/port_gen/hamster_wheel/Initialize(mapload)
	. = ..()
	//default parts, removed in checkparts if it was actually crafted
	new /obj/item/stock_parts/manipulator(src)
	refresh_parts()

/obj/machinery/power/port_gen/hamster_wheel/proc/refresh_parts()
	var/manip_rating = 0 // Should never be under 1
	for(var/obj/item/stock_parts/manipulator/M in contents)
		manip_rating = M.rating

	if(manip_rating > 0)
		power_amplifier = manip_rating * manip_rating //square the value to get more out of it

/obj/machinery/power/port_gen/hamster_wheel/CheckParts(list/parts_list)
	for(var/obj/item/stock_parts/defaultpart in contents)
		qdel(defaultpart)
	..()
	refresh_parts()


/obj/machinery/power/port_gen/hamster_wheel/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/port_gen/hamster_wheel/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(active)
		open_machine(drop = FALSE)
		dump_inventory_contents(list(occupant))
		to_chat(user, span_notice("You carefully remove the mouse from the wheel."))

/obj/machinery/power/port_gen/hamster_wheel/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				set_anchored(TRUE)
				to_chat(user, span_notice("You secure the hamster wheel to the floor."))
			else if(anchored)
				set_anchored(FALSE)
				to_chat(user, span_notice("You unsecure the hamster wheel from the floor."))

			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return

	return ..()

/obj/machinery/power/port_gen/hamster_wheel/process(delta_time)
	if(occupant == null )
		if(active) {
			TogglePower()
			open_machine(drop = FALSE)
			dump_inventory_contents(list(occupant))
		}
		return FALSE
	if(active)
		if(!HasFuel() || !anchored)
			TogglePower()
			return
		if(powernet)
			add_avail(power_gen * power_output * power_amplifier)
		UseFuel()
	else
		handleInactive()
	return TRUE


/obj/machinery/power/port_gen/hamster_wheel/proc/add_runner(mouse)
	if (active != TRUE)
		close_machine(mouse)
		TogglePower()


//A human sized hamsterwheel, with a large dynamo attached
//Able to generate 5 kW of power (50 times the estimated 100W for a human sized hamster wheel)
/obj/machinery/power/port_gen/hamsterperson_wheel
	name = "\improper Hamsterperson wheel"
	desc = "A large hamster wheel, designed for hamsterpeople to run in. A shame they do not exist. It can generate significantly more power than the regular sized one."
	icon = 'icons/obj/machines/power/human.dmi'
	icon_state = "human_wheel"
	base_icon_state = "human_wheel"
	pixel_x = -9
	density = TRUE
	power_gen = 5 KILOWATT
	var/power_amplifier = 1
	can_buckle = TRUE
	buckle_lying = 0
	///How much we shift the mouse's pixel y when using the wheel.
	var/pixel_shift_y = 3
	dir = EAST	//The wheel should make the runner face east

/obj/machinery/power/port_gen/hamsterperson_wheel/Initialize(mapload)
	. = ..()
	//default parts, removed in checkparts if it was actually crafted
	new /obj/item/stock_parts/manipulator(src)
	refresh_parts()

/obj/machinery/power/port_gen/hamsterperson_wheel/proc/refresh_parts()
	var/manip_rating = 0 // Should never be under 1
	for(var/obj/item/stock_parts/manipulator/M in contents)
		manip_rating = M.rating

	if(manip_rating > 0)
		power_amplifier = manip_rating * manip_rating //square the value to get more out of it

/obj/machinery/power/port_gen/hamsterperson_wheel/CheckParts(list/parts_list)
	for(var/obj/item/stock_parts/defaultpart in contents)
		qdel(defaultpart)
	..()
	refresh_parts()


/obj/machinery/power/port_gen/hamsterperson_wheel/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		dir = EAST //The wheel should make the runner face east
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/port_gen/hamsterperson_wheel/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				set_anchored(TRUE)
				to_chat(user, span_notice("You secure the hamsterperson wheel to the floor."))
			else if(anchored)
				set_anchored(FALSE)
				to_chat(user, span_notice("You unsecure the hamsterperson wheel from the floor."))

			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return
	return ..()

/obj/machinery/power/port_gen/hamsterperson_wheel/process(delta_time)
	if(active)
		if(!HasFuel() || !anchored || !has_buckled_mobs())
			TogglePower()
			return FALSE
		var/mob/living/user = buckled_mobs[1]
		if(!iscarbon(user) || user.stat != CONSCIOUS)
			//no sleepwalkers or dead people on the wheel
			//We check if they are still humanoid, and not ensorcelled by a wizard or mutation toxin
			TogglePower()
			unbuckle_mob(user)
			return FALSE
		if(powernet)
			var/slowdown = max(user.cached_multiplicative_slowdown, 0.1) //Avoid division by zero, and negative values
			var/speed_effect = 2 / slowdown	//The default value appears to be 2, and lower values make us faster
			add_avail(power_gen * power_output * power_amplifier * speed_effect)
		UseFuel()
	else
		if(has_buckled_mobs() && anchored)
			var/mob/living/user = buckled_mobs[1]
			if(!iscarbon(user) || user.stat != CONSCIOUS)
				//Smaller mobs cannot turn the wheel, and everyone else should be awake at least
				unbuckle_mob(user)
				return FALSE
			TogglePower()
		else
			return FALSE
		handleInactive()
	var/mob/living/user = buckled_mobs[1]
	flick("[base_icon_state]-u", src)
	animate(user, pixel_y = pixel_shift_y, time = 0.4 SECONDS, SINE_EASING)
	playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	animate(pixel_y = user.base_pixel_y, time = 0.4 SECONDS, SINE_EASING)

	return TRUE
