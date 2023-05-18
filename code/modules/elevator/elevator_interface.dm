/obj/machinery/elevator_interface
	name = "elevator interface"
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_interface"
	desc = "A control panel for the elevator."
	density = FALSE
	emag_toggleable = TRUE
	//Helps us group elevator components
	var/id
	///List of levels we can travel to
	var/list/available_levels = list()
	///Do we call the elevator down or up to us
	var/preset_z = FALSE
	//The detail offset
	var/z_offset = -1
	///The amount of time it takes to call an elevator
	var/calltime = 8 SECONDS
	///Do we add the standing overlay?
	var/standing = FALSE

//Mapping preset - Primary Elevator
/obj/machinery/elevator_interface/primary
	id = "primary"
	available_levels = list(1, 2, 3)

// Glowstation
/obj/machinery/elevator_interface/secure
	id = "secure"
	available_levels = list(1, 2, 5)
	calltime = 3.5 SECONDS // this is a long elevator, please don't take 5 years

/obj/machinery/elevator_interface/Initialize(mapload)
	. = ..()
	if(standing)
		var/mutable_appearance/M = mutable_appearance('icons/obj/elevator.dmi', "elevator_stand")
		add_overlay(M)

/obj/machinery/elevator_interface/attack_hand(mob/living/user)
	. = ..()
	if(preset_z)
		select_level(get_virtual_z_level() + z_offset)

/obj/machinery/elevator_interface/proc/select_level(display_level)
	if(!powered() || SSelevator_controller.elevator_group_timers[id])
		if(powered())
			say("Elevator is currently moving, please wait.")
		return
	var/real_destination = display_level - z_offset
	var/display_destination = display_level
	if(!(display_destination in available_levels))
		return
	if(!real_destination || (real_destination == get_virtual_z_level() && !preset_z))
		return
	if(preset_z)
		say("Calling elevator...")
	if(!SSelevator_controller.move_elevator(id, real_destination, calltime * abs(get_virtual_z_level() - real_destination), obj_flags & EMAGGED))
		say("Elevator obstructed...")

/obj/machinery/elevator_interface/on_emag(mob/user)
	. = ..()
	if(!(obj_flags & EMAGGED))
		say("Recalibrating...")

/obj/machinery/elevator_interface/ui_interact(mob/user, datum/tgui/ui)
	if(preset_z)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Elevator", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/elevator_interface/ui_data(mob/user)
	var/list/data = list()
	data["current_z"] = get_virtual_z_level()+z_offset
	data["available_levels"] = available_levels
	data["in_transit"] = !!SSelevator_controller.elevator_group_timers[id]
	return data

/obj/machinery/elevator_interface/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/num = text2num(action)
	if(isnum(num))
		select_level(num)
	return TRUE
