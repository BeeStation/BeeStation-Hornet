/*
* Order of procs being called by 'dynamic.dm'
*
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
	/// Ranging from 0 - 9. The probability of this ruleset being picked against other rulesets.
	var/weight = 5
	/// How many points this ruleset costs to run. (How many players for one of this antagonist to spawn)
	var/points_cost = 5
	/// How many players are drafted by this ruleset. This should usually be 1 but should be increased for team antagonists (cult, incursion)
	var/drafted_players_amount = 1
	/// The role preference used for this ruleset
	var/datum/role_preference/antagonist/role_preference = /datum/role_preference/antagonist/traitor
	/// The antag datum assigned to a candidates mind on execution
	var/datum/antagonist/antag_datum = /datum/antagonist/traitor
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
	var/datum/game_mode/dynamic/dynamic
	/// List of possible people for this ruleset to draft. Assigned in 'dynamic.dm' 'pick_roundstart_rulesets()'
	var/candidates = list()
	/// List of minds to become antag
	var/chosen_minds = list()

/datum/dynamic_ruleset/New(dynamic_mode)
	SHOULD_NOT_OVERRIDE(TRUE)
	dynamic = dynamic_mode
	. = ..()

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
			candidates -= player
			continue

		// Antag banned? Disabled? Not enough hours?
		if(!client.should_include_for_role(
			banning_key = antag_datum.banning_key,
			role_preference_key = role_preference,
			req_hours = antag_datum.required_living_playtime
		))
			candidates -= player
			continue

		// Already assigned antag?
		if(player.mind.special_role)
			candidates -= player
			continue

/*
* Check if all requirements for this ruleset are met.
* Called from 'dynamic.dm' 'pick_roundstart_rulesets()'
*/
/datum/dynamic_ruleset/proc/allowed()
	if(length(candidates) < drafted_players_amount)
		log_game("DYNAMIC: FAIL: [name] is not allowed: The minimum candidate requirement (drafted players: [drafted_players_amount]) was not met! (candidates: [length(candidates)])")
		return FALSE

	return TRUE

/*
* Picks a player from the list of candidates.
* If 'use_antag_reputation' is set to TRUE, take antag_rep into account.
*/
/datum/dynamic_ruleset/proc/select_player()
	var/mob/dead/new_player/selected_player = dynamic && use_antag_reputation ? dynamic.antag_pick(candidates, role_preference) : pick(candidates)

	if(selected_player)
		candidates -= selected_player
	return selected_player.mind

/*
* Choose candidates
* Apply special_role and banned_roles
* Called from 'dynamic.dm' pick_roundstart_rulesets()
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
* Called from 'dynamic.dm' post_setup()
*/
/datum/dynamic_ruleset/proc/execute()
	for(var/datum/mind/chosen_mind in chosen_minds)
		chosen_mind.add_antag_datum(antag_datum)
		GLOB.pre_setup_antags -= chosen_mind
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
	rule_category = DYNAMIC_LATEJOIN
