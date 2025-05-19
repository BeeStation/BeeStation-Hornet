/datum/dynamic_ruleset/midround
	rule_category = DYNAMIC_CATEGORY_MIDROUND
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)

	/// How dangerous/disruptive the ruleset is. (DYNAMIC_MIDROUND_LIGHT, DYNAMIC_MIDROUND_MEDIUM, DYNAMIC_MIDROUND_HEAVY)
	var/severity
	/// Whether or not ghost roles are allowed to roll this ruleset (Ashwalkers, Golems, Drones, etc.)
	var/allow_ghost_roles = FALSE
	/// What mob type the ruleset is restricted to.
	var/mob_type = /mob/living/carbon/human

/datum/dynamic_ruleset/midround/get_candidates()
	candidates = dynamic.current_players[CURRENT_LIVING_PLAYERS]

/datum/dynamic_ruleset/midround/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Correct mob type?
		if(!istype(candidate, mob_type))
			candidates -= candidate
			continue
		// Compatible job?
		if(candidate.mind?.assigned_role in restricted_roles)
			candidates -= candidate
			continue
		// Ghost role?
		if(!allow_ghost_roles && (candidate.mind?.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL]))
			candidates -= candidate
			continue

/datum/dynamic_ruleset/midround/select_player()
	if(!length(candidates))
		stack_trace("[src] called select_player without any candidates!")
		return

	var/mob/selected_player = dynamic && CHECK_BITFIELD(flags, SHOULD_USE_ANTAG_REP) ? dynamic.antag_pick(candidates, role_preference) : pick(candidates)

	if(selected_player)
		candidates -= selected_player
	return selected_player.mind

/datum/dynamic_ruleset/midround/execute()
	// Get our candidates
	set_drafted_players_amount()
	get_candidates()
	trim_candidates()

	if(!length(candidates))
		return DYNAMIC_EXECUTE_FAILURE

	for(var/i = 1 to drafted_players_amount)
		var/datum/mind/chosen_mind = select_player()

		chosen_candidates += chosen_mind
		chosen_mind.special_role = antag_datum.banning_key

	. = ..()

//////////////////////////////////////////////
//                                          //
//         VALUE DRIFTED AI (MEDIUM)        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/value_drifted
	name = "Value Drifted AI"
	severity = DYNAMIC_MIDROUND_MEDIUM
	restricted_roles = list(JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)
	role_preference = /datum/role_preference/midround_living/malfunctioning_ai
	antag_datum = /datum/antagonist/malf_ai
	points_cost = 40
	weight = 2
	mob_type = /mob/living/silicon/ai

//////////////////////////////////////////////
//                                          //
//          SLEEPER AGENT (LIGHT)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/sleeper_agent
	name = "Syndicate Sleeper Agent"
	severity = DYNAMIC_MIDROUND_LIGHT
	role_preference = /datum/role_preference/midround_living/traitor
	antag_datum = /datum/antagonist/traitor
	points_cost = 30

//////////////////////////////////////////////
//                                          //
//             HERETIC (LIGHT)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/heretic
	name = "Fanatic Revelation"
	severity = DYNAMIC_MIDROUND_LIGHT
	role_preference = /datum/role_preference/midround_living/heretic
	antag_datum = /datum/antagonist/heretic
	points_cost = 30

/datum/dynamic_ruleset/midround/heretic/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/heretic/new_heretic = IS_HERETIC(chosen_mind.current)

		// Heretics passively gain influence over time.
		// As a consequence, latejoin heretics start out at a massive
		// disadvantage if the round's been going on for a while.
		// Let's give them some influence points when they arrive.
		new_heretic.knowledge_points += round((world.time - SSticker.round_start_time) / new_heretic.passive_gain_timer)
		// BUT let's not give smugglers a million points on arrival.
		// Limit it to four missed passive gain cycles (4 points).
		new_heretic.knowledge_points = min(new_heretic.knowledge_points, 5)

//////////////////////////////////////////////
//                                          //
//             OBSESSED (LIGHT)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/obsessed
	name = "Obsessed"
	severity = DYNAMIC_MIDROUND_LIGHT
	antag_datum = /datum/antagonist/obsessed
	role_preference = /datum/role_preference/midround_living/obsessed
	points_cost = 20

/datum/dynamic_ruleset/midround/obsessed/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		if(ishuman(chosen_mind.current))
			var/mob/living/carbon/human/human_target = chosen_mind.current
			human_target.gain_trauma(/datum/brain_trauma/special/obsessed)
