/datum/round_event_control/abductor
	name = "Abductors"
	typepath = /datum/round_event/ghost_role/abductor
	weight = 9
	max_occurrences = 1
	min_players = 24
	earliest_start = 8 MINUTES //not particularly dangerous, gives abductors time to do their objective
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("nuclear","wizard","revolution")
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/abductor
	minimum_required = 2
	role_name = "abductor team"
	fakeable = FALSE //Nothing to fake here

/datum/round_event/ghost_role/abductor/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		role = /datum/role_preference/midround_ghost/abductor,
		check_jobban = ROLE_ABDUCTOR,
		poll_time = 30 SECONDS,
		role_name_text = "abductor agent",
		alert_pic = /obj/item/melee/baton/abductor,
	)
	if(length(candidates) < 2)
		return NOT_ENOUGH_PLAYERS

	var/mob/living/carbon/human/agent = makeBody(pick_n_take(candidates))
	var/mob/living/carbon/human/scientist = makeBody(pick_n_take(candidates))

	var/datum/team/abductor_team/team = new
	if(team.team_number > ABDUCTOR_MAX_TEAMS)
		return MAP_ERROR

	log_game("[key_name(scientist)] has been selected as [team.name] abductor scientist.")
	log_game("[key_name(agent)] has been selected as [team.name] abductor agent.")

	scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, team)
	agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, team)

	spawned_mobs += list(agent, scientist)

	return SUCCESSFUL_SPAWN
