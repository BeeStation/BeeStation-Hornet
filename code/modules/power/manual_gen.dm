//A regular hamsterwheel, with a small dynamo attached
//Able to generate 0.5W of power
/obj/machinery/power/port_gen/hamster_wheel
	name = "\improper Hamster wheel"
	desc = "An ordinary hamster wheel, rigged with an old bicyle dynamo to produce a small amount of power."
	icon = 'icons/obj/machines/power/manual.dmi'
	icon_state = "hamster_wheel"
	base_icon_state = "hamster_wheel"
	density = FALSE
	// circuit = /obj/item/circuitboard/machine/pacman
	power_gen = 5 WATT
	var/power_amplifier = 1
	can_buckle = TRUE
	buckle_lying = 0
	///How much we shift the mouse's pixel y when using the wheel.
	var/pixel_shift_y = 3

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
	if(!has_buckled_mobs())
		if(active) {
			TogglePower()
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
	var/mob/living/user = buckled_mobs[1]
	flick("[base_icon_state]-u", src)
	animate(user, pixel_y = pixel_shift_y, time = 0.4 SECONDS, SINE_EASING)
	playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	animate(pixel_y = user.base_pixel_y, time = 0.4 SECONDS, SINE_EASING)

	return TRUE


/obj/machinery/power/port_gen/hamster_wheel/proc/add_runner(mouse)
	if (active != TRUE)
		buckle_mob(mouse, TRUE, FALSE, buckle_mob_flags = NONE)
		TogglePower()
