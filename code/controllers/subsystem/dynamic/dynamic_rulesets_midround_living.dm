/datum/dynamic_ruleset/midround/living
	abstract_type = /datum/dynamic_ruleset/midround/living

	/// Whether or not ghost roles are allowed to roll this ruleset (Ashwalkers, Golems, Drones, etc.)
	var/allow_ghost_roles = FALSE
	/// What mob type the ruleset is restricted to.
	var/mob_type = /mob/living/carbon/human

/datum/dynamic_ruleset/midround/living/get_candidates()
	candidates = SSdynamic.current_players[CURRENT_LIVING_PLAYERS].Copy()

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

		// Already assigned antag?
		if(candidate.mind.special_role)
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
		LAZYADD(chosen_candidates, select_player())

	// See if they actually want to play this role
	var/previous_chosen_candidates = length(chosen_candidates)
	var/datum/poll_config/config = new()
	config.role_name_text = name
	config.poll_time = 30 SECONDS
	config.alert_pic = get_poll_icon()
	chosen_candidates = SSpolling.poll_candidates(config, chosen_candidates)

	if(!length(chosen_candidates))
		message_admins("DYNAMIC: [previous_chosen_candidates] player\s [previous_chosen_candidates > 0 ? "were" : "was"] selected for [src], but none of them wanted to play it.")
		log_dynamic("NOT ALLOWED: [previous_chosen_candidates] player\s [previous_chosen_candidates > 0 ? "were" : "was"] selected for [src], but none of them wanted to play it.")
		return DYNAMIC_EXECUTE_FAILURE

	for(var/mob/chosen_candidate in chosen_candidates)
		chosen_candidate.mind.special_role = antag_datum.banning_key
	return ..()

//////////////////////////////////////////////
//                                          //
//         VALUE DRIFTED AI (MEDIUM)        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/value_drifted
	name = "Value Drifted AI"
	severity = DYNAMIC_MIDROUND_MEDIUM
	restricted_roles = list(JOB_NAME_CYBORG, JOB_NAME_POSIBRAIN)
	role_preference = /datum/role_preference/midround/malfunctioning_ai
	antag_datum = /datum/antagonist/malf_ai
	weight = 3
	points_cost = 40
	minimum_players_required = 24
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
	role_preference = /datum/role_preference/midround/traitor
	antag_datum = /datum/antagonist/traitor
	weight = 7
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
	role_preference = /datum/role_preference/midround/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 7
	points_cost = 30

/datum/dynamic_ruleset/midround/living/heretic/get_poll_icon()
	return /obj/item/codex_cicatrix

/datum/dynamic_ruleset/midround/living/heretic/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// CLANKERS GO HOME (github copilot comment)
		if(isipc(candidate))
			candidates -= candidate
			continue

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
//             VAMPIRE (LIGHT)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/vampire
	name = "Vampiric Accident"
	severity = DYNAMIC_MIDROUND_LIGHT
	role_preference = /datum/role_preference/midround/vampire
	antag_datum = /datum/antagonist/vampire
	weight = 7
	points_cost = 30
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_CURATOR)

/datum/dynamic_ruleset/midround/living/vampire/trim_candidates()
	. = ..()
	for(var/mob/living/carbon/candidate in candidates)
		// Don't draft incompatible species
		if(HAS_TRAIT(candidate, TRAIT_NOT_TRANSMORPHIC))
			candidates -= candidate
			continue

/datum/dynamic_ruleset/midround/living/vampire/get_poll_icon()
	return icon('icons/vampires/actions_vampire.dmi', icon_state = "power_feed")

/datum/dynamic_ruleset/midround/living/vampire/execute()
	. = ..()
	for(var/mob/chosen_candidate in chosen_candidates)
		var/datum/antagonist/vampire/new_vampire = IS_VAMPIRE(chosen_candidate)
		new_vampire.vampire_level_unspent = rand(2,3)

//////////////////////////////////////////////
//                                          //
//             OBSESSED (LIGHT)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/living/obsessed
	name = "Obsessed"
	severity = DYNAMIC_MIDROUND_LIGHT | DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/obsessed
	role_preference = /datum/role_preference/midround/obsessed
	weight = 6
	points_cost = 20

/datum/dynamic_ruleset/midround/living/obsessed/get_poll_icon()
	return icon('icons/obj/clothing/masks.dmi', icon_state = "mad_mask")

/// Obsessed are special little cupcakes that require snowflake code
/datum/dynamic_ruleset/midround/living/obsessed/trim_candidates()
	SHOULD_CALL_PARENT(FALSE)
	for(var/mob/candidate in candidates)
		// Connected?
		if(!candidate.client)
			candidates -= candidate
			continue

		// Antag banned?
		// Antag disabled?
		// Enough hours?
#ifndef TESTING_DYNAMIC
		if(!candidate.client.should_include_for_role(
			banning_key = antag_datum.banning_key,
			role_preference_key = role_preference,
			req_hours = antag_datum.required_living_playtime
		))
			candidates -= candidate
			continue
#endif

		// Correct mob type?
		if(!istype(candidate, mob_type))
			candidates -= candidate
			continue

		// Ghost role?
		if(!allow_ghost_roles && (candidate.mind?.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL]))
			candidates -= candidate
			continue

		// Already obsessed?
		if(candidate.mind.has_antag_datum(/datum/antagonist/obsessed))
			candidates -= candidate
			continue

/datum/dynamic_ruleset/midround/living/obsessed/execute()
	SHOULD_CALL_PARENT(FALSE)
	// Get our candidates
	set_drafted_players_amount()
	get_candidates()
	trim_candidates()

	if(!allowed())
		return DYNAMIC_EXECUTE_FAILURE

	// Select candidates
	for(var/i = 1 to drafted_players_amount)
		LAZYADD(chosen_candidates, select_player())

	// See if they actually want to play this role
	var/previous_chosen_candidates = length(chosen_candidates)
	var/datum/poll_config/config = new
	config.poll_time = 30 SECONDS
	config.role_name_text = name
	config.alert_pic = get_poll_icon()
	chosen_candidates = SSpolling.poll_candidates(config, chosen_candidates)

	if(!length(chosen_candidates))
		message_admins("DYNAMIC: [previous_chosen_candidates] player\s [previous_chosen_candidates > 0 ? "were" : "was"] selected for [src], but none of them wanted to play it.")
		log_dynamic("NOT ALLOWED: [previous_chosen_candidates] player\s [previous_chosen_candidates > 0 ? "were" : "was"] selected for [src], but none of them wanted to play it.")
		return DYNAMIC_EXECUTE_FAILURE

	for(var/mob/living/carbon/human/chosen_candidate in chosen_candidates)
		chosen_candidate.gain_trauma(/datum/brain_trauma/special/obsessed)

	return DYNAMIC_EXECUTE_SUCCESS
