/datum/dynamic_ruleset/roundstart
	rule_category = DYNAMIC_CATEGORY_ROUNDSTART
	ruleset_flags = SHOULD_USE_ANTAG_REP
	abstract_type = /datum/dynamic_ruleset/roundstart
	/// The percentage (0 to 100) chance that this ruleset will be repicked
	/// when selected, assuming there are cost points available.
	var/elasticity = 0

/datum/dynamic_ruleset/roundstart/get_candidates()
	candidates = SSdynamic.roundstart_candidates.Copy()

/datum/dynamic_ruleset/roundstart/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// "Connected"?
		if(!candidate.mind)
			candidates -= candidate
			continue

		// Already an antag?
		if(candidate.mind.special_role)
			candidates -= candidate
			continue

/**
 * Choose candidates, if your ruleset makes them a non-crewmember, set their assigned role here.
 */
/datum/dynamic_ruleset/roundstart/proc/choose_candidates()
	for(var/i = 1 to drafted_players_amount)
		var/mob/chosen_candidate = select_player()
		var/datum/mind/chosen_mind = chosen_candidate.mind

		GLOB.pre_setup_antags += chosen_mind
		LAZYADD(chosen_candidates, chosen_mind)

		chosen_mind.special_role = initial(antag_datum.banning_key)
		chosen_mind.restricted_roles = restricted_roles

/datum/dynamic_ruleset/roundstart/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		GLOB.pre_setup_antags -= chosen_mind

//////////////////////////////////////////
//                                      //
//            BLOOD BROTHERS            //
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/brothers
	name = "Blood Brothers"
	role_preference = /datum/role_preference/roundstart/blood_brother
	antag_datum = /datum/antagonist/brother
	drafted_players_amount = 2
	weight = 6
	points_cost = 8

	var/datum/team/brother_team/team

/datum/dynamic_ruleset/roundstart/brothers/choose_candidates()
	. = ..()
	team = new()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		team.add_member(chosen_mind)

/datum/dynamic_ruleset/roundstart/brothers/execute()
	team.pick_meeting_area()
	team.forge_brother_objectives()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.add_antag_datum(antag_datum, team)
		GLOB.pre_setup_antags -= chosen_mind

	team.update_name()
	return DYNAMIC_EXECUTE_SUCCESS
