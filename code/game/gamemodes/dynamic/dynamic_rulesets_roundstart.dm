
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	minimum_required_age = 0
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 5
	cost = 8	// Avoid raising traitor threat above this, as it is the default low cost ruleset.
	scaling_cost = 9
	requirements = list(8,8,8,8,8,8,8,8,8,8)
	antag_cap = list("denominator" = 38)
	var/autotraitor_cooldown = (15 MINUTES)

/datum/dynamic_ruleset/roundstart/traitor/pre_execute(population)
	. = ..()
	if (population < CONFIG_GET(number/malf_ai_minimum_pop))
		restricted_roles |= JOB_NAME_AI
	var/num_traitors = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_traitors)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_TRAITOR
		M.mind.restricted_roles = restricted_roles
	return TRUE


//////////////////////////////////////////
//                                      //
//           BLOOD BROTHERS             //
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitorbro
	name = "Blood Brothers"
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother/
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 2
	weight = 2
	cost = 12
	scaling_cost = 15
	requirements = list(40,30,30,20,20,15,15,15,10,10)
	antag_cap = 2	// Can pick 3 per team, but rare enough it doesn't matter.
	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/min_team_size = 2

/datum/dynamic_ruleset/roundstart/traitorbro/pre_execute(population)
	. = ..()
	var/num_teams = (get_antag_cap(population)/min_team_size) * (scaled_times + 1) // 1 team per scaling
	for(var/j = 1 to num_teams)
		if(candidates.len < min_team_size || candidates.len < required_candidates)
			break
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, candidates.len) : 2
		for(var/k = 1 to team_size)
			var/mob/bro = pick_n_take(candidates)
			assigned += bro.mind
			team.add_member(bro.mind)
			bro.mind.special_role = "brother"
			bro.mind.restricted_roles = restricted_roles
		pre_brother_teams += team
	return TRUE

/datum/dynamic_ruleset/roundstart/traitorbro/execute()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	mode.brother_teams += pre_brother_teams
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10
	requirements = list(70,70,60,50,40,20,20,10,10,10)
	antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/pre_execute(population)
	. = ..()
	var/num_changelings = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_changelings)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_CHANGELING
	return TRUE

/datum/dynamic_ruleset/roundstart/changeling/execute()
	for(var/datum/mind/changeling in assigned)
		var/datum/antagonist/changeling/new_antag = new antag_datum()
		changeling.add_antag_datum(new_antag)
	return TRUE

//////////////////////////////////////////////
//                                          //
//              ELDRITCH CULT               //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/heretics
	name = "Heretics"
	antag_flag = ROLE_HERETIC
	antag_datum = /datum/antagonist/heretic
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 3
	cost = 15
	scaling_cost = 9
	requirements = list(101,101,101,40,35,20,20,15,10,10)
	antag_cap = list("denominator" = 24)


/datum/dynamic_ruleset/roundstart/heretics/pre_execute(population)
	. = ..()
	var/num_ecult = get_antag_cap(population) * (scaled_times + 1)

	for (var/i = 1 to num_ecult)
		if(candidates.len <= 0)
			break
		var/mob/picked_candidate = pick_n_take(candidates)
		assigned += picked_candidate.mind
		picked_candidate.mind.restricted_roles = restricted_roles
		picked_candidate.mind.special_role = ROLE_HERETIC
	return TRUE

/datum/dynamic_ruleset/roundstart/heretics/execute()

	for(var/c in assigned)
		var/datum/mind/cultie = c
		var/datum/antagonist/heretic/new_antag = new antag_datum()
		cultie.add_antag_datum(new_antag)

	return TRUE


//////////////////////////////////////////////
//                                          //
//               WIZARDS                    //
//                                          //
//////////////////////////////////////////////

// Dynamic is a wonderful thing that adds wizards to every round and then adds even more wizards during the round.
/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	antag_flag = ROLE_WIZARD
	antag_datum = /datum/antagonist/wizard
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET
	minimum_required_age = 14
	restricted_roles = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN) // Just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 1
	weight = 2
	cost = 20
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	var/list/roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/acceptable(population=0, threat=0)
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/pre_execute()
	if(GLOB.wizardstart.len == 0)
		return FALSE
	mode.antags_rolled += 1
	var/mob/M = pick_n_take(candidates)
	if (M)
		assigned += M.mind
		M.mind.assigned_role = ROLE_WIZARD
		M.mind.special_role = ROLE_WIZARD

	return TRUE

