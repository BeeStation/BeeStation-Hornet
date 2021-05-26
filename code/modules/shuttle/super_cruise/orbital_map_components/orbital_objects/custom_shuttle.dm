/datum/orbital_object/shuttle/custom_shuttle
	name = "Custom Shuttle"

	var/obj/machinery/computer/shuttle_flight/custom_shuttle/attached_console

/datum/orbital_object/shuttle/custom_shuttle/process()
	if(!attached_console)
		return
	attached_console.consume_fuel(ORBITAL_UPDATE_RATE_SECONDS * thrust)
	if(attached_console.check_stranded())
		return
	max_thrust = (5 * arctan(attached_console.calculated_acceleration / 20)) / 90
	. = ..()
