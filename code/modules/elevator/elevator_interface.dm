/obj/machinery/elevator_interface
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_interface"
	density = FALSE
	//Helps us group elevator components
	var/id
	///List of levels we can travel to
	var/list/available_levels = list()

//Mapping preset - Primary Elevator
/obj/machinery/elevator_interface/primary
	id = "primary"

/obj/machinery/elevator_interface/attack_hand(mob/living/user)
	. = ..()
	var/destination = input(user, "Select Level", "Select Level", z) as num|null
	if(!destination)
		return
	SSelevator_controller.move_elevator(id, destination)
