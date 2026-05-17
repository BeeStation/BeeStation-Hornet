/*
	Common ancestor for plant machines that use the terminal control stuff
*/
/obj/machinery/plant_machine
	///Reference to the UI accesor
	var/obj/machinery/computer/plant_machine_controller/controller

/obj/machinery/plant_machine/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	. = ..()
	if(controller?.Adjacent(neighbor))
		return TRUE

/obj/machinery/plant_machine/ui_status(mob/user)
	. = ..()
	if(controller?.Adjacent(user))
		return UI_INTERACTIVE
	else
		return UI_DISABLED

/obj/machinery/plant_machine/ui_act(action, params)
	if(..() && (!isliving(usr) || !in_range(controller, usr)))
		return TRUE

/obj/machinery/plant_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(controller && in_range(controller, usr))
		ui_interact(user)
	else
		to_chat(user, span_danger("[src] can be controlled with a hydroponics machine terminal."))

/obj/machinery/plant_machine/proc/encrypt_ref(ref_string)
	return "0x[copytext(md5(ref_string), 1, 8)]"
