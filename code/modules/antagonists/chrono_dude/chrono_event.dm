/*
	- CHRONO AGENT -
	
	CONTENTS	
		Chrono Event Controller (admin triggered event, just in case something goes wrong and you need a second/multiple chrono suckers)
		The event itself (creates a chrono dude, sets his objectives, gear and protects it)

*/

/datum/round_event_control/chronos
	name = "Timeline Correction Agent"
	typepath = /datum/round_event/ghost_role/chronos
	random = FALSE

/datum/round_event/ghost_role/chronos
	var/success_spawn = 0
	role_name = "timeline correction agent"
	minimum_required = 1
	var/spawn_loc
	var/datum/antagonist/ta/target

/datum/round_event/ghost_role/chronos/spawn_role()
	//selecting a spawn_loc
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
		if(!spawn_locs.len)
			return kill()
		spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return MAP_ERROR

	//selecting a candidate player
	var/list/candidates = get_candidates(ROLE_DEATHSQUAD, null, ROLE_DEATHSQUAD)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected_candidate = pick_n_take(candidates)
	var/key = selected_candidate.key

	//Prepare mind
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = ROLE_DEATHSQUAD
	Mind.special_role = ROLE_DEATHSQUAD
	Mind.active = 1

	//spawn the agent and assign the candidate
	var/mob/living/carbon/human/agent = new(spawn_loc)
	agent.dna.update_dna_identity()

	Mind.transfer_to(agent)
	var/datum/antagonist/tca/antag = new
	if (target)
		antag.assign_prey(target)
	else		//assign a random, already existing target, in case you want to turn adminbus to adminbuse with 10 chronoagents
		for(var/mob/living/carbon/C in GLOB.alive_mob_list)
			var/datum/antagonist/ta/antag_datum = C.mind?.has_antag_datum(/datum/antagonist/ta)
			if(istype(antag_datum))
				antag.assign_prey(antag_datum)
				break
	Mind.add_antag_datum(antag)

	if(agent.mind != Mind)			//something has gone wrong!
		CRASH("TCA created with incorrect mind")

	spawned_mobs += agent
	message_admins("[ADMIN_LOOKUPFLW(agent)] has been made into a Timeline Correction Agent by an event.")
	log_game("[key_name(agent)] was spawned as a Timeline Correction Agent by an event.")

	return SUCCESSFUL_SPAWN
