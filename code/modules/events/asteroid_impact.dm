
/datum/round_event_control/asteroid_impact
	name = "Asteroid Impact (End Round)"
	typepath = /datum/round_event/asteroid_impact
	weight = -1
	max_occurrences = 0

/datum/round_event/asteroid_impact
	//Should be enough time to escape.
	startWhen = 260
	announceWhen = 1

/datum/round_event/asteroid_impact/announce(fake)
	priority_announce("A class-A asteroid has been detected on a collision course with the station. Destruction of the station is innevitable.")
	if(!fake)
		set_security_level(SEC_LEVEL_DELTA)
		var/area/A = GLOB.areas_by_type[/area/centcom]
		if(EMERGENCY_IDLE_OR_RECALLED)
			SSshuttle.emergency.request(null, A, "Automatic Shuttle Call: Station destruction imminent.", TRUE)
		else
			if(SSshuttle.emergency.timer > world.time + 5 MINUTES)
				SSshuttle.emergency.setTimer(5 MINUTES)

/datum/round_event/asteroid_impact/start()
	for(var/mob/living/M in GLOB.mob_list)
		if(is_station_level(M.z) && !QDELETED(M))
			explosion(M, 3, 4, 6, 0, FALSE)
			qdel(M)
			CHECK_TICK