/datum/dynamic_ruleset/roundstart/wizard/execute()
	for(var/datum/mind/M in assigned)
		M.current.forceMove(pick(GLOB.wizardstart))
		M.add_antag_datum(new antag_datum())
	return TRUE

//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	antag_flag = ROLE_CULTIST
	antag_datum = /datum/antagonist/cult
	minimum_required_age = 14
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	required_candidates = 2
	weight = 3
	cost = 20
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	minimum_players = 24
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET
	antag_cap = list("denominator" = 20, "offset" = 1)
	var/datum/team/cult/main_cult

/datum/dynamic_ruleset/roundstart/bloodcult/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	return ..()

/datum/dynamic_ruleset/roundstart/bloodcult/pre_execute(population)
	. = ..()
	var/cultists = get_antag_cap(population)
	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_CULTIST
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	main_cult = new
	for(var/datum/mind/M in assigned)
		var/datum/antagonist/cult/new_cultist = new antag_datum()
		new_cultist.cult_team = main_cult
		new_cultist.give_equipment = TRUE
		M.add_antag_datum(new_cultist)
	main_cult.setup_objectives()
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/round_result()
	..()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	minimum_required_age = 14
	restricted_roles = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN) // Just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 5
	weight = 3
	cost = 20
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET
	antag_cap = list("denominator" = 18, "offset" = 1)
	var/datum/team/nuclear/nuke_team

/datum/dynamic_ruleset/roundstart/nuclear/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	return ..()

/datum/dynamic_ruleset/roundstart/nuclear/pre_execute(population)
	. = ..()
	// If ready() did its job, candidates should have 5 or more members in it
	var/operatives = get_antag_cap(population)
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.assigned_role = "Nuclear Operative"
		M.mind.special_role = "Nuclear Operative"
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/leader = TRUE
	for(var/datum/mind/M in assigned)
		if (leader)
			leader = FALSE
			var/datum/antagonist/nukeop/leader/new_op = M.add_antag_datum(antag_leader_datum)
			nuke_team = new_op.nuke_team
		else
			var/datum/antagonist/nukeop/new_op = new antag_datum()
			M.add_antag_datum(new_op)
	return TRUE

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
//               REVS		                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revs
	name = "Revolution"
	persistent = TRUE
	antag_flag = ROLE_REV_HEAD
	antag_flag_override = ROLE_REV
	antag_datum = /datum/antagonist/rev/head
	minimum_required_age = 14
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	required_candidates = 3
	weight = 3
	delay = 7 MINUTES
	cost = 20
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	antag_cap = 3
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET
	blocking_rules = list(/datum/dynamic_ruleset/latejoin/provocateur)
	// I give up, just there should be enough heads with 35 players...
	minimum_players = 35
	/// How much threat should be injected when the revolution wins?
	var/revs_win_threat_injection = 20
	var/datum/team/revolution/revolution
	var/finished = FALSE

