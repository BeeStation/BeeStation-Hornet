/datum/dynamic_ruleset/latejoin
	rule_category = DYNAMIC_CATEGORY_LATEJOIN

/datum/dynamic_ruleset/latejoin/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Don't give antag to security officers and other restricted roles
		if(candidate.mind.assigned_role in restricted_roles)
			candidates -= candidate

/datum/dynamic_ruleset/latejoin/execute()
	chosen_candidates += select_player()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.special_role = antag_datum.banning_key
	. = ..()

//////////////////////////////////////////////
//                                          //
//           SYNDICATE INFILTRATOR          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	role_preference = /datum/role_preference/antagonist/traitor
	antag_datum = /datum/antagonist/traitor
	weight = 7

//////////////////////////////////////////////
//                                          //
//            CHANGELING STOWAWAY           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/changeling_stowaway
	name = "Changeling Stowaway"
	role_preference = /datum/role_preference/antagonist/changeling
	antag_datum = /datum/antagonist/changeling
	weight = 4

//////////////////////////////////////////////
//                                          //
//             HERETIC SMUGGLER             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/heretic_smuggler
	name = "Heretic Smuggler"
	role_preference = /datum/role_preference/antagonist/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 4

/datum/dynamic_ruleset/latejoin/heretic_smuggler/execute()
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
