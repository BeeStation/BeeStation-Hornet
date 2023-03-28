/datum/dock_allocation_tracker
	var/time_left = 10 MINUTES
	var/obj/docking_port/stationary/spawn_point/point
	var/mobile_id

/datum/dock_allocation_tracker/New(mobile_id, dock)
	. = ..()
	src.mobile_id = mobile_id
	point = dock
	START_PROCESSING(SSorbits, src)
	SSorbits.dock_allocations[mobile_id] = src

/datum/dock_allocation_tracker/Destroy(force, ...)
	STOP_PROCESSING(SSorbits, src)
	point.current_allocation = null
	point = null
	SSorbits.dock_allocations[mobile_id] = null
	. = ..()

/datum/dock_allocation_tracker/process(delta_time)
	time_left -= delta_time * 10
	if (time_left < 0)
		expire()
		return PROCESS_KILL

/datum/dock_allocation_tracker/proc/expire()
	var/obj/docking_port/mobile/docked = SSshuttle.getShuttle(mobile_id)
	docked.destination = null
	docked.mode = SHUTTLE_IGNITING
	docked.setTimer(0)
	// Delete mobs on the ship
	for(var/t in docked.return_turfs())
		var/turf/T = t
		for(var/mob/living/M in T.GetAllContents())
			// Ghostize them and put them in nullspace stasis (for stat & possession checks)
			M.notransform = TRUE
			M.ghostize(FALSE)
			M.moveToNullspace()
	spawn(15 SECONDS)
		docked.jumpToNullSpace()
		qdel(src)
