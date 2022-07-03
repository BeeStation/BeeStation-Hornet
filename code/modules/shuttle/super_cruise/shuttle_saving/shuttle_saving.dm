//Return a key
//Even if ID is null just return a key that will put it
//in its own group.
/obj/machinery/computer/shuttle_flight/get_pre_save_key()
	return shuttleId || "null[rand()]"

/obj/docking_port/mobile/get_pre_save_key()
	return id || "null[rand()]"

//Don't save subtypes
/obj/docking_port/mobile/get_saved_type()
	return /obj/docking_port/mobile

/obj/machinery/computer/shuttle_flight/get_saved_type()
	return /obj/machinery/computer/shuttle_flight

/obj/machinery/computer/shuttle_flight/custom_shuttle/get_saved_type()
	return /obj/machinery/computer/shuttle_flight/custom_shuttle

//Set the ID to something unique for saving
/obj/docking_port/mobile/pre_save(list/group, pre_save_key)
	//A unique map key
	var/static/saves = 0
	var/mapkey = "[GLOB.round_id]_[saves++]"
	//The shuttle key
	var/newShuttleKey = "SAVEDSHUTTLE_[mapkey]"
	//Alright lets do pre saving
	for(var/obj/docking_port/mobile/thing in group)
		thing.pre_saved_vars = list()
		thing.pre_saved_vars["id"] = thing.id
		thing.id = newShuttleKey
	for(var/obj/machinery/computer/shuttle_flight/thing in group)
		thing.pre_saved_vars = list()
		thing.pre_saved_vars["shuttleId"] = thing.shuttleId
		thing.shuttleId = newShuttleKey
	return TRUE

//Properly save shuttle consoles
/obj/machinery/computer/shuttle_flight/get_save_vars(save_flag)
	if(!pre_saved_vars)
		return
	. = list()
	.["shuttleId"] = "\"[shuttleId]\""

//Properly save shuttle docks, oh god
/obj/docking_port/mobile/get_save_vars()
	if(!pre_saved_vars)
		return
	. = list()
	.["dwidth"] = dwidth
	.["width"] = width
	.["dheight"] = dwidth
	.["height"] = height
	.["id"] = "\"[id]\""
	.["shuttle_object_type"] = shuttle_object_type
