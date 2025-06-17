/datum/round_event_control/mimite_infestation
	name = "Mimite Infestation"
	typepath = /datum/round_event/mimite_infestation
	weight = 10
	min_players = 20


/datum/round_event/mimite_infestation
	announceWhen = 200
	// 50% chance of being incremented by one
	var/spawncount = 3
	fakeable = TRUE

/datum/round_event/mimite_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	endWhen = 3600 //60 min
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
			var/datum/pipenet/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops mimites getting stuck in small networks.
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent
	if(!vents.len)
		message_admins("An event attempted to spawn mimites but no suitable vents were found. Shutting down.")
		return MAP_ERROR
	while(spawncount > 0 && vents.len)
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/hostile/mimite/new_mimite = new(vent.loc)
		switch(length(GLOB.player_list))
			if(0 to 20)
				new_mimite.remaining_replications = 3
			if(20 to 40)
				new_mimite.remaining_replications = 4
			else
				new_mimite.remaining_replications = 5
		spawncount--
		announce_to_ghosts(new_mimite)
		message_admins("[ADMIN_LOOKUPFLW(new_mimite)] has been spawned by an event.")
		log_game("mimites where spawned by an event.")
	return SUCCESSFUL_SPAWN


/datum/round_event/mimite_infestation/end()
	if(length(GLOB.all_mimites)) //If they're still around at the end of 60 min, turn of replication permanently
		for(var/mob/living/simple_animal/hostile/mimite/M in GLOB.all_mimites)
			M.eventongoing = FALSE
	else
		priority_announce("Sensors are no-longer detecting an outbreak of Mimites, well done crew!", "Lifesign Alert", SSstation.announcer.get_rand_alert_sound())
