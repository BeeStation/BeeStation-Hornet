/datum/dynamic_ruleset/gamemode
	rule_category = DYNAMIC_CATEGORY_GAMEMODE
	// Uses antag rep to pick candidates, as we choose from everyone available.
	ruleset_flags = SHOULD_USE_ANTAG_REP
	abstract_type = /datum/dynamic_ruleset/gamemode
	// Sorry, but if you are going to be THE antagonist, you can't be leaving the station and making
	// the round boring for everyone else.
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_PRISONER, JOB_NAME_SHAFTMINER, JOB_NAME_EXPLORATIONCREW)
	/// Default minimum players required so that there is some mystery involved.
	/// Disabled for now, since traitor works fine on 0 pop
	minimum_players_required = 3
	/// The number of rounds that it takes before this gamemode reaches full weight after it has been executed.
	/// The first round after execution will use a weight of 1 (still possible but rare).
	/// A value of 1 means that it will instantly recover
	/// A value of 2 means that the next round after it executes, it will have half weight and after that it
	/// will have full weight.
	var/recent_weight_recovery_linear = 4

/datum/dynamic_ruleset/gamemode/get_weight()
	if (recent_weight_recovery_linear <= 1)
		return weight
	var/list/gamemode_data = SSpersistence.get_gamemode_data()
	var/rounds_since_execution = gamemode_data["[type]"]
	// No data available (never executed)
	if (rounds_since_execution <= 0)
		return weight
	// Calculate the proportion
	var/proportion = CLAMP01((rounds_since_execution - 1) / recent_weight_recovery_linear)
	// Linear interpolation between 1 and the original weight based on time since last execution
	var/used_weight = 1 + (weight - 1) * proportion
	if (weight != used_weight)
		log_dynamic("DYNAMIC: Ruleset [type] is using a weight of [used_weight] instead of [weight] as it executed [rounds_since_execution] rounds ago and takes [recent_weight_recovery_linear] rounds to fully recover.")
	return used_weight

/datum/dynamic_ruleset/gamemode/convert_ruleset()
	removed = TRUE
	log_dynamic("CONVERSION: [name] was removed from the round, it has been marked as removed.")

/datum/dynamic_ruleset/gamemode/get_candidates()
	candidates = SSdynamic.roundstart_candidates.Copy()

/datum/dynamic_ruleset/gamemode/trim_candidates()
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

		// Compatible job?
		if(candidate.mind.assigned_role && (candidate.mind.assigned_role in restricted_roles))
			candidates -= candidate
			continue

/**
 * Choose candidates, if your ruleset makes them a non-crewmember, set their assigned role here.
 */
/datum/dynamic_ruleset/gamemode/proc/choose_candidates()
	for(var/i = 1 to drafted_players_amount)
		var/mob/chosen_candidate = select_player()
		var/datum/mind/chosen_mind = chosen_candidate.mind

		GLOB.pre_setup_antags += chosen_mind
		LAZYADD(chosen_candidates, chosen_mind)

		chosen_mind.special_role = initial(antag_datum.banning_key)
		chosen_mind.restricted_roles = restricted_roles

/datum/dynamic_ruleset/gamemode/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		GLOB.pre_setup_antags -= chosen_mind

/datum/dynamic_ruleset/gamemode/proc/security_report()
	return null

//////////////////////////////////////////////
//                                          //
//                  TRAITOR                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/traitor
	name = "Traitor"
	role_preference = /datum/role_preference/roundstart/traitor
	antag_datum = /datum/antagonist/traitor
	weight = 16
	recent_weight_recovery_linear = 1

/datum/dynamic_ruleset/gamemode/traitor/security_report()
	return "Intercepted communications between neighboring orbital stations suggest that Syndicate activity, as always, remains a potential threat."

//////////////////////////////////////////////
//                                          //
//                CHANGELING                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/changeling
	name = "Changeling"
	role_preference = /datum/role_preference/roundstart/changeling
	antag_datum = /datum/antagonist/changeling
	weight = 8
	ruleset_flags = SHOULD_USE_ANTAG_REP | REQUIRED_POP_ALLOW_UNREADY
	minimum_players_required = 8

