/datum/round_event_control/diona_infestation
	name = "Nymph Swarm"
	typepath = /datum/round_event/diona_infestation
	weight = 5
	min_players = 5

/datum/round_event/diona_infestation
	var/spawncount = 5

/datum/round_event/diona_infestation/proc/preRunEvent()
	if(locate(/mob/living/simple_animal/hostile/retaliate/nymph) in GLOB.alive_mob_list)
		return EVENT_INTERRUPTED

/datum/round_event/diona_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipenet/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops nymphs getting stuck in small networks.
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent
	if(!vents.len)
		message_admins("An event attempted to spawn nymphs but no suitable vents were found. Shutting down.")
		return MAP_ERROR
	while(spawncount > 0 && vents.len)
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/hostile/retaliate/nymph/new_nymph = new(vent.loc)
		spawncount--

		announce_to_ghosts(new_nymph)
		message_admins("[ADMIN_LOOKUPFLW(new_nymph)] has been spawned by an event.")
		log_game("diona nymphs were spawned by an event.")
	return SUCCESSFUL_SPAWN
