/datum/round_event_control/mimite_infestation
	name = "Mimite Infestation"
	typepath = /datum/round_event/mimite_infestation
	weight = 10
	min_players = 20


/datum/round_event/mimite_infestation
	announceWhen	= 400
	// 50% chance of being incremented by one
	var/spawncount = 2
	fakeable = TRUE

/datum/round_event/mimite_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	if(prob(50))
		spawncount++

/datum/round_event/mimite_infestation/announce(fake)
	var/living_mimites = FALSE
	for(var/mob/living/simple_animal/hostile/mimite/A)
		if(A.stat != DEAD)
			living_mimites = TRUE

	if(living_mimites || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/mimite_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops mimites getting stuck in small networks.
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent
	if(!vents.len)
		message_admins("An event attempted to spawn mimites but no suitable vents were found. Shutting down.")
		return MAP_ERROR
	while(spawncount > 0 && vents.len)
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/hostile/mimite/new_mimite = new(vent.loc)
		spawncount--
		message_admins("[ADMIN_LOOKUPFLW(new_mimite)] has been spawned by an event.")
		log_game("mimites where spawned by an event.")
	return SUCCESSFUL_SPAWN
