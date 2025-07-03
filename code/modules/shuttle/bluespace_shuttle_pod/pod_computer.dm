/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod
	//Uses a standard custom shuttle circuit.
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	var/shuttle_named = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod)

/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	var/static/pod_shuttles = 0
	var/area/area_instance = get_area(src)
	var/obj/docking_port/mobile/port = locate(/obj/docking_port/mobile) in area_instance
	pod_shuttles ++
	port?.id = "podshuttle_[pod_shuttles]"
	shuttleId = "podshuttle_[pod_shuttles]"
	port?.register()
	//Create a shuttle designator with the port
	var/obj/item/shuttle_creator/shuttle_creator = new(loc)
	shuttle_creator.linkedShuttleId = "podshuttle_[pod_shuttles]"
	shuttle_creator.recorded_shuttle_area = port?.shuttle_areas[1] //Shuttle creators can only handle one area shuttles
	shuttle_creator.update_origin()
	shuttle_creator.reset_saved_area(FALSE)

/obj/machinery/computer/shuttle_flight/custom_shuttle/bluespace_pod/ui_interact(mob/user, datum/tgui/ui)
	if(!shuttle_named && !isobserver(user))
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
