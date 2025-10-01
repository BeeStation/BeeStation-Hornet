/datum/dynamic_ruleset/roundstart
	rule_category = DYNAMIC_CATEGORY_ROUNDSTART
	flags = SHOULD_USE_ANTAG_REP
	abstract_type = /datum/dynamic_ruleset/roundstart

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

/datum/dynamic_ruleset/roundstart/select_player()
	if(!length(candidates))
		CRASH("[src] called select_player without any candidates!")

	var/mob/selected_player = CHECK_BITFIELD(flags, SHOULD_USE_ANTAG_REP) ? SSdynamic.antag_pick(candidates, role_preference) : pick(candidates)

	if(selected_player)
		candidates -= selected_player
	return selected_player.mind

/**
 * Choose candidates, if your ruleset makes them a non-crewmember, set their assigned role here.
**/
/datum/dynamic_ruleset/roundstart/proc/choose_candidates()
	for(var/i = 1 to drafted_players_amount)
		var/datum/mind/chosen_candidate = select_player()

		GLOB.pre_setup_antags += chosen_candidate
		chosen_candidates += chosen_candidate

		chosen_candidate.special_role = initial(antag_datum.banning_key)
		chosen_candidate.restricted_roles = restricted_roles

/datum/dynamic_ruleset/roundstart/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		GLOB.pre_setup_antags -= chosen_mind

//////////////////////////////////////////////
//                                          //
//                  TRAITOR                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitor"
	role_preference = /datum/role_preference/roundstart/traitor
	antag_datum = /datum/antagonist/traitor
	weight = 10

//////////////////////////////////////////////
//                                          //
//                CHANGELING                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changeling"
	role_preference = /datum/role_preference/roundstart/changeling
	antag_datum = /datum/antagonist/changeling
	weight = 8

//////////////////////////////////////////////
//                                          //
//                  HERETIC                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/heretic
	name = "Heretic"
	role_preference = /datum/role_preference/roundstart/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 8
	minimum_players_required = 13

//////////////////////////////////////////////
//                                          //
//                  VAMPIRE                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampire"
	role_preference = /datum/role_preference/roundstart/vampire
	antag_datum = /datum/antagonist/vampire
	weight = 8
	minimum_players_required = 13
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_CURATOR)

//////////////////////////////////////////////
//                                          //
//             MALFUNCTIONING AI            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/malf
	name = "Malfunctioning AI"
	role_preference = /datum/role_preference/roundstart/malfunctioning_ai
	antag_datum = /datum/antagonist/malf_ai
	weight = 6
	points_cost = 13
	minimum_players_required = 24
	restricted_roles = list(JOB_NAME_CYBORG)
	flags = SHOULD_USE_ANTAG_REP | CANNOT_REPEAT

/datum/dynamic_ruleset/roundstart/malf/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		SSjob.AssignRole(chosen_mind.current, JOB_NAME_AI)

//////////////////////////////////////////////
//                                          //
//                  WIZARD                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	role_preference = /datum/role_preference/roundstart/wizard
	antag_datum = /datum/antagonist/wizard
	weight = 1
	points_cost = 15
	minimum_players_required = 20
	flags = HIGH_IMPACT_RULESET | NO_OTHER_RULESETS

/datum/dynamic_ruleset/roundstart/wizard/allowed()
	. = ..()
	if(!.)
		return FALSE

	if(!length(GLOB.wizardstart))
		log_dynamic("NOT ALLOWED: [src] couldn't find any spawn points.")
		return FALSE

/datum/dynamic_ruleset/roundstart/wizard/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/roundstart/wizard/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.current.forceMove(pick(GLOB.wizardstart))
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

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
	team = new
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

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	role_preference = /datum/role_preference/roundstart/blood_cultist
	antag_datum = /datum/antagonist/cult
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 2
	weight = 5
	points_cost = 20
	minimum_players_required = 30
	flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS
	blocking_rulesets = list(
		/datum/dynamic_ruleset/roundstart/clockcult,
	)

	var/datum/team/cult/team