/datum/dynamic_ruleset/roundstart/revs/pre_execute(population)
	. = ..()
	var/max_candidates = get_antag_cap(population)
	for(var/i = 1 to max_candidates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = antag_flag
	return TRUE

/datum/dynamic_ruleset/roundstart/revs/execute()
	revolution = new()
	for(var/datum/mind/M in assigned)
		if(check_eligible(M))
			var/datum/antagonist/rev/head/new_head = new antag_datum()
			new_head.give_flash = TRUE
			new_head.give_hud = TRUE
			new_head.remove_clumsy = TRUE
			M.add_antag_datum(new_head,revolution)
		else
			assigned -= M
			log_game("DYNAMIC: [ruletype] [name] discarded [M.name] from head revolutionary due to ineligibility.")
	if(revolution.members.len)
		revolution.update_objectives()
		revolution.update_heads()
		SSshuttle.registerHostileEnvironment(revolution)
		return TRUE
	log_game("DYNAMIC: [ruletype] [name] failed to get any eligible headrevs. Refunding [cost] threat.")
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/clean_up()
	qdel(revolution)
	..()

/datum/dynamic_ruleset/roundstart/revs/rule_process()
	var/winner = revolution.process_victory(revs_win_threat_injection)
	if (isnull(winner))
		return
	finished = winner
	return RULESET_STOP_PROCESSING

/// Checks for revhead loss conditions and other antag datums.
/datum/dynamic_ruleset/roundstart/revs/proc/check_eligible(var/datum/mind/M)
	var/turf/T = get_turf(M.current)
	if(!considered_afk(M) && considered_alive(M) && is_station_level(T.z) && !M.antag_datums?.len && !HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return TRUE
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/round_result()
	revolution.round_result(finished)

// Admin only rulesets. The threat requirement is 101 so it is not possible to roll them.

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	antag_flag = null
	antag_datum = null
	restricted_roles = list()
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET

/datum/dynamic_ruleset/roundstart/extended/pre_execute()
	message_admins("Starting a round of extended.")
	log_game("Starting a round of extended.")
	mode.spend_roundstart_budget(mode.round_start_budget)
	mode.spend_midround_budget(mode.mid_round_budget)
	mode.threat_log += "[worldtime2text()]: Extended ruleset set threat to 0."
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CLOWN OPS                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops
	name = "Clown Ops"
	antag_datum = /datum/antagonist/nukeop/clownop
	antag_leader_datum = /datum/antagonist/nukeop/leader/clownop
	requirements = list(101,101,101,101,101,101,101,101,101,101)

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops/pre_execute()
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				new /obj/machinery/nuclearbomb/syndicate/bananium(T)
		for(var/datum/mind/V in assigned)
			V.assigned_role = "Clown Operative"
			V.special_role = "Clown Operative"

//////////////////////////////////////////////
//                                          //
//               DEVIL                      //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/devil
	name = "Devil"
	antag_flag = ROLE_DEVIL
	antag_datum = /datum/antagonist/devil
	restricted_roles = list(JOB_NAME_LAWYER, JOB_NAME_CURATOR, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE)
	required_candidates = 1
	weight = 3
	cost = 0
	flags = LONE_RULESET
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	antag_cap = list("denominator" = 30)

/datum/dynamic_ruleset/roundstart/devil/pre_execute(population)
	. = ..()
	var/num_devils = get_antag_cap(population) * (scaled_times + 1)

	for(var/j = 0, j < num_devils, j++)
		if (candidates.len <= 0)
			break
		var/mob/devil = pick_n_take(candidates)
		assigned += devil.mind
		devil.mind.special_role = ROLE_DEVIL
		devil.mind.restricted_roles = restricted_roles

		log_game("[key_name(devil)] has been selected as a devil")
	return TRUE

/datum/dynamic_ruleset/roundstart/devil/execute()
	for(var/datum/mind/devil in assigned)
		add_devil(devil.current, ascendable = TRUE)
		add_devil_objectives(devil,2)
	return TRUE

/datum/dynamic_ruleset/roundstart/devil/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	var/datum/antagonist/devil/D = devil_mind.has_antag_datum(/datum/antagonist/devil)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		D.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type
		else
			objective.find_target()
		log_objective(D, objective.explanation_text)

//////////////////////////////////////////////
//                                          //
//               METEOR                     //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/meteor
	name = "Meteor"
	persistent = TRUE
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET
	var/meteordelay = 2000
	var/nometeors = 0
	var/rampupdelta = 5

/datum/dynamic_ruleset/roundstart/meteor/rule_process()
	if(nometeors || meteordelay > world.time - SSticker.round_start_time)
		return

	var/list/wavetype = GLOB.meteors_normal
	var/meteorminutes = (world.time - SSticker.round_start_time - meteordelay) / 10 / 60

	if (prob(meteorminutes))
		wavetype = GLOB.meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = GLOB.meteors_catastrophic

	var/ramp_up_final = CLAMP(round(meteorminutes/rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)

//////////////////////////////////////////////
//                                          //
//               CLOCKCULT                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/clockcult
	name = "Clockwork Cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	antag_datum = /datum/antagonist/servant_of_ratvar
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN, JOB_NAME_HEADOFPERSONNEL)
	required_candidates = 4
	weight = 3
	cost = 35
	requirements = list(100,90,80,70,60,50,30,30,30,30)
	minimum_players = 24
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET
	var/datum/team/clock_cult/main_cult
	var/list/selected_servants = list()

/datum/dynamic_ruleset/roundstart/clockcult/pre_execute()
	//Load Reebe
	LoadReebe()
	//Make cultists
	var/starter_servants = 4
	var/number_players = mode.roundstart_pop_ready
	if(number_players > 30)
		number_players -= 30
		starter_servants += round(number_players / 10)
	starter_servants = min(starter_servants, 8)
	for (var/i in 1 to starter_servants)
		var/mob/servant = pick_n_take(candidates)
		assigned += servant.mind
		servant.mind.assigned_role = ROLE_SERVANT_OF_RATVAR
		servant.mind.special_role = ROLE_SERVANT_OF_RATVAR
	//Generate scriptures
	generate_clockcult_scriptures()
	return TRUE

/datum/dynamic_ruleset/roundstart/clockcult/execute()
	var/list/spawns = GLOB.servant_spawns.Copy()
	main_cult = new
	main_cult.setup_objectives()
	//Create team
	for(var/datum/mind/servant_mind in assigned)
		servant_mind.current.forceMove(pick_n_take(spawns))
		servant_mind.current.set_species(/datum/species/human)
		var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(servant_mind.current, team=main_cult)
		S.equip_carbon(servant_mind.current)
		S.equip_servant()
		S.prefix = CLOCKCULT_PREFIX_MASTER
	//Setup the conversion limits for auto opening the ark
	calculate_clockcult_values()
	return ..()

/datum/dynamic_ruleset/roundstart/clockcult/round_result()
	if(GLOB.ratvar_risen)
		SSticker.news_report = CLOCK_SUMMON
		SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
	else
		SSticker.news_report = CULT_FAILURE
		SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"

//////////////////////////////////////////////
//                                          //
//                INCURSION                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/incursion
	name = "Incursion"
	antag_flag = ROLE_INCURSION
	antag_datum = /datum/antagonist/incursion
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_HEADOFSECURITY, JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFMEDICALOFFICER)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 2
	weight = 3
	cost = 20
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 10, "offset" = 1)
	var/datum/team/incursion/incursion_team

