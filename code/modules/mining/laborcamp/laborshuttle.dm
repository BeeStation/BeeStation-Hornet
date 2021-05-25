/obj/machinery/computer/shuttle_flight/labor
	name = "labor shuttle console"
	desc = "Used to call and send the labor camp shuttle."
	circuit = /obj/item/circuitboard/computer/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle_flight/labor/one_way
	name = "prisoner shuttle console"
	desc = "A one-way shuttle console, used to summon the shuttle to the labor camp."
	recall_docking_port_id = "laborcamp_away"
	circuit = /obj/item/circuitboard/computer/labor_shuttle/one_way
	req_access = list( )
