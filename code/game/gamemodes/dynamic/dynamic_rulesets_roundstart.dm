// TODO: scale team antagonists with get_antag_cap()

/datum/dynamic_ruleset/roundstart
	rule_category = DYNAMIC_ROUNDSTART
	use_antag_reputation = TRUE

//////////////////////////////////////////////
//                                          //
//               TRAITOR	                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitor"
	role_preference = /datum/role_preference/antagonist/traitor
	antag_datum = /datum/antagonist/traitor
	banned_roles = list(JOB_NAME_CYBORG)
	weight = 5
	points_cost = 5

//////////////////////////////////////////////
//                                          //
//               CHANGELING	                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changeling"
	role_preference = /datum/role_preference/antagonist/changeling
	antag_datum = /datum/antagonist/changeling
	weight = 4
	points_cost = 5

//////////////////////////////////////////////
//                                          //
//                HERETIC	                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/heretic
	name = "Heretic"
	role_preference = /datum/role_preference/antagonist/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 4
	points_cost = 5

//////////////////////////////////////////////
//                                          //
//                WIZARD                    //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	role_preference = /datum/role_preference/antagonist/wizard
	antag_datum = /datum/antagonist/wizard
	weight = 2
	points_cost = 15
	flags = HIGH_IMPACT_RULESET

/datum/dynamic_ruleset/roundstart/wizard/allowed()
	. = ..()
	if(!length(GLOB.wizardstart))
		var/msg = "Cannot accept Wizard ruleset. Couldn't find any wizard spawn points."
		log_admin(msg)
		message_admins(msg)
		return FALSE

/datum/dynamic_ruleset/roundstart/wizard/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_minds)
		chosen_mind.current.forceMove(pick(GLOB.wizardstart))

//////////////////////////////////////////
//                                      //
//           BLOOD BROTHERS             //
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/brothers
	name = "Blood Brothers"
	role_preference = /datum/role_preference/antagonist/blood_brother
	antag_datum = /datum/antagonist/brother
	drafted_players_amount = 2
	weight = 2
	points_cost = 8

	var/datum/team/brother_team/team

/datum/dynamic_ruleset/roundstart/brothers/pre_execute()
	. = ..()
	team = new
	for(var/datum/mind/chosen_mind in chosen_minds)
		team.add_member(chosen_mind)
		GLOB.pre_setup_antags -= chosen_mind

/datum/dynamic_ruleset/roundstart/brothers/execute()
	team.pick_meeting_area()
	team.forge_brother_objectives()
	. = ..()
	team.update_name()

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	role_preference = /datum/role_preference/antagonist/blood_cultist
	antag_datum = /datum/antagonist/cult
	banned_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 2
	weight = 3
	points_cost = 20
	minimum_points_required = 24
	flags = HIGH_IMPACT_RULESET

	var/datum/team/cult/team

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	team = new
	for(var/datum/mind/chosen_mind in chosen_minds)
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
//               CLOCKCULT                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/clockcult
	name = "Clockwork Cult"
	role_preference = /datum/role_preference/antagonist/clock_cultist
	antag_datum = /datum/antagonist/servant_of_ratvar
	banned_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 4
	weight = 3
	points_cost = 35
	minimum_points_required = 24
	flags = HIGH_IMPACT_RULESET

	var/datum/team/clock_cult/main_cult

/datum/dynamic_ruleset/roundstart/clockcult/pre_execute()
	LoadReebe()
	. = ..()
	generate_clockcult_scriptures()

/datum/dynamic_ruleset/roundstart/clockcult/execute(forced = FALSE)
	main_cult = new

	for(var/datum/mind/chosen_mind in chosen_minds)
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
//          NUCLEAR OPERATIVES              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	role_preference = /datum/role_preference/antagonist/nuclear_operative
	antag_datum = /datum/antagonist/nukeop
	drafted_players_amount = 3
	weight = 3
	points_cost = 20
	flags = HIGH_IMPACT_RULESET

	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	var/datum/team/nuclear/nuke_team

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/leader = TRUE
	for(var/datum/mind/chosen_mind in chosen_minds)
		if(leader)
			leader = FALSE
			var/datum/antagonist/nukeop/leader/leader_datum = chosen_mind.add_antag_datum(antag_leader_datum)
			leader_datum = leader_datum.nuke_team
		else
			chosen_mind.add_antag_datum(antag_datum)

		GLOB.pre_setup_antags -= chosen_mind

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/nuclear/round_result()
	var result = nuke_team.get_result()
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

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops/pre_execute()
	. = ..()
	for(var/obj/machinery/nuclearbomb/syndicate/nuke in GLOB.nuke_list)
		var/turf/turf = get_turf(nuke)
		if(turf)
			qdel(nuke)
			new /obj/machinery/nuclearbomb/syndicate/bananium(turf)

//////////////////////////////////////////////
//                                          //
//               REVOLUTION		            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revolution
	name = "Revolution"
	role_preference = /datum/role_preference/antagonist/revolutionary
	antag_datum = /datum/antagonist/rev/head
	banned_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	drafted_players_amount = 3
	weight = 3
	points_cost = 20
	minimum_points_required = 35
	flags = HIGH_IMPACT_RULESET

	var/datum/team/revolution/team
	var/finished = FALSE

/datum/dynamic_ruleset/roundstart/revolution/execute(forced = FALSE)
	team = new
	for(var/datum/mind/chosen_mind in chosen_minds)
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

/datum/dynamic_ruleset/roundstart/revolution/round_result()
	revolution.round_result(finished)

//////////////////////////////////////////////
//                                          //
//                INCURSION                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/incursion
	name = "Incursion"
	role_preference = /datum/role_preference/antagonist/incursionist
	antag_datum = /datum/antagonist/incursion
	drafted_players_amount = 2
	weight = 3
	points_cost = 20
	flags = HIGH_IMPACT_RULESET
	minimum_points_required = 22
	var/datum/team/incursion/incursion_team

/datum/dynamic_ruleset/roundstart/incursion/ready(population, forced = FALSE)
	drafted_players_amount = clamp(get_antag_cap(population), CONFIG_GET(number/incursion_count_min), CONFIG_GET(number/incursion_count_max))
	return ..()

/datum/dynamic_ruleset/roundstart/incursion/execute(forced = FALSE)
	incursion_team = new
	incursion_team.forge_team_objectives(banned_roles)
	for(var/datum/mind/chosen_mind in chosen_minds)
		var/datum/antagonist/incursion/new_incursionist = new antag_datum()

		new_incursionist.team = incursion_team
		incursion_team.add_member(chosen_mind)
		chosen_mind.add_antag_datum(new_incursionist)
		GLOB.pre_setup_antags -= chosen_mind
	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/roundstart/incursion/round_result()
	..()
	if(incursion_team.check_incursion_victory())
		SSticker.mode_result = "win - incursion win"
	else
		SSticker.mode_result = "loss - staff stopped the incursion"
