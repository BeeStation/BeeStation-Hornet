/datum/dynamic_ruleset
	/*
	 * Configurable Variables
	*/

	/// For admin logging and round end screen.
	var/name
	/// For admin logging and round end screen. DYNAMIC_CATEGORY_ROUNDSTART, DYNAMIC_CATEGORY_MIDROUND, DYNAMIC_CATEGORY_LATEJOIN
	var/rule_category
	/// Ranging from 0 - 9. The probability of this ruleset being picked against other rulesets.
	var/weight = 5
	/// How many points this ruleset costs to run. (How many players for one of this antagonist to spawn)
	var/points_cost = 7
	/// How many players are drafted by this ruleset. This should usually be 1 but should be increased for team antagonists (cult, incursion)
	var/drafted_players_amount = 1
	/// The role preference used for this ruleset
	var/datum/role_preference/antagonist/role_preference = /datum/role_preference/antagonist/traitor
	/// The antag datum assigned to a candidates mind on execution
	var/datum/antagonist/antag_datum = /datum/antagonist/traitor
	/// If the config flag 'protect_roles_from_antagonist' is TRUE, then these roles are excluded
	var/list/protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	/// The roles that can never have this ruleset applied to them regardless of the config
	var/list/restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	/// A list of rulesets that this ruleset is not compatible with. (A blood and clock cult can't both run)
	var/list/blocking_rulesets = list()
	/// A flag that determines how the ruleset is handled. (HIGH_IMPACT_RULESET, CANNOT_REPEAT, SHOULD_PROCESS_RULESET)
	var/flags = NONE

	/*
	 * Backend Variables
	*/

	/// Reference to the dynamic gamemode
	var/datum/game_mode/dynamic/dynamic
	/// List of possible people for this ruleset to draft. Assigned in 'dynamic.dm' 'pick_roundstart_rulesets()'
	var/candidates = list()
	/// A list of people chosen for this ruleset, usually a list of minds but is a list of observers when a ghost ruleset
	var/list/chosen_candidates = list()

/datum/dynamic_ruleset/New(dynamic_mode)
	SHOULD_NOT_OVERRIDE(TRUE)
	dynamic = dynamic_mode
	. = ..()

/*
* Some rulesets, like cult, set their drafted players to an ammount relative to the server population.
* IMPORTANT: use ROUND_UP instead of round. We (usually) don't want drafted players to be 0
*/
/datum/dynamic_ruleset/proc/set_drafted_players_amount()
	return

/*
* Get a list of candidates
*/
/datum/dynamic_ruleset/proc/get_candidates()
	return

/*
* Remove candidates that do not meet your requirements.
* Usually this doesn't need to be changed unless you need some specific requirements from your candidates.
* Or you're using a midround ghost ruleset :)
*/
/datum/dynamic_ruleset/proc/trim_candidates()
	for(var/mob/candidate in candidates)
		var/client/client = GET_CLIENT(candidate)

		// Connected?
		if(!client || !candidate.mind)
			candidates -= candidate
			continue

		// Antag banned?
		// Antag disabled?
		// Enough hours?
#if !defined(TESTING)
		if(!client.should_include_for_role(
			banning_key = antag_datum.banning_key,
			role_preference_key = role_preference,
			req_hours = antag_datum.required_living_playtime
		))
			candidates -= candidate
			continue
#endif

		// Already assigned antag?
		if(candidate.mind.special_role)
			candidates -= candidate
			continue

/*
* Check if all requirements for this ruleset are met.
* Called from 'dynamic.dm' 'pick_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/allowed()
	if(length(candidates) < drafted_players_amount)
		log_dynamic("NOT ALLOWED: [name] The minimum candidate requirement (drafted players: [drafted_players_amount]) was not met! (candidates: [length(candidates)])")
		return FALSE

	return TRUE

/*
* Picks a player from the list of candidates.
* If we have the SHOULD_USE_ANTAG_REP flag, take antag_rep into account.
*/
/datum/dynamic_ruleset/proc/select_player()
	if(!length(candidates))
		stack_trace("[src] called select_player without any candidates!")
		return

	var/mob/dead/new_player/selected_player = dynamic && CHECK_BITFIELD(flags, SHOULD_USE_ANTAG_REP) ? dynamic.antag_pick(candidates, role_preference) : pick(candidates)

	if(selected_player)
		candidates -= selected_player
	return selected_player.mind

/*
* Give your chosen minds their antag datums.
*/
/datum/dynamic_ruleset/proc/execute()
	if(!length(chosen_candidates))
		return DYNAMIC_EXECUTE_FAILURE

	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.add_antag_datum(antag_datum)

	return DYNAMIC_EXECUTE_SUCCESS

/*
* If flags contains 'SHOULD_PROCESS_RULESET', this is called every tick.
*/
/datum/dynamic_ruleset/proc/rule_process()
	return

/// Set mode result and news report here.
/// Only called if ruleset is flagged as HIGH_IMPACT_RULESET
/datum/dynamic_ruleset/proc/round_result()
	return

/datum/dynamic_ruleset/latejoin
	rule_category = DYNAMIC_CATEGORY_LATEJOIN
