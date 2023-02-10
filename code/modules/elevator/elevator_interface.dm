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

//Mapping preset - Primary Elevator
/obj/machinery/elevator_interface/primary
	id = "primary"

/obj/machinery/elevator_interface/attack_hand(mob/living/user)
	. = ..()
	var/destination = preset_z ? z : input(user, "Select Level", "Select Level", z) as num|null
	if(!destination || destination == z)
		return
	SSelevator_controller.move_elevator(id, destination)
