//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	for(var/mob/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role) // Are they connected?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_roles) // Does their job allow for it?
			candidates.Remove(P)
		else if(length(exclusive_roles) && !(P.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
			candidates.Remove(P)
		else if(!P.client.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime)
		))
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(forced = FALSE)
	if (forced)
		return ..()

	var/job_check = 0
	if (enemy_roles.len > 0)
		for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
			if (M.stat == DEAD)
				continue // Dead players cannot count as opponents
			if (M.mind && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

	var/threat = round(mode.threat_level/10)

	if (job_check < required_enemies[threat])
		log_game("DYNAMIC: FAIL: [src] is not ready, because there are not enough enemies: [required_enemies[threat]] needed, [job_check] found")
		return FALSE

	if (mode.check_lowpop_lowimpact_injection())
		return FALSE

	return ..()

/datum/dynamic_ruleset/latejoin/execute(forced = FALSE)
	var/mob/M = pick(candidates)
	assigned += M.mind
	M.mind.special_role = initial(antag_datum.banning_key)
	M.mind.add_antag_datum(antag_datum)
	return DYNAMIC_EXECUTE_SUCCESS

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	antag_datum = /datum/antagonist/traitor
	role_preference = /datum/role_preference/antagonist/traitor
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL)
	restricted_roles = list(JOB_NAME_AI,JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 7
	cost = 8
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	repeatable = TRUE
	flags = INTACT_STATION_RULESET
	blocking_rules = list(
		/datum/dynamic_ruleset/roundstart/bloodcult,
		/datum/dynamic_ruleset/roundstart/clockcult,
		/datum/dynamic_ruleset/roundstart/nuclear,
		/datum/dynamic_ruleset/roundstart/wizard,
		/datum/dynamic_ruleset/roundstart/revs,
		/datum/dynamic_ruleset/roundstart/hivemind
	)

//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	persistent = TRUE
	antag_datum = /datum/antagonist/rev/head
	role_preference = /datum/role_preference/antagonist/revolutionary
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	enemy_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER,JOB_NAME_DETECTIVE,JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_WARDEN)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 2
	delay = 1 MINUTES // Prevents rule start while head is offstation.
	cost = 13
	requirements = list(101,101,70,40,30,20,20,20,20,20)
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/revs)
	var/required_heads_of_staff = 3
	var/finished = FALSE
	/// How much threat should be injected when the revolution wins?
	var/revs_win_threat_injection = 20
	var/datum/team/revolution/revolution

/datum/dynamic_ruleset/latejoin/provocateur/ready(forced=FALSE)
	if (forced)
		required_heads_of_staff = 1
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.current_players[CURRENT_LIVING_PLAYERS])
		if (player.mind.assigned_role in GLOB.command_positions)
			head_check++
	return (head_check >= required_heads_of_staff)

/datum/dynamic_ruleset/latejoin/provocateur/execute(forced = FALSE)
	var/mob/M = pick(candidates)	// This should contain a single player, but in case.
	if(check_eligible(M.mind))	// Didnt die/run off z-level/get implanted since leaving shuttle.
		assigned += M.mind
		M.mind.special_role = ROLE_REV_HEAD
		revolution = new()
		var/datum/antagonist/rev/head/new_head = new()
		new_head.give_flash = TRUE
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		new_head = M.mind.add_antag_datum(new_head, revolution)
		revolution.update_objectives()
		revolution.update_heads()
		SSshuttle.registerHostileEnvironment(revolution)
		return DYNAMIC_EXECUTE_SUCCESS
	else
		log_game("DYNAMIC: [ruletype] [name] discarded [M.name] from head revolutionary due to ineligibility.")
		log_game("DYNAMIC: [ruletype] [name] failed to get any eligible headrevs. Refunding [cost] threat.")
		return DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS

/datum/dynamic_ruleset/latejoin/provocateur/rule_process()
	var/winner = revolution.process_victory(revs_win_threat_injection)
	if (isnull(winner))
		return

	finished = winner
	return RULESET_STOP_PROCESSING

/// Checks for revhead loss conditions and other antag datums.
/datum/dynamic_ruleset/latejoin/provocateur/proc/check_eligible(var/datum/mind/M)
	var/turf/T = get_turf(M.current)
	if(!considered_afk(M) && considered_alive(M) && is_station_level(T.z) && !M.antag_datums?.len && !HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return TRUE
	return FALSE

/datum/dynamic_ruleset/latejoin/provocateur/round_result()
	revolution.round_result(finished)

//////////////////////////////////////////////
//                                          //
//           HERETIC SMUGGLER          		//
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/heretic_smuggler
	name = "Heretic Smuggler"
	antag_datum = /datum/antagonist/heretic
	role_preference = /datum/role_preference/antagonist/heretic
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI,JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 4
	cost = 10
	requirements = list(101,101,101,10,10,10,10,10,10,10)
	repeatable = TRUE
	blocking_rules = list(
		/datum/dynamic_ruleset/roundstart/bloodcult,
		/datum/dynamic_ruleset/roundstart/clockcult,
		/datum/dynamic_ruleset/roundstart/nuclear,
		/datum/dynamic_ruleset/roundstart/wizard,
		/datum/dynamic_ruleset/roundstart/revs,
		/datum/dynamic_ruleset/roundstart/hivemind
	)

/datum/dynamic_ruleset/latejoin/heretic_smuggler/execute(forced = FALSE)
	var/mob/picked_mob = pick(candidates)
	assigned += picked_mob.mind
	picked_mob.mind.special_role = ROLE_HERETIC
	var/datum/antagonist/heretic/new_heretic = picked_mob.mind.add_antag_datum(antag_datum)

	// Heretics passively gain influence over time.
	// As a consequence, latejoin heretics start out at a massive
	// disadvantage if the round's been going on for a while.
	// Let's give them some influence points when they arrive.
	new_heretic.knowledge_points += round((world.time - SSticker.round_start_time) / new_heretic.passive_gain_timer)
	// BUT let's not give smugglers a million points on arrival.
	// Limit it to four missed passive gain cycles (4 points).
	new_heretic.knowledge_points = min(new_heretic.knowledge_points, 5)

	return DYNAMIC_EXECUTE_SUCCESS
