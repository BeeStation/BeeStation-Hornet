/obj/machinery/computer/shuttle_flight/custom_shuttle/exploration
	name = "exploration shuttle console"
	desc = "Used to pilot the exploration shuttle."
	circuit = /obj/item/circuitboard/computer/exploration_shuttle
	shuttleId = "exploration"
	possible_destinations = "exploration_home"
	req_access = list(ACCESS_EXPLORATION)

/obj/machinery/computer/shuttle_flight/custom_shuttle/exploration/linkShuttle(new_id)
	return

/obj/machinery/computer/shuttle_flight/custom_shuttle/exploration/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	return
