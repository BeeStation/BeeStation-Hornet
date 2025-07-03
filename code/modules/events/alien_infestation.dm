/datum/round_event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/ghost_role/alien_infestation
	weight = 5

	min_players = 10

	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE
	can_malf_fake_alert = TRUE

/datum/round_event_control/alien_infestation/canSpawnEvent()
	. = ..()
	if(!.)
		return .

	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			return FALSE

/datum/round_event/ghost_role/alien_infestation
	announceWhen	= 400

	minimum_required = 1
	role_name = "alien larva"

	// 50% chance of being incremented by one
	var/spawncount = 1
	fakeable = TRUE


/datum/round_event/ghost_role/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	if(prob(50))
		spawncount++

/datum/round_event/ghost_role/alien_infestation/announce(fake)
	var/living_aliens = FALSE
	for(var/mob/living/carbon/alien/A in GLOB.player_list)
		if(A.stat != DEAD)
			living_aliens = TRUE

	if(living_aliens || fake)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)


/datum/round_event/ghost_role/alien_infestation/spawn_role()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipenet/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue//no parent vent
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent

	if(!length(vents))
		return MAP_ERROR

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		role = /datum/role_preference/midround_ghost/xenomorph,
		check_jobban = ROLE_ALIEN,
		poll_time = 30 SECONDS,
		role_name_text = "alien larva",
		alert_pic = /mob/living/carbon/alien/larva,
	)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	while(spawncount > 0 && length(candidates) && length(vents))
		var/obj/vent = pick_n_take(vents)
		var/mob/dead/observer/candidate = pick_n_take(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate.key

		message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by an event.")
		log_game("[key_name(new_xeno)] was spawned as an alien by an event.")
		spawned_mobs += new_xeno
		spawncount--

	return SUCCESSFUL_SPAWN