/datum/dynamic_ruleset/gamemode/changeling/security_report()
	return "Private research teams have recently been researching lifeforms of unknown origin, capable of controlling their bodies at a cellular level. \
	Unconfirmed reports suggest a tangible risk of impersonation and infiltration for the purposes of their species' hunting cycle."

//////////////////////////////////////////////
//                                          //
//                  HERETIC                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/heretic
	name = "Heretic"
	role_preference = /datum/role_preference/roundstart/heretic
	antag_datum = /datum/antagonist/heretic
	weight = 8
	ruleset_flags = SHOULD_USE_ANTAG_REP | REQUIRED_POP_ALLOW_UNREADY
	minimum_players_required = 14

/datum/dynamic_ruleset/gamemode/heretic/security_report()
	return "Independent theological organizations have long expressed interest in this region of space for reasons that remain unclear. \
	Individuals with confirmed or suspected thaumaturgical expertise may constitute a potential security liability, \
	regardless of the current inconclusiveness of their findings."

//////////////////////////////////////////////
//                                          //
//             MALFUNCTIONING AI            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/malf
	name = "Malfunctioning AI"
	role_preference = /datum/role_preference/roundstart/malfunctioning_ai
	antag_datum = /datum/antagonist/malf_ai
	weight = 8
	minimum_players_required = 20
	restricted_roles = list(JOB_NAME_CYBORG)
	ruleset_flags = SHOULD_USE_ANTAG_REP | CANNOT_REPEAT | REQUIRED_POP_ALLOW_UNREADY

/datum/dynamic_ruleset/gamemode/malf/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		SSjob.AssignRole(chosen_mind.current, JOB_NAME_AI)

/datum/dynamic_ruleset/gamemode/malf/security_report()
	return "The proximity to multiple stars leads to a risk of ion storms born from constructive wave interference. This has been identified \
	as an unconfirmed future risk towards various computer-controlled systems, including artificial-intelligence units and power supply technologies."

//////////////////////////////////////////////
//                                          //
//                  WIZARD                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/wizard
	name = "Wizard"
	role_preference = /datum/role_preference/roundstart/wizard
	antag_datum = /datum/antagonist/wizard
	weight = 8
	minimum_players_required = 20
	ruleset_flags = HIGH_IMPACT_RULESET | NO_OTHER_RULESETS | IS_OBVIOUS_RULESET | NO_LATE_JOIN | NO_CONVERSION_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY

