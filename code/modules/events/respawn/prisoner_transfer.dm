/datum/round_event_control/respawn/prisoner
	name = "Prisoners"
	typepath = /datum/round_event/ghost_role/prisoner
	weight = 100
	earliest_start = 1 MINUTES	//The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins
	min_players = 0			//The minimum amount of alive, non-AFK human players on server required to start the event.
	max_occurrences = 1		//The maximum number of times this event can occur (naturally), it can still be forced.
	cannot_spawn_after_shuttlecall = TRUE	// Prevents the event from spawning after the shuttle was called

/datum/round_event/ghost_role/prisoner
	minimum_required = 1
	role_name = "Transferred prisoners"
	fakeable = FALSE

/datum/round_event/ghost_role/prisoner/spawn_role() //make them spawn in drop pods that land on open turfs in the prison hopefully
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_PRISONER, /datum/role_preference/midround_ghost/prisoner)
	var/list/spawn_locs = list()

	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list) //carp spawn placeholder, THIS CANNOT BE IN THE FINAL VERSION, SCREAM AT ME IF YOU SEE THIS
		if(isturf(L.loc))
			spawn_locs += L.loc

	if(candidates.len < 1)
		return NOT_ENOUGH_PLAYERS
	var/i
	for(i=0, i<=3, i++) //Pick candidates until we have 3 prisoners
		if(!length(candidates))
			continue
		var/mob/living/carbon/prisoner = makeBody(pick_n_take(candidates))
		log_game("[key_name(prisoner)] has been selected as a transferred prisoner")
		prisoner.mind.add_antag_datum(/datum/antagonist/prisoner)
		spawned_mobs += list(prisoner)

	return SUCCESSFUL_SPAWN

