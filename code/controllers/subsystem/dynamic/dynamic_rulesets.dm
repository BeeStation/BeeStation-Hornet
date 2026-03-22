/datum/dynamic_ruleset
	/**
	 * Configurable Variables
	 */

	/// For admin logging and round end screen.
	var/name
	/// When this ruleset runs. (Roundstart, Midround, Latejoin)
	var/rule_category
	/// The probability of this ruleset being picked against other rulesets.
	/// Access via get_weight
	var/weight = 5
	/// How many points this ruleset costs to run.
	var/points_cost = 7
	/// The minimum amount of players that have to be connected for this ruleset to run
	var/minimum_players_required = 0
	/// The amount of people drafted by this ruleset.
	var/drafted_players_amount = 1
	/// The role preference used for this ruleset
	var/datum/role_preference/roundstart/role_preference
	/// The antag datum assigned to a candidate's mind on execution
	var/datum/antagonist/antag_datum
	/// If the config flag `protect_roles_from_antagonist` is set, these roles are excluded
	var/list/protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_PRISONER)
	/// The roles that can never have this ruleset applied to them regardless of the config
	var/list/restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	/// A list of rulesets that this ruleset is not compatible with. (A blood and clock cult can't both run)
	var/list/blocking_rulesets = list()
	/// The flags that determines how the ruleset is handled.
	var/ruleset_flags = NONE
	/// Time that the ruleset was executed at
	var/executed_at = 0
	/// Was this ruleset removed from the round?
	var/removed = FALSE

	/**
	 * Backend Variables
	 */

	/// The base abstract path for this subtype.
	var/abstract_type = /datum/dynamic_ruleset
	/// List of possible mobs (or minds for roundstart rulesets) for this ruleset to draft.
	var/list/candidates
	/// A list of mobs (or minds for roundstart rulesets) chosen for this ruleset.
	var/list/chosen_candidates

/// Shall we permit this ruleset to be converted into another one?
/datum/dynamic_ruleset/proc/can_convert(ignore_dead = FALSE)
	if (ruleset_flags & NO_TRANSFER_RULESET)
		log_dynamic("CONVERSION: Cannot convert [name] as it is flagged with NO_TRANSFER_RULESET.")
		return FALSE
	// Check to see if we just nuked a ruleset
	var/last_remaining_from_ruleset = TRUE
	var/last_remaining_of_type = TRUE
	for (var/datum/antagonist/antagonist in GLOB.antagonists)
		// This antagonist has been removed from its owner
		if (!antagonist.owner)
			continue
		// If we ignore dead people, don't treat them as existing
		if (ignore_dead && (!antagonist.owner.current || antagonist.owner.current == DEAD))
			continue
		if (antagonist.spawning_ruleset == src)
			last_remaining_from_ruleset = FALSE
		if (istype(antagonist, type))
			last_remaining_of_type = FALSE
	if (!last_remaining_from_ruleset)
		log_dynamic("CONVERSION: Cannot convert [name] as there are still antagonists alive created by this ruleset.")
		return FALSE
	if ((ruleset_flags & NO_CONVERSION_TRANSFER_RULESET) && !last_remaining_of_type)
		log_dynamic("CONVERSION: Cannot convert [name] as there are antagonists of the same type and this ruleset is marked with NO_CONVERSION_TRANSFER_RULESET.")
		return FALSE
	log_dynamic("CONVERSION: Conversion from ruleset [name] was allowed.")
	return TRUE

/// Convert this ruleset into a different ruleset
/datum/dynamic_ruleset/proc/convert_ruleset()
	message_admins("DYNAMIC: Attempted to convert [name] into a new ruleset, but the logic handling this was not implemented. Manual intervention may be required.")
	CRASH("convert_ruleset was called on a ruleset which cannot manage its conversions.")

/**
 * Sets the weight of this ruleset based on non-static rules such as recovery time.
 */
/datum/dynamic_ruleset/proc/get_weight()
	return weight

/**
 * Set the amount of players to be drafted.
 * IMPORTANT: use ROUND_UP instead of round. We don't want the amount of drafted players to be 0
 */
/datum/dynamic_ruleset/proc/set_drafted_players_amount()
	return