/datum/dynamic_ruleset/roundstart/bloodcult/set_drafted_players_amount()
	drafted_players_amount = max(FLOOR(length(SSdynamic.roundstart_candidates) / 9, 1), 1)

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	team = new
	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/cult/cultist_datum = new antag_datum()

		cultist_datum.cult_team = team
		cultist_datum.give_equipment = TRUE

		chosen_mind.add_antag_datum(cultist_datum)
		GLOB.pre_setup_antags -= chosen_mind

	team.setup_objectives()
	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/bloodcult/round_result()
	if(team.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

//////////////////////////////////////////////
//                                          //
//                CLOCK CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/clockcult
	name = "Clockwork Cult"
	role_preference = /datum/role_preference/roundstart/clock_cultist
	antag_datum = /datum/antagonist/servant_of_ratvar
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 4
	weight = 5
	points_cost = 35
	minimum_players_required = 35
	flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS
	blocking_rulesets = list(
		/datum/dynamic_ruleset/roundstart/bloodcult,
	)

	var/datum/team/clock_cult/main_cult

/datum/dynamic_ruleset/roundstart/clockcult/set_drafted_players_amount()
	drafted_players_amount = max(FLOOR(length(SSdynamic.roundstart_candidates) / 7, 1), 1)

/datum/dynamic_ruleset/roundstart/clockcult/choose_candidates()
	. = ..()
	LoadReebe()
	generate_clockcult_scriptures()

	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/roundstart/clockcult/execute()
	main_cult = new

	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.current.forceMove(pick_n_take(GLOB.servant_spawns))

		var/datum/antagonist/servant_of_ratvar/servant_datum = add_servant_of_ratvar(chosen_mind.current, team = main_cult)
		servant_datum.equip_carbon(chosen_mind.current)
		servant_datum.equip_servant()
		servant_datum.prefix = CLOCKCULT_PREFIX_MASTER

		GLOB.pre_setup_antags -= chosen_mind

	main_cult.setup_objectives()

	calculate_clockcult_values()
	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/clockcult/round_result()
	if(GLOB.ratvar_risen)
		SSticker.news_report = CLOCK_SUMMON
		SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
	else
		SSticker.news_report = CULT_FAILURE
		SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"

//////////////////////////////////////////////
//                                          //
//            NUCLEAR OPERATIVES            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Operatives"
	role_preference = /datum/role_preference/roundstart/nuclear_operative
	antag_datum = /datum/antagonist/nukeop
	drafted_players_amount = 3
	weight = 3
	points_cost = 20
	minimum_players_required = 28
	flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS

	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	var/datum/team/nuclear/nuke_team

/datum/dynamic_ruleset/roundstart/nuclear/set_drafted_players_amount()
	drafted_players_amount = max(FLOOR(length(SSdynamic.roundstart_candidates) / 7, 1), 1)

/datum/dynamic_ruleset/roundstart/nuclear/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/has_made_leader = FALSE
	for(var/datum/mind/chosen_mind in chosen_candidates)
		if(!has_made_leader)
			has_made_leader = TRUE
			var/datum/antagonist/nukeop/leader/leader_datum = chosen_mind.add_antag_datum(antag_leader_datum)
			nuke_team = leader_datum.nuke_team
		else
			chosen_mind.add_antag_datum(antag_datum)

		GLOB.pre_setup_antags -= chosen_mind

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/nuclear/round_result()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

//////////////////////////////////////////////
//                                          //
//             CLOWN OPERATIVES             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops
	name = "Clown Operatives"
	antag_datum = /datum/antagonist/nukeop/clownop
	antag_leader_datum = /datum/antagonist/nukeop/leader/clownop
	weight = 2

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops/execute()
	. = ..()
	for(var/obj/machinery/nuclearbomb/syndicate/nuke in GLOB.nuke_list)
		var/turf/turf = get_turf(nuke)
		if(turf)
			var/obj/machinery/nuclearbomb/syndicate/bananium/new_nuke = new(turf)
			new_nuke.yes_code = nuke.yes_code
			qdel(nuke)

//////////////////////////////////////////////
//                                          //
//                REVOLUTION                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revolution
	name = "Revolution"
	role_preference = /datum/role_preference/roundstart/revolutionary
	antag_datum = /datum/antagonist/rev/head
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	drafted_players_amount = 3
	weight = 4
	points_cost = 20
	minimum_players_required = 35
	flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS

	var/datum/team/revolution/team
	var/finished = FALSE

/datum/dynamic_ruleset/roundstart/revolution/set_drafted_players_amount()
	drafted_players_amount = ROUND_UP(length(GLOB.player_list) / 15)

/datum/dynamic_ruleset/roundstart/revolution/execute()
	team = new
	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/rev/head/headrev_datum = new antag_datum()
		headrev_datum.give_flash = TRUE
		headrev_datum.give_hud = TRUE
		headrev_datum.remove_clumsy = TRUE

		chosen_mind.add_antag_datum(headrev_datum, team)
		GLOB.pre_setup_antags -= chosen_mind

	team.update_objectives()
	team.update_heads()

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/revolution/rule_process()
	var/winner = team.process_victory()
	if(isnull(winner))
		return

	finished = winner
	return RULESET_STOP_PROCESSING

#define REVOLUTION_VICTORY 1
#define STATION_VICTORY 2

/datum/dynamic_ruleset/roundstart/revolution/round_result()
	if(finished == REVOLUTION_VICTORY)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if (finished == STATION_VICTORY)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE
	else
		SSticker.mode_result = "minor win - station forced to be abandoned"
		SSticker.news_report = STATION_EVACUATED

#undef REVOLUTION_VICTORY
#undef STATION_VICTORY
