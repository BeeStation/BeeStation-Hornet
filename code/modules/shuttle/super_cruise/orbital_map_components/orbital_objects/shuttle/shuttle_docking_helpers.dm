///Public
///Lands a shuttle with a specific port, if the port ID is in the location
///we are docking with.
///Parameters:
/// - portId: The ID of the port to dock with (UNTRUSTED: USER INPUT)
/datum/orbital_object/shuttle/proc/goto_port(portId)
	if(!pre_dock())
		return
	//Get our mobile port
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttle_port_id)
	//Find the target port
	var/obj/docking_port/stationary/target_port = SSshuttle.getDock(portId)
	//Check to ensure the dock exists
	if(!target_port)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Unable to locate target port location.")
		return
	//Check for valid docks
	if(mobile_port.canDock(target_port) != SHUTTLE_CAN_DOCK)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			scramble_message_replace_chars("Critical Error: Invalid docking location"))
		log_admin("[usr] (most likely) attempted to forge a target location through a tgui exploit through shuttle docking.")
		message_admins("[ADMIN_FULLMONTY(usr)] (most likely) attempted to forge a target location through a tgui exploit on shuttle docking.")
		return
	//Make sure the port is in the location we are docking with
	if(!docking_target.z_in_contents(target_port.z))
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Selected docking target")
		return
	//Hold the Z-level we are going to during docking, so it doesn't get z-cleared
	SSzclear.temp_keep_z(target_port.z)
	//Move the shuttle
	switch(SSshuttle.moveShuttle(shuttle_port_id, target_port.id, TRUE))
		if(0)
			SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
				"Initiating supercruise throttle-down, prepare for landing.")
			//Hold the shuttle in the docking position until ready.
			mobile_port.setTimer(INFINITY)
			SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
				"Waiting for hyperspace lane...")
			begin_dethrottle(target_port.z)
		if(1)
			SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
				"Invalid shuttle requested.")
		else
			SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
				"Unable to comply.")

///Private
///Checks if we can dock
/datum/orbital_object/shuttle/proc/pre_dock()
	PRIVATE_PROC(TRUE)
	//Check if we even have a docking target
	if(!docking_target)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Docking target lost, please re-establish orbital trajectory.")
		return FALSE
	//Check if our docking is frozen
	if(docking_frozen)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Docking computer is not responding.")
		return FALSE
	//Check if our target is still generating
	if(docking_target.is_generating)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Docking computer is currently aligning, please wait.")
		return FALSE
	//Get our port
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttle_port_id)
	if(!mobile_port || mobile_port.destination != null)
		return FALSE
	//Check if we are ready
	if(mobile_port.mode == SHUTTLE_RECHARGING)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Supercruise Warning: Shuttle engines not ready for use.")
		return FALSE
	//Check if we are docking with a location
	if(mobile_port.mode != SHUTTLE_CALL || mobile_port.destination)
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
			"Supercruise Warning: Already dethrottling shuttle.")
		return FALSE
	return TRUE

/// Public
/// Undocks from the current docking target
/datum/orbital_object/shuttle/proc/undock()
	if(!docking_target || is_docking)
		return
	velocity.Set(docking_target.velocity.GetX() * 1.1, docking_target.velocity.GetY() * 1.1)
	MOVE_ORBITAL_BODY(src, docking_target.position.GetX(), docking_target.position.GetY())
	docking_target = null
	collision_ignored = TRUE

///Public
///Commences docking with a specified orbital object. This will force our shuttle to remain locked at their location
///Parameters:
/// - docking: The orbital object that we are docking with
/// - forced: If set to true, then we will be forced to dock with the location (otherwise, we may just indicate that we can dock, but not actually dock)
/// - quick_generation: Indicates if the generators should be faster than usual (small asteroids)
/// - block_undocking: If true, will prevent undocking
/datum/orbital_object/shuttle/proc/commence_docking(datum/orbital_object/z_linked/docking, forced = FALSE, quick_generation = FALSE, block_undocking = FALSE)
	//Check for valid docks on z-level
	if((!docking.forced_docking || collision_ignored) && !forced)
		can_dock_with = docking
		return
	//Begin docking.
	is_docking = block_undocking
	docking_target = docking
	//Check for ruin stuff
	var/datum/orbital_object/z_linked/beacon/ruin_obj = docking_target
	if(istype(ruin_obj))
		if(!ruin_obj.linked_z_level)
			ruin_obj.assign_z_level(quick_generation)