/datum/dynamic_ruleset/roundstart/incursion/ready(population, forced = FALSE)
	required_candidates = CLAMP(get_antag_cap(population), CONFIG_GET(number/incursion_count_min), CONFIG_GET(number/incursion_count_max))
	return ..()

/datum/dynamic_ruleset/roundstart/incursion/pre_execute(population)
	. = ..()
	for(var/x = 1 to required_candidates)
		if(!length(candidates))
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_INCURSION
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/incursion/execute()
	incursion_team = new
	incursion_team.forge_team_objectives(restricted_roles)
	for(var/datum/mind/M in assigned)
		var/datum/antagonist/incursion/new_incursionist = new antag_datum()
		new_incursionist.team = incursion_team
		incursion_team.add_member(M)
		M.add_antag_datum(new_incursionist)
	return TRUE

/datum/dynamic_ruleset/roundstart/incursion/round_result()
	..()
	if(incursion_team.check_incursion_victory())
		SSticker.mode_result = "win - incursion win"
	else
		SSticker.mode_result = "loss - staff stopped the incursion"

//////////////////////////////////////////////
//                                          //
//             ASSIMILATION                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/hivemind
	name = "Assimilation"
	antag_flag = ROLE_HIVE
	antag_datum = /datum/antagonist/hivemind
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 3
	weight = 3
	cost = 30
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	flags = HIGH_IMPACT_RULESET | NO_OTHER_ROUNDSTARTS_RULESET

/datum/dynamic_ruleset/roundstart/hivemind/pre_execute(population)
	. = ..()
	var/num_hosts = max( 3 , rand(0,1) + min(8, round(population / 8) ) )
	for (var/i = 1 to num_hosts)
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_HIVE
	return TRUE

/datum/dynamic_ruleset/roundstart/hivemind/execute()
	for(var/datum/mind/host in assigned)
		var/datum/antagonist/hivemind/new_antag = new antag_datum()
		host.add_antag_datum(new_antag)
	return TRUE
