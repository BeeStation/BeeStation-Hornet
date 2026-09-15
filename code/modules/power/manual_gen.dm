//A regular hamsterwheel, with a small dynamo attached
//Able to generate 0.5W of power
/obj/machinery/power/port_gen/hamster_wheel
	name = "\improper Modified hamster wheel"
	desc = "An ordinary hamster wheel, rigged with an old bicyle dynamo to produce a small amount of power."
	icon = 'icons/obj/machines/power/manual.dmi'
	icon_state = "hamster_wheel"
	base_icon_state = "hamster_wheel"
	// circuit = /obj/item/circuitboard/machine/pacman
	power_gen = 0.5 WATT

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
