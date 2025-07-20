/datum/dynamic_ruleset
	/*
	 * Configurable Variables
	*/

	/// For admin logging and round end screen.
	var/name
	/// For admin logging and round end screen. DYNAMIC_CATEGORY_ROUNDSTART, DYNAMIC_CATEGORY_MIDROUND, DYNAMIC_CATEGORY_LATEJOIN
	var/rule_category
	/// The probability of this ruleset being picked against other rulesets. Try and keep this in-between 0 - 10
	var/weight = 5
	/// How many points this ruleset costs to run. (How many players for one of this antagonist to spawn)
	var/points_cost = 7
	/// How many players are drafted by this ruleset. This should usually be 1 but should be increased for team antagonists (cult, incursion)
	var/drafted_players_amount = 1
	/// The role preference used for this ruleset
	var/datum/role_preference/roundstart/role_preference = /datum/role_preference/roundstart/traitor
	/// The antag datum assigned to a candidates mind on execution
	var/datum/antagonist/antag_datum = /datum/antagonist/traitor
	/// If the config flag `protect_roles_from_antagonist` is set, these roles are excluded
	var/list/protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	/// The roles that can never have this ruleset applied to them regardless of the config
	var/list/restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	/// A list of rulesets that this ruleset is not compatible with. (A blood and clock cult can't both run)
	var/list/blocking_rulesets = list()
	/// A flag that determines how the ruleset is handled. (HIGH_IMPACT_RULESET, CANNOT_REPEAT, SHOULD_PROCESS_RULESET)
	var/flags = NONE

	/**
	 * Backend Variables
	**/

	/// The base abstract path for this subtype.
	var/abstract_type = /datum/dynamic_ruleset
	/// List of possible mobs or minds for this ruleset to draft.
	var/list/candidates = list()
	/// A list of mobs or minds chosen for this ruleset.
	var/list/chosen_candidates = list()

/**
 * Set the amount of players to be drafted.
 * IMPORTANT: use ROUND_UP instead of round. We (usually) don't want drafted players to be 0
**/
/datum/dynamic_ruleset/proc/set_drafted_players_amount()
	return

/**
 * Get a list of candidates
**/
/datum/dynamic_ruleset/proc/get_candidates()
	return

/**
 * Remove candidates that do not meet your requirements.
 * Usually this doesn't need to be changed unless you need some specific requirements from your candidates.
**/
/datum/dynamic_ruleset/proc/trim_candidates()
	SHOULD_CALL_PARENT(TRUE)

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

/**
 * Check if all requirements for this ruleset are met.
**/
/datum/dynamic_ruleset/proc/allowed()
	if(length(candidates) < drafted_players_amount)
		log_dynamic("NOT ALLOWED: [name] The minimum candidate requirement (drafted players: [drafted_players_amount]) was not met! (candidates: [length(candidates)])")
		return FALSE

	return TRUE

/**
 * Picks a player from the list of candidates.
 * If we have the SHOULD_USE_ANTAG_REP flag, take antag_rep into account.
**/
/datum/dynamic_ruleset/proc/select_player()
	if(!length(candidates))
		CRASH("[src] called select_player without any candidates!")

	var/mob/selected_player = CHECK_BITFIELD(flags, SHOULD_USE_ANTAG_REP) ? SSdynamic.antag_pick(candidates, role_preference) : pick(candidates)
	candidates -= selected_player

	return selected_player

/**
 * Give our chosen candidates their antag datums
**/
/datum/dynamic_ruleset/proc/execute()
	if(!length(chosen_candidates))
		return DYNAMIC_EXECUTE_FAILURE

	// Roundstart rulesets have their candidate bodies deleted before execute so we store a list of minds, not bodies
	if(istype(src, /datum/dynamic_ruleset/roundstart))
		for(var/datum/mind/chosen_mind in chosen_candidates)
			chosen_mind.add_antag_datum(antag_datum)
	else
		for(var/mob/chosen_candidate in chosen_candidates)
			chosen_candidate.mind.add_antag_datum(antag_datum)

	return DYNAMIC_EXECUTE_SUCCESS

/**
 * If the `SHOULD_PROCESS_RULESET` flag is defined, this is called every tick.
**/
/datum/dynamic_ruleset/proc/rule_process()
	return

/// Set mode result and news report here.
/// Only called if ruleset is flagged as HIGH_IMPACT_RULESET
/datum/dynamic_ruleset/proc/round_result()
	return
