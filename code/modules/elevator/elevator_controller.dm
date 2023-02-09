SUBSYSTEM_DEF(elevator_controller)
	name = "Elevator Controller"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ELEVATOR
	///List of elevator groups
	var/list/elevator_groups = list()

/datum/controller/subsystem/elevator_controller/Initialize(start_timeofday)
	. = ..()

/datum/controller/subsystem/elevator_controller/proc/append_id(id)
	elevator_groups |= id
	
/datum/controller/subsystem/elevator_controller/proc/move_elevator(id, destination_z)
	SEND_SIGNAL(src, COMSIG_ELEVATOR_MOVE, id, destination_z)
