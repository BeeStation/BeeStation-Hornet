/*
* Order of procs being called by 'dynamic.dm'
*
* check_points_requirement()
* trim_candidates()
* allowed()
* pre_execute()
* execute()
* rule_process()
*/

/datum/dynamic_ruleset
	/*
	 * Configurable Variables
	*/

	/// For admin logging and round end screen. (traitors, wizard, nuclear emergency)
	var/name = "Ruleset"
	/// For admin logging and round end screen. (Roundstart, Midround, Latejoin)
	var/rule_category
	/// If set to TRUE, dynamic will call rule_process() every time it ticks.
	var/should_process = FALSE
	/// Ranging from 0 - 9. The probability of this ruleset being picked against other rulesets.
	var/weight = 5
	/// What is the minimum number of population points for this to be drafted.
	var/minimum_points_required = 0
	/// How many points this ruleset costs to run. (How many players for one of this antagonist to spawn)
	var/points_cost = 5
	/// How many players are drafted by this ruleset. This should usually be 1 but should be increased for team antagonists (cult, incursion)
	var/drafted_players_amount = 1
	/// The role preference used for this ruleset
	var/role_preference = /datum/role_preference/antagonist/traitor
	/// The antag datum assigned to a candidates mind on execution
	var/antag_datum = /datum/antagonist/traitor
	/// If the config flag 'protect_roles_from_antagonist' is TRUE, then these roles are excluded
	var/list/protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	/// The roles that can never have this ruleset applied to them regardless of the config
	var/list/banned_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	/// A list of rulesets that this ruleset is not compatible with. (A blood and clock cult can't both run)
	var/list/blocking_rulesets = list()
	/// Should the chosen player(s) be picked based off of their antagonist reputation
	var/use_antag_reputation = FALSE
	/// A flag that determines how the ruleset is handled. Check __DEFINES/dynamic.dm for an explanation of the accepted values.
	var/flags = NONE

	/*
	 * Backend Variables
	*/

	/// Reference to the dynamic gamemode
	var/dynamic
	/// List of possible people for this ruleset to draft. Assigned in 'dynamic.dm' 'pick_roundstart_rulesets()'
	var/candidates = list()
	/// List of minds to become antag
	var/chosen_minds = list()

/datum/dynamic_ruleset/New(datum/game_mode/dynamic/dynamic_mode)
	SHOULD_NOT_OVERRIDE(TRUE)
	dynamic = dynamic_mode
	. = ..()

/*
* Check if dynamic has enough points for this event to be possible
* Called from 'dynamic.dm' 'pick_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/check_points_requirement()
	if(dynamic.roundstart_points < minimum_points_required)
		log_game("DYNAMIC: FAIL: [src] is not allowed: The minimum point requirement (minimum: [minimum_points_required]) was not met! (points: [dynamic.roundstart_points])")
		return FALSE
	return TRUE

/*
* Remove candidates that do not meet your requirements.
* Usually this doesn't need to be changed unless you need some specific requirements from your candidates.
* Called from 'dynamic.dm' 'pick_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/trim_candidates()
	for(var/mob/dead/new_player/player in candidates)
		var/client/client = GET_CLIENT(player)

		// Connected?
		if(!client || !player.mind)
			candidates.Remove(player)
			continue

		// Antag banned/disabled or not enough hours?
		if(!client.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime)
		))
			candidates.Remove(player)
			continue

		// Already assigned antag?
		if(player.mind.special_role)
			candidates.Remove(player)
			continue

/*
* Check if all requirements for this ruleset are met.
* Called from 'dynamic.dm' 'pick_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/allowed()
	if(length(candidates) < drafted_players_amount)
		// log_game("DYNAMIC: FAIL: [src] is not allowed: The minimum point requirement (minimum: [minimum_points_required]) was not met! (points: [dynamic.roundstart_points])")
		return FALSE
	return TRUE

/*
* Picks a player from the list of candidates.
* If 'use_antag_reputation' is set to TRUE, take antag_rep into account.
*/
/datum/dynamic_ruleset/proc/select_player(list/candidates)
	var/mob/dead/new_player/selected_player = dynamic && use_antag_reputation ? dynamic.antag_pick(candidates, role_preference) : pick(candidates)

	if(selected_player)
		candidates -= selected_player
	return selected_player.mind

