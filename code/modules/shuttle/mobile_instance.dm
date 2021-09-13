
//ID is a temp ID that links shuttles in the map file.
//Port and consoles must be on the same map file, will not work if the shuttle console is placed on a different map.
//After map load, the shuttle will be given a new unique ID and any consoles with the old port will be given the new unique ID.
//Used for making ships that can spawn multiple times and are fully contained in 1 file.
//
//Works for shuttles carrying other shuttles too.
/obj/docking_port/mobile/instance/New(loc, ...)
	. = ..()
	SSshuttle.ports_to_init += src

/obj/docking_port/mobile/instance/proc/generate_unique_id()
	var/static/number = 0
	//Generate a unique ID
	var/old_id = id
	id = "[id]_[number++]"
	//Find attached flight consoles
	for(var/atom/thing as() in SSshuttle.consoles)
		if(!thing)
			stack_trace("Warning: Null value in SSshuttle.consoles!")
			continue
		//Update anything thats linked to us to use our new unique ID.
		if(thing.get_linked_shuttle() == old_id)
			thing.connect_to_shuttle(src, override = TRUE)
