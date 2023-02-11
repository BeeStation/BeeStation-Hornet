/obj/machinery/elevator_interface
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_interface"
	density = FALSE
	//Helps us group elevator components
	var/id
	///List of levels we can travel to
	var/list/available_levels = list()
	///Do we call the elevator down or up to us
	var/preset_z = FALSE
	//The detail offset
	var/z_offset = -1
	///The amount of time it takes to call an elevator
	var/calltime = 3 SECONDS
	///Do we add the standing overlay?
	var/standing = FALSE

//Mapping preset - Primary Elevator
/obj/machinery/elevator_interface/primary
	id = "primary"
	available_levels = list(1, 2, 3)

/obj/machinery/elevator_interface/Initialize(mapload)
	. = ..()
	if(standing)
		var/mutable_appearance/M = mutable_appearance('icons/obj/elevator.dmi', "elevator_stand")
		add_overlay(M)

/obj/machinery/elevator_interface/attack_hand(mob/living/user)
	. = ..()
	if(!powered() || SSelevator_controller.elevator_group_timers[id])
		if(powered())
			say("Unable to call elevator...")
		return
	var/destination = preset_z ? z : input(user, "Select Level", "Select Level", z+z_offset) as num|null
	if(!(destination in available_levels))
		return
	destination -= preset_z ? 0 : z_offset
	if(!destination || (destination == z && !preset_z))
		return
	if(preset_z)
		say("Calling elevator...")
	if(!SSelevator_controller.move_elevator(id, destination, calltime * abs(z - destination)))
		say("Elevator obstructed...")
