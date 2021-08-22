/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod
	//Uses a standard custom shuttle circuit.
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	var/shuttle_named = FALSE

/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	var/static/pod_shuttles = 0
	var/area/area_instance = get_area(src)
	var/obj/docking_port/mobile/port = locate(/obj/docking_port/mobile) in area_instance
	pod_shuttles ++
	port.id = "podshuttle_[pod_shuttles]"
	shuttleId = "podshuttle_[pod_shuttles]"
	//Create a shuttle designator with the port
	var/obj/item/shuttle_creator/shuttle_creator = new(loc)
	shuttle_creator.linkedShuttleId = "podshuttle_[pod_shuttles]"

/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod/ui_interact(mob/user, datum/tgui/ui)
	if(!shuttle_named)
		var/area/area_instance = get_area(src)
		var/obj/docking_port/mobile/port = locate(/obj/docking_port/mobile) in area_instance
		if(port)
			port.name = stripped_input(user, "Shuttle Name:", "Blueprint Editing", "", MAX_NAME_LEN)
			if(!port.name)
				port.name = "Unnamed shuttle"
		shuttle_named = TRUE
	. = ..()

/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod/traitor
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