/*
* Choose candidates
* Apply special_role and banned_roles
* Called from 'dynamic.dm' 'execute_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/pre_execute()
	for(var/i = 1 to drafted_players_amount)
		var/datum/mind/chosen_mind = select_player()

		GLOB.pre_setup_antags += chosen_mind
		chosen_minds += chosen_mind

		chosen_mind.special_role = antag_datum.special_role
		chosen_mind.restricted_roles = banned_roles
	return TRUE

/*
* Give your chosen_minds their antag datums.
* Called from 'dynamic.dm' 'post_setup'
*/
/datum/dynamic_ruleset/proc/execute()
	for(var/datum/mind/chosen_mind in chosen_minds)
		chosen_mind.add_antag_datum(antag_datum)
		GLOB.pre_setup_antags -= chosen_mind
	return DYNAMIC_EXECUTE_SUCCESS

/*
* If 'should_process' is TRUE this is called every tick.
*/
/datum/dynamic_ruleset/proc/rule_process()
	return


/datum/dynamic_ruleset/latejoin
	rule_category = DYNAMIC_LATEJOIN

/// Set mode result and news report here.
/// Only called if ruleset is flagged as HIGH_IMPACT_RULESET
/datum/dynamic_ruleset/proc/round_result()
	return

/// Checks if the ruleset is "dead", where all the antags are either dead or deconverted.
/datum/dynamic_ruleset/proc/is_dead()
	// Don't let dead threats affect simulation results
	if (mode.simulated)
		return FALSE
	for(var/datum/mind/mind in assigned)
		var/mob/living/body = mind.current
		// If they have no body, they're dead for realsies.
		if(QDELETED(body))
			continue
		// Well, if there's nobody in the body, they might as well be dead.
		if(!body.ckey)
			continue
		// Have they been AFK for over 20 minutes? If so, eh, we won't take them into consdideration.
		if(body.client?.is_afk(20 MINUTES))
			continue
		// Have they been husked by a non-burn source? Probably really really dead.
		if(HAS_TRAIT_NOT_FROM(body, TRAIT_HUSK, "burn"))
			continue
		// Alright, they have a body with a ckey, but are they actually dead?
		if(body.stat == DEAD)
			// Has their soul departed or been ripped out? If so, yep, they dead alright.
			if(body.soul_departed() || mind.hellbound)
				continue
			// Are they in medbay or an operating table/stasis bed, and have been dead for less than 20 minutes? If so, they're probably being revived.
			if((mode.simulated_time || world.time) <= (mind.last_death + 15 MINUTES) && (istype(get_area(body), /area/medical) || (locate(/obj/machinery/stasis) in body.loc) || (locate(/obj/structure/table/optable) in body.loc)))
				log_undead()
				return FALSE
		else
			// Are they a silicon? If so, might as well be dead.
			if(issilicon(body) && mind.assigned_role != JOB_NAME_AI)
				continue
			// Well, they're at least somewhat alive. But are they still antag?
			if(antag_datum && mind.has_antag_datum(antag_datum))
				// They're still antag and not dead.
				log_undead()
				return FALSE
	log_dead()
	return TRUE

/datum/dynamic_ruleset/proc/log_dead()
	if(dead)
		return
	dead = TRUE
	log_game("DYNAMIC: ruleset [src] is considered dead now, new midround rulesets may be able to roll now")
	message_admins("DYNAMIC: ruleset [src] is considered dead now, new midround rulesets may be able to roll now")

/datum/dynamic_ruleset/proc/log_undead()
	if(!dead)
		return
	dead = FALSE
	log_game("DYNAMIC: ruleset [src] is no longer considered dead")
	message_admins("DYNAMIC: ruleset [src] is no longer considered dead")

