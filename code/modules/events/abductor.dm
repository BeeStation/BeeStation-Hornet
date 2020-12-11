/datum/round_event_control/abductor
	name = "Abductors"
	typepath = /datum/round_event/ghost_role/abductor
	weight = 12
	max_occurrences = 1
	min_players = 20
	earliest_start = 8 MINUTES //not particularly dangerous, gives abductors time to do their objective
	gamemode_blacklist = list("nuclear","wizard","revolution")

/datum/round_event/ghost_role/abductor
	minimum_required = 1
	role_name = "abductor team"
	fakeable = FALSE //Nothing to fake here

/datum/round_event/ghost_role/abductor/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_ABDUCTOR, null, ROLE_ABDUCTOR)

	if(candidates.len < 1)
		return NOT_ENOUGH_PLAYERS
	if(candidates.len >= 2)
		var/mob/living/carbon/human/agent = makeBody(pick_n_take(candidates))
		var/mob/living/carbon/human/scientist = makeBody(pick_n_take(candidates))

		var/datum/team/abductor_team/T = new
		if(T.team_number > ABDUCTOR_MAX_TEAMS)
			return MAP_ERROR

		log_game("[key_name(scientist)] has been selected as [T.name] abductor scientist.")
		log_game("[key_name(agent)] has been selected as [T.name] abductor agent.")

		scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, T)
		agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, T)

		spawned_mobs += list(agent, scientist)
	else
		var/mob/living/carbon/human/sci_agent = makeBody(pick_n_take(candidates))

		var/datum/team/abductor_team/T = new
		if(T.team_number > ABDUCTOR_MAX_TEAMS)
			return MAP_ERROR
		log_game("[key_name(sci_agent)] has been selected as [T.name] abductor sci-agent.")

		sci_agent.mind.add_antag_datum(/datum/antagonist/abductor/scientist/onemanteam, T)

	return SUCCESSFUL_SPAWN