///Public
///Randomly drop at a specified z-level
///Parameters:
/// - target_z: The numerical z-value of the level that should be dropped into.
/datum/orbital_object/shuttle/proc/random_drop(target_z, crashing = FALSE)
	//Get shuttle dock
	var/obj/docking_port/mobile/shuttle_dock = SSshuttle.getShuttle(shuttle_port_id)
	if(!shuttle_dock)
		return FALSE
	if(!target_z)
		if(!docking_target)
			CRASH("Attempting to random drop shuttle at invalid location")
		target_z = docking_target.linked_z_level[1].z_value
	if(is_reserved_level(target_z))
		CRASH("Shuttle [shuttle_port_id] attempted to dock on a reserved \
			z-level as a result of docking with [docking_target?.name].")
	//Create temporary port
	var/obj/docking_port/stationary/random_port = new
	var/static/random_drops = 0
	random_port.id = "randomdroplocation_[random_drops++]"
	random_port.name = "Random drop location"
	random_port.delete_after = TRUE
	random_port.width = shuttle_dock.width
	random_port.height = shuttle_dock.height
	random_port.dwidth = shuttle_dock.dwidth
	random_port.dheight = shuttle_dock.dheight
	var/sanity = 20
	var/square_length = max(shuttle_dock.width, shuttle_dock.height)
	var/border_distance = 10 + square_length
	//20 attempts to find a random port
	while(sanity > 0)
		sanity --
		//Place the port in a random valid area.
		var/x = rand(border_distance, world.maxx - border_distance)
		var/y = rand(border_distance, world.maxy - border_distance)
		//Check to make sure there are no indestructible turfs in the way
		random_port.setDir(pick(NORTH, SOUTH, EAST, WEST))
		random_port.forceMove(locate(x, y, target_z))
		var/list/turfs = random_port.return_turfs()
		var/valid = TRUE
		for(var/turf/T as() in turfs)
			if(istype(T, /turf/open/indestructible) || istype(T, /turf/closed/indestructible))
				valid = FALSE
				break
		if(!valid)
			continue
		//Dont wipe z level while we are going
		SSzclear.temp_keep_z(target_z)
		//Ok lets go there
		switch(SSshuttle.moveShuttle(shuttle_port_id, random_port.id, TRUE))
			if(0)
				SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
					"Initiating supercruise throttle-down, prepare for landing.")
				//Hold the shuttle in the docking position until ready.
				shuttle_dock.setTimer(INFINITY)
				SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
					"Waiting for hyperspace lane...")
				begin_dethrottle(target_z)
				return TRUE
			if(1)
				SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
					"Invalid shuttle requested")
			else
				SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
					"Unable to comply.")
	qdel(random_port)
	SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE,
		"Critical Error: Failed to dock at a random location.")
	CRASH("Failed to dock at a random location.")

/datum/orbital_object/shuttle/proc/begin_dethrottle(target_z)
	is_docking = TRUE
	var/datum/space_level/space_level = SSmapping.get_level(target_z)
	timer_id = addtimer(CALLBACK(src, PROC_REF(unfreeze_shuttle)), 3 MINUTES, TIMER_STOPPABLE)
	RegisterSignal(space_level, COMSIG_SPACE_LEVEL_GENERATED, PROC_REF(unfreeze_shuttle))
	//Check if its already generated afterwards due to asynchronous behaviours
	if(!space_level.generating)
		unfreeze_shuttle(space_level)

/datum/orbital_object/shuttle/proc/unfreeze_shuttle(datum/source)
	var/obj/docking_port/mobile/shuttle_dock = SSshuttle.getShuttle(shuttle_port_id)
	if(source)
		UnregisterSignal(source, COMSIG_SPACE_LEVEL_GENERATED)
	else
		//Locate where we were meant to be going
		var/target_z = shuttle_dock.destination.z
		var/datum/space_level/space_level = SSmapping.get_level(target_z)
		UnregisterSignal(space_level, COMSIG_SPACE_LEVEL_GENERATED)
		message_admins("CAUTION: SHUTTLE [shuttle_port_id] REACHED THE GENERATION \
			TIMEOUT OF 3 MINUTES. THE ASSIGNED Z-LEVEL IS STILL MARKED AS GENERATING, \
			BUT WE ARE DOCKING ANYWAY.")
		log_mapping("CAUTION: SHUTTLE [shuttle_port_id] REACHED THE GENERATION TIMEOUT \
			OF 3 MINUTES. THE ASSIGNED Z-LEVEL IS STILL MARKED AS GENERATING, BUT WE ARE \
			DOCKING ANYWAY.")
		SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Warning: Docking at location with \
			bluespace instabilities.")
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	shuttle_dock.setTimer(20)
	qdel(src)
