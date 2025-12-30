/datum/dynamic_ruleset/latejoin
	rule_category = DYNAMIC_CATEGORY_LATEJOIN
	abstract_type = /datum/dynamic_ruleset/latejoin

/datum/dynamic_ruleset/latejoin/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Don't give antag to security officers and other restricted roles
		if(candidate.mind.assigned_role in restricted_roles)
			candidates -= candidate

/datum/dynamic_ruleset/latejoin/execute()
	trim_candidates()
	if(!allowed())
		return DYNAMIC_EXECUTE_FAILURE

	LAZYADD(chosen_candidates, select_player())
	for(var/mob/chosen_candidate in chosen_candidates)
		chosen_candidate.mind.special_role = antag_datum.banning_key
	return ..()

//////////////////////////////////////////////
//                                          //
//           SYNDICATE INFILTRATOR          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/traitor
	name = "Syndicate Infiltrator"
	role_preference = /datum/role_preference/latejoin/traitor
	antag_datum = /datum/antagonist/traitor
	weight = 7

//////////////////////////////////////////////
//                                          //
//            CHANGELING STOWAWAY           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changeling Stowaway"
	role_preference = /datum/role_preference/latejoin/changeling
	antag_datum = /datum/antagonist/changeling
	weight = 4

//////////////////////////////////////////////
//                                          //
//             HERETIC SMUGGLER             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/heretic
	name = "Heretic Smuggler"
	role_preference = /datum/role_preference/latejoin/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 4

/datum/dynamic_ruleset/latejoin/heretic/execute()
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
//             VAMPIRE BREAKOUT             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/vampire
	name = "Vampire Breakout"
	role_preference = /datum/role_preference/latejoin/vampire
	antag_datum = /datum/antagonist/vampire
	weight = 4
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_CURATOR)

/datum/dynamic_ruleset/latejoin/vampire/execute()
	. = ..()
	for(var/mob/chosen_candidate in chosen_candidates)
		var/datum/antagonist/vampire/new_vampire = IS_VAMPIRE(chosen_candidate)
		new_vampire.vampire_level_unspent = rand(2,3)