/datum/dynamic_ruleset/gamemode/wizard/allowed(require_drafted = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(!length(GLOB.wizardstart))
		log_dynamic("NOT ALLOWED: [src] couldn't find any spawn points.")
		return FALSE

/datum/dynamic_ruleset/gamemode/wizard/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/gamemode/wizard/execute()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.current.forceMove(pick(GLOB.wizardstart))
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/gamemode/wizard/security_report()
	return "Unconfirmed rumours suggest that a series of powerful artifacts that possess intricate control over space-time are in the hands \
	of an independant organisation. While these reports currently lack credibility, the probability of incident has yet to be determined as \
	negligable and security should utilise this possibility as a training excercise."

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/bloodcult
	name = "Blood Cult"
	role_preference = /datum/role_preference/roundstart/blood_cultist
	antag_datum = /datum/antagonist/cult
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 2
	weight = 8
	minimum_players_required = 24
	ruleset_flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS | NO_LATE_JOIN | NO_CONVERSION_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY
	blocking_rulesets = list(
		/datum/dynamic_ruleset/gamemode/clockcult,
	)

	var/datum/team/cult/team

/datum/dynamic_ruleset/gamemode/bloodcult/set_drafted_players_amount()
	drafted_players_amount = max(CEILING(length(SSdynamic.roundstart_candidates) / 9, 1), 2)

/datum/dynamic_ruleset/gamemode/bloodcult/execute()
	team = new
	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/cult/cultist_datum = new antag_datum()

		cultist_datum.cult_team = team
		cultist_datum.give_equipment = TRUE

		chosen_mind.add_antag_datum(cultist_datum, ruleset = src)
		GLOB.pre_setup_antags -= chosen_mind

	team.setup_objectives()
	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/gamemode/bloodcult/round_result()
	if(team.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

/datum/dynamic_ruleset/gamemode/bloodcult/security_report()
	return "Although numerous fringe theological groups are under observation, one faction has shown increased operational boldness, \
	culminating in several recorded attacks on civilian facilities. The group's capacity for further disruption cannot be dismissed; \
	persistent monitoring of relevant sectors is advised."

//////////////////////////////////////////////
//                                          //
//                CLOCK CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/clockcult
	name = "Clockwork Cult"
	role_preference = /datum/role_preference/roundstart/clock_cultist
	antag_datum = /datum/antagonist/servant_of_ratvar
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	drafted_players_amount = 4
	weight = 8
	minimum_players_required = 30
	ruleset_flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS | IS_OBVIOUS_RULESET | NO_LATE_JOIN | NO_CONVERSION_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY
	blocking_rulesets = list(
		/datum/dynamic_ruleset/gamemode/bloodcult,
	)

	var/datum/team/clock_cult/main_cult

/datum/dynamic_ruleset/roundstart/clockcult/set_drafted_players_amount()
	drafted_players_amount = max(CEILING(length(SSdynamic.roundstart_candidates) / 7, 1), 3)

/datum/dynamic_ruleset/gamemode/clockcult/choose_candidates()
	. = ..()
	load_reebe()
	generate_clockcult_scriptures()

	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/gamemode/clockcult/execute()
	main_cult = new()

	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/servant_of_ratvar/servant_datum = add_servant_of_ratvar(chosen_mind.current, team = main_cult)
		servant_datum.equip_carbon(chosen_mind.current)
		servant_datum.equip_servant()
		servant_datum.prefix = CLOCKCULT_PREFIX_MASTER

		// Blind them while Reebe loads, cleared by teleport_all_servants_to_reebe()
		chosen_mind.current.overlay_fullscreen("reebe_loading", /atom/movable/screen/fullscreen/flash/black)

		GLOB.pre_setup_antags -= chosen_mind

	// If Reebe is somehow loaded, we might as well go ahead and move our servants there
	if(length(GLOB.servant_spawns))
		teleport_all_servants_to_reebe()

	main_cult.setup_objectives()

	calculate_clockcult_values()
	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/gamemode/clockcult/round_result()
	if(GLOB.ratvar_risen)
		SSticker.news_report = CLOCK_SUMMON
		SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
	else
		SSticker.news_report = CULT_FAILURE
		SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"

/datum/dynamic_ruleset/gamemode/clockcult/security_report()
	return "A group yielding unprecedented theological methodologies involving machine logic and dimensional interfaces has been linked to several abductions. \
	The operational intent remains unclear, but potential applications present a non-trivial security concern. Crew safety monitoring is recommended."

//////////////////////////////////////////////
//                                          //
//            NUCLEAR OPERATIVES            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/nuclear
	name = "Nuclear Operatives"
	role_preference = /datum/role_preference/roundstart/nuclear_operative
	antag_datum = /datum/antagonist/nukeop
	drafted_players_amount = 3
	weight = 8
	minimum_players_required = 24
	ruleset_flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS | IS_OBVIOUS_RULESET | NO_LATE_JOIN | REQUIRED_POP_ALLOW_UNREADY

	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	var/datum/team/nuclear/nuke_team

/datum/dynamic_ruleset/gamemode/nuclear/set_drafted_players_amount()
	drafted_players_amount = max(FLOOR(length(SSdynamic.roundstart_candidates) / 7, 1), 2)

/datum/dynamic_ruleset/gamemode/nuclear/choose_candidates()
	. = ..()
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.assigned_role = initial(antag_datum.banning_key)

/datum/dynamic_ruleset/gamemode/nuclear/execute()
	var/has_made_leader = FALSE
	for(var/datum/mind/chosen_mind in chosen_candidates)
		if(!has_made_leader)
			has_made_leader = TRUE
			var/datum/antagonist/nukeop/leader/leader_datum = chosen_mind.add_antag_datum(antag_leader_datum, ruleset = src)
			nuke_team = leader_datum.nuke_team
		else
			chosen_mind.add_antag_datum(antag_datum, ruleset = src)

		GLOB.pre_setup_antags -= chosen_mind

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/gamemode/nuclear/round_result()
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


/datum/dynamic_ruleset/gamemode/nuclear/security_report()
	return "During construction of a nearby station, a well-armed and well-funded Syndicate faction intercepted a shipment containing the station's \
	nuclear self-destruct system. Intelligence assessments indicate a credible risk of future terrorist activity with the objective of total target \
	destruction. Heightened security protocols are recommended."

//////////////////////////////////////////////
//                                          //
//             CLOWN OPERATIVES             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/nuclear/clown_ops
	name = "Clown Operatives"
	antag_datum = /datum/antagonist/nukeop/clownop
	antag_leader_datum = /datum/antagonist/nukeop/leader/clownop
	weight = 0

/datum/dynamic_ruleset/gamemode/nuclear/clown_ops/execute()
	. = ..()
	for(var/obj/machinery/nuclearbomb/syndicate/nuke in GLOB.nuke_list)
		var/turf/turf = get_turf(nuke)
		if(turf)
			var/obj/machinery/nuclearbomb/syndicate/bananium/new_nuke = new(turf)
			new_nuke.r_code = nuke.r_code
			qdel(nuke)

/datum/dynamic_ruleset/gamemode/nuclear/clown_ops/security_report()
	return "During construction of a nearby circus, a well-armed and well-funded Clown faction intercepted a shipment containing the station's \
	prank system. Intelligence assessments indicate a credible risk of future pranks with the objective of total target \
	pranking. Looser security protocols are not recommended."

//////////////////////////////////////////////
//                                          //
//                REVOLUTION                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/gamemode/revolution
	name = "Revolution"
	role_preference = /datum/role_preference/roundstart/revolutionary
	antag_datum = /datum/antagonist/rev/head
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	drafted_players_amount = 3
	weight = 0	// Temporarily disabled: We need to refactor this so that it executes after round-start, and rolls into a different gamemode if it fails to execute.
	minimum_players_required = 24
	ruleset_flags = SHOULD_USE_ANTAG_REP | HIGH_IMPACT_RULESET | NO_OTHER_RULESETS | IS_OBVIOUS_RULESET | NO_CONVERSION_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY

	var/datum/team/revolution/team
	var/finished = FALSE

/datum/dynamic_ruleset/gamemode/revolution/set_drafted_players_amount()
	drafted_players_amount = ROUND_UP(length(GLOB.player_list) / 15)

/datum/dynamic_ruleset/gamemode/revolution/execute()
	team = new
	for(var/datum/mind/chosen_mind in chosen_candidates)
		var/datum/antagonist/rev/head/headrev_datum = new antag_datum()
		headrev_datum.give_flash = TRUE
		headrev_datum.give_hud = TRUE
		headrev_datum.remove_clumsy = TRUE

		chosen_mind.add_antag_datum(headrev_datum, team, ruleset = src)
		GLOB.pre_setup_antags -= chosen_mind

	team.update_objectives()
	team.update_heads()

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/gamemode/revolution/rule_process()
	var/winner = team.process_victory()
	if(isnull(winner))
		return

	finished = winner
	return RULESET_STOP_PROCESSING

#define REVOLUTION_VICTORY 1
#define STATION_VICTORY 2

/datum/dynamic_ruleset/gamemode/revolution/round_result()
	if(finished == REVOLUTION_VICTORY)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if (finished == STATION_VICTORY)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE
	else
		SSticker.mode_result = "minor win - station forced to be abandoned"
		SSticker.news_report = STATION_EVACUATED

/datum/dynamic_ruleset/gamemode/revolution/security_report()
	return "Following an industrial incident on Tellune, violent demonstrations demanding unsanctioned worker concessions occurred outside a \
	Nanotrasen command center. The potential emergence of imitator movements with revolutionary intent presents a credible short-term security \
	concern and should be monitored."

#undef REVOLUTION_VICTORY
#undef STATION_VICTORY