/**
 * Get a list of candidates
 */
/datum/dynamic_ruleset/proc/get_candidates()
	return

/// Called when we successfully execute
/datum/dynamic_ruleset/proc/success()
	SHOULD_CALL_PARENT(TRUE)
	executed_at = world.time - SSticker.round_start_time
	if (CHECK_BITFIELD(ruleset_flags, SHOULD_PROCESS_RULESET))
		SSdynamic.rulesets_to_process += src

/**
 * Remove candidates that do not meet your requirements.
 * Usually this doesn't need to be changed unless you need some specific requirements from your candidates.
 */
/datum/dynamic_ruleset/proc/trim_candidates()
	SHOULD_CALL_PARENT(TRUE)

	for(var/mob/candidate as anything in candidates)
		// Hard-deleted?
		if (QDELETED(candidate))
			candidates -= candidate
			continue

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
 */
/datum/dynamic_ruleset/proc/allowed(require_drafted = TRUE)
	// Some rulesets such as midrounds don't need drafted players to be
	// picked, as the poll will continue until it hits the players required
	if(length(candidates) < drafted_players_amount && require_drafted)
		log_dynamic("NOT ALLOWED: [src] did not meet the minimum candidate requirement! (required candidates: [drafted_players_amount]) (candidates: [length(candidates)])")
		return FALSE

	var/players = length(SSdynamic.current_players[CURRENT_LIVING_PLAYERS])
	if (ruleset_flags & REQUIRED_POP_ALLOW_UNREADY)
		// If we can use unreadied players, take anyone in the game
		players = length(GLOB.player_list)
	else if (!SSticker.HasRoundStarted())
		// If the round hasn't started and we can't use unreadied players,
		// then take the total number of ready players
		players = SSticker.totalPlayersReady

	if(players < minimum_players_required)
		log_dynamic("NOT ALLOWED: [src] did not meet the minimum player requirement! (minimum players: [minimum_players_required]) (players: [players])")
		return FALSE

	return TRUE

/**
 * Picks a player from the list of candidates.
 * If we have the SHOULD_USE_ANTAG_REP flag, take antag_rep into account.
 */
/datum/dynamic_ruleset/proc/select_player()
	var/mob/selected_player = CHECK_BITFIELD(ruleset_flags, SHOULD_USE_ANTAG_REP) ? SSdynamic.antag_pick(candidates, role_preference) : pick(candidates)
	candidates -= selected_player
	return selected_player

/**
 * Give our chosen candidates their antag datums
 */
/datum/dynamic_ruleset/proc/execute()
	if(!length(chosen_candidates))
		return DYNAMIC_EXECUTE_FAILURE

	// Roundstart rulesets have their candidate bodies deleted before execute so we store a list of minds, not bodies
	for(var/datum/mind/chosen_mind in chosen_candidates)
		chosen_mind.add_antag_datum(antag_datum, ruleset = src)
	for(var/mob/chosen_candidate in chosen_candidates)
		chosen_candidate.mind.add_antag_datum(antag_datum, ruleset = src)

	return DYNAMIC_EXECUTE_SUCCESS

/**
 * If the `SHOULD_PROCESS_RULESET` flag is defined, this is called every tick.
 */
/datum/dynamic_ruleset/proc/rule_process()
	return

/**
 * Called at roundend if you have the flag `HIGH_IMPACT_RULESET`. Set the news report and mode result here.
 */
/datum/dynamic_ruleset/proc/round_result()
	return

/**
 * Instantiate and return a new ruleset with the same type and mostly the same vars as src.
 */
/datum/dynamic_ruleset/proc/duplicate()
	var/datum/dynamic_ruleset/new_ruleset = new type()

	// Configurable vars
	new_ruleset.weight = weight
	new_ruleset.points_cost = points_cost
	new_ruleset.minimum_players_required = minimum_players_required
	new_ruleset.drafted_players_amount = drafted_players_amount
	new_ruleset.protected_roles = protected_roles.Copy()
	new_ruleset.restricted_roles = restricted_roles.Copy()
	new_ruleset.ruleset_flags = ruleset_flags

	// Backend vars - intentionally not candidates.Copy()
	new_ruleset.candidates = candidates

	return new_ruleset
