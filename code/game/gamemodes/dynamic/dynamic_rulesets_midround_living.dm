/datum/dynamic_ruleset/midround/living
	/// Whether or not ghost roles are allowed to roll this ruleset (Ashwalkers, Golems, Drones, etc.)
	var/allow_ghost_roles = FALSE
	/// What mob type the ruleset is restricted to.
	var/mob_type = /mob/living/carbon/human

/datum/dynamic_ruleset/midround/living/get_candidates()
	candidates = dynamic.current_players[CURRENT_LIVING_PLAYERS]

/datum/dynamic_ruleset/midround/living/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Correct mob type?
		if(!istype(candidate, mob_type))
			candidates -= candidate
			continue

		// Compatible job?
		if(candidate.mind.assigned_role in restricted_roles)
			candidates -= candidate
			continue

		// Ghost role?
		if(!allow_ghost_roles && (candidate.mind?.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL]))
			candidates -= candidate
			continue

/datum/dynamic_ruleset/midround/living/execute()
	// Get our candidates
	set_drafted_players_amount()
	get_candidates()
	trim_candidates()

	if(!allowed())
		return DYNAMIC_EXECUTE_FAILURE

	// Select candidates
	for(var/i = 1 to drafted_players_amount)
		chosen_candidates += select_player()

	// See if they actually want to play this role
	var/previous_chosen_candidates = length(chosen_candidates)
	chosen_candidates = SSpolling.poll_candidates(
		group = chosen_candidates,
		poll_time = 30 SECONDS,
		role_name_text = name,
		alert_pic = get_poll_icon(),
	)

	if(!length(chosen_candidates))
		message_admins("DYNAMIC: [previous_chosen_candidates] players were selected for [src] but none of them wanted to play it.")
		log_dynamic("NOT ALLOWED: Not enough players volunteered for the [src] ruleset - [length(chosen_candidates)] out of [drafted_players_amount].")
		return DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS

	for(var/mob/chosen_candidate in chosen_candidates)
		chosen_candidate.mind.special_role = antag_datum.banning_key
	. = ..()

//////////////////////////////////////////////
//                                          //
//         VALUE DRIFTED AI (MEDIUM)        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/value_drifted
	name = "Value Drifted AI"
	severity = DYNAMIC_MIDROUND_MEDIUM
	restricted_roles = list(JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)
	role_preference = /datum/role_preference/midround_living/malfunctioning_ai
	antag_datum = /datum/antagonist/malf_ai
	points_cost = 40
	weight = 2
	mob_type = /mob/living/silicon/ai

/datum/dynamic_ruleset/midround/living/value_drifted/get_poll_icon()
	return icon('icons/mob/ai.dmi', icon_state = "ai-not malf")

//////////////////////////////////////////////
//                                          //
//          SLEEPER AGENT (LIGHT)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/sleeper_agent
	name = "Syndicate Sleeper Agent"
	severity = DYNAMIC_MIDROUND_LIGHT
	role_preference = /datum/role_preference/midround_living/traitor
	antag_datum = /datum/antagonist/traitor
	points_cost = 30

/datum/dynamic_ruleset/midround/living/sleeper_agent/get_poll_icon()
	return /obj/item/gun/ballistic/revolver

//////////////////////////////////////////////
//                                          //
//             HERETIC (LIGHT)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/heretic
	name = "Fanatic Revelation"
	severity = DYNAMIC_MIDROUND_LIGHT
	role_preference = /datum/role_preference/midround_living/heretic
	antag_datum = /datum/antagonist/heretic
	points_cost = 30

/datum/dynamic_ruleset/midround/living/heretic/get_poll_icon()
	return /obj/item/codex_cicatrix

/datum/dynamic_ruleset/midround/living/heretic/execute()
	. = ..()
	for(var/mob/chosen_candidate in chosen_candidates)
		var/datum/antagonist/heretic/new_heretic = IS_HERETIC(chosen_candidate)

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

/datum/dynamic_ruleset/midround/living/obsessed
	name = "Obsessed"
	severity = DYNAMIC_MIDROUND_LIGHT
	antag_datum = /datum/antagonist/obsessed
	role_preference = /datum/role_preference/midround_living/obsessed
	points_cost = 20

/datum/dynamic_ruleset/midround/living/obsessed/get_poll_icon()
	return icon('icons/obj/clothing/masks.dmi', icon_state = "mad_mask")

/datum/dynamic_ruleset/midround/living/obsessed/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Already obsessed?
		if(candidate.mind.has_antag_datum(/datum/antagonist/obsessed))
			candidates -= candidate
			continue


/datum/dynamic_ruleset/midround/living/obsessed/execute()
	. = ..()
	for(var/mob/chosen_candidate in chosen_candidates)
		var/mob/living/carbon/human/human_target = chosen_candidate
		human_target.gain_trauma(/datum/brain_trauma/special/obsessed)
