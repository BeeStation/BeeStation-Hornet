//yoinked from hippie (infiltrators)
/datum/round_event_control/infiltrators
	name = "Infiltrators"
	typepath = /datum/round_event/ghost_role/infiltrators

	weight = 10
	max_occurrences = 1
	earliest_start = 30 MINUTES

	min_players = 18

	gamemode_blacklist = list("nuclear","wizard","revolution","abduction","infiltration","gang","cult","clockcult")

/datum/round_event_control/infiltrators/canSpawnEvent(var/players_amt, var/gamemode)
	. = ..()
	if(SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE) // Don't send infiltrators if the shuttle is coming!
		return FALSE
	var/datum/station_state/current_state = new /datum/station_state()
	current_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(current_state)), 100)
	if(station_integrity < 80) // Don't send infiltrators to a broken station!
		return FALSE

/datum/round_event/ghost_role/infiltrators
	minimum_required = 3
	role_name = "infiltration team"

/datum/round_event/ghost_role/infiltrators/spawn_role()
	var/list/candidates = pollGhostCandidates("Do you wish to be considered for an infiltration team?", ROLE_INFILTRATOR)

	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null
	if(!LAZYLEN(candidates) || candidates.len < 3)
		return NOT_ENOUGH_PLAYERS
	var/numagents = 4
	var/agentcount = 0
	for(var/i = 0, i<numagents,i++)
		shuffle_inplace(candidates) //More shuffles means more randoms
		for(var/mob/j in candidates)
			if(!j || !j.client)
				candidates.Remove(j)
				continue
			theghost = j
			candidates.Remove(theghost)
			chosen += theghost
			agentcount++
			break
	if(agentcount < 3)
		return NOT_ENOUGH_PLAYERS
	//Let's find the spawn locations
	var/datum/team/infiltrator/our_team = new
	for(var/mob/c in chosen)
		var/mob/living/carbon/human/new_character = makeBody(c)
		new_character.mind.assigned_role = "Syndicate Infiltrator"
		new_character.mind.special_role = "Syndicate Infiltrator"
		new_character.mind.add_antag_datum(/datum/antagonist/infiltrator, our_team) // Adding the antag datum teleports them to the base anyways.
		spawned_mobs += new_character
	our_team.update_objectives()
	return SUCCESSFUL_SPAWN
