SUBSYSTEM_DEF(dynamic)
	name = "Dynamic"
	runlevels = RUNLEVEL_GAME
	wait = 1 MINUTES

	/**
	 * Roundstart variables
	**/

	/// Set at the beginning of the round, our budget for choosing rulesets
	var/roundstart_points = 0
	/// Only here for logging purposes
	var/roundstart_point_divergence = 1
	/// List of all roundstart rulesets that have been executed
	var/list/datum/dynamic_ruleset/roundstart/roundstart_executed_rulesets = list()
	/// List of players ready on roundstart.
	var/list/mob/dead/new_player/authenticated/roundstart_candidates = list()
	/// The amount of people ready at roundstart
	var/roundstart_ready_amount = 0
	/// A list if roundstart rulesets configured from 'dynamic.json'
	var/list/datum/dynamic_ruleset/roundstart/roundstart_configured_rulesets

	/// Dynamic Panel variables

	/// List of forced roundstart rulesets from the dynamic panel
	var/list/datum/dynamic_ruleset/roundstart/roundstart_forced_rulesets = list()
	/// Do we choose any roundstart rulesets or only use the ones in `roundstart_forced_rulesets`
	var/roundstart_only_use_forced_rulesets = FALSE
	/// Inverse of the above, blacklist the rulesets in `roundstart_forced_rulesets`
	var/roundstart_blacklist_forced_rulesets = FALSE
	/// Whether or not we ignore our roundstart points calculation
	var/roundstart_points_override = FALSE

	/**
	 * Midround variables
	**/

	/// How many points we currently have to spend on the next midround. Constantly changing
	var/midround_points = 0
	/// List of all midround rulesets that have been executed
	var/list/datum/dynamic_ruleset/midround/midround_executed_rulesets = list()
	/// The midround that we are currently saving points up for.
	var/datum/dynamic_ruleset/midround/midround_chosen_ruleset
	/// A list if midround rulesets configured from 'dynamic.json'
	var/list/datum/dynamic_ruleset/midround/midround_configured_rulesets

	/// The chances for each type of midround ruleset to be picked
	/// Set in `configure_variables()`
	var/midround_light_chance
	var/midround_medium_chance
	var/midround_heavy_chance

	/// The cooldown until the chosen midround can execute
	COOLDOWN_DECLARE(midround_ruleset_cooldown)

	/// Dynamic Panel variables

	/// Logged points over time
	var/list/logged_points = list(
		"logged_points" = list(0),
		"logged_points_living" = list(0),
		"logged_points_dead" = list(0),
		"logged_points_dead_security" = list(0),
		"logged_points_observer" = list(0),
		"logged_points_antag" = list(0),
		"logged_points_linear" = list(0),
		"logged_points_linear_forced" = list(0),
	)
	/// Logged chances, should be from 0 to 10, not 0 to 100
	var/list/logged_chances = list(
		"light" = list(10),
		"medium" = list(0),
		"heavy" = list(0),
	)

	/**
	 * Latejoin variables
	**/

	/// List of all latejoin rulesets that have been executed
	var/list/datum/dynamic_ruleset/latejoin/latejoin_executed_rulesets = list()
	/// The latejoin ruleset to force. Only for admin interaction
	var/datum/dynamic_ruleset/latejoin/latejoin_forced_ruleset
	/// A list if latejoin rulesets configured from 'dynamic.json'
	var/list/datum/dynamic_ruleset/latejoin/latejoin_configured_rulesets

	/**
	 * Other variables
	**/

	/// Can dynamic actually do stuff? Execute midrounds, latejoins, etc.
	var/forced_extended = FALSE
	/// The dynamic configuration file. Used for setting ruleset and dynamic variables
	var/list/dynamic_configuration
	/// Some rulesets (like revolution) need to process
	var/list/datum/dynamic_ruleset/rulesets_to_process = list()
	/// Associative list of current players
	var/list/list/current_players = list(
		CURRENT_LIVING_PLAYERS = list(),
		CURRENT_LIVING_ANTAGS = list(),
		CURRENT_DEAD_PLAYERS = list(),
		CURRENT_OBSERVERS = list(),
	)

	/**
	 * Configurable variables
	 * All of these can be changed in the dynamic configuration file
	 *
	 * IMPORTANT: none of the variables above should be configured
	**/

	/**
	 * Roundstart
	**/

	/// In order to make rounds less predictable, a randomized divergence percentage is applied to the total point value
	/// These should be decimals. i.e: 0.20, 0.75, 1.5
	var/roundstart_divergence_percent_lower = 1
	var/roundstart_divergence_percent_upper = 1
	/// How many roundstart points should be granted per player based off ready status
	var/roundstart_points_per_ready = 1
	var/roundstart_points_per_unready = 0.5
	var/roundstart_points_per_observer = 0

	/**
	 * Midround
	 *
	 * How midround rolling works is as follows:
	 *
	 * All midround rulesets have a specific severity. Light, Medium, or Heavy
	 * At the start of the round, there is a 100% chance to choose a Light midround (Light Ruleset Chance)
	 * As the round progresses, the Light Ruleset Chance decreases and the Medium/Heavy Ruleset Chance increases.
	 *
	 * The amount that the Light Ruleset Chance decreases every minute
	 * is given to the Medium Ruleset Chance and Heavy Ruleset Chance.
	 *
	 * The ratio determining what percentage of the
	 * Light Ruleset Chance decrease rate is given to the Medium Ruleset Chance is 75%.
	 * The Heavy Ruleset Chance will receive the remainder, in this case, 25%
	 *
	 * When the round time reaches one hour the Light Ruleset Chance will reach 0%
	 * and the Medium Ruleset Chance will start to decrease while the Heavy Ruleset Chance increases.
	 *
	 * The rest is pretty simple, the chosen midround ruleset's severity is picked based off
	 * the Light/Medium/Heavy Ruleset Chances and after that, we choose based off ruleset weights of that severity.
	 * Finally, we save up until we have enough points to execute our chosen midround ruleset and repeat the cycle.
	**/

	/// The chances for each type of midround ruleset to be picked at roundstart
	var/midround_light_starting_chance = 100
	var/midround_medium_starting_chance = 0
	var/midround_heavy_starting_chance = 0
	/// At this time the Light/Medium Ruleset Chance will reach 0%
	/// When configuring these in `dynamic.json` be sure to have them set in deciseconds (minutes * 600)
	var/midround_light_end_time = 1 HOURS
	var/midround_medium_end_time = 2 HOURS
	/// The ratio of the Light Ruleset Chance decrease rate that is given to the Medium Ruleset Chance
	/// The Heavy Ratio is the remainder of the Medium Increase Ratio
	/// These should always be on a range of 0 - 1. i.e: 0.25, 0.75, 1.0
	var/midround_medium_increase_ratio = 1
	/// The time at which midrounds can start rolling
	var/midround_grace_period = 20 MINUTES
	/// The amount of midround points given per minute for every type of player
	/// The total midround points delta cannot be lower than 0, it always increases or stays the same
	var/midround_living_delta = 0.05
	var/midround_observer_delta = 0
	var/midround_dead_delta = -0.4
	var/midround_dead_security_delta = -0.6
	var/midround_linear_delta = 0.9
	/// This delta is applied no matter what
	var/midround_linear_delta_forced = 0.25

	/// How long dynamic will wait to execute another ruleset if it fails to execute the previous one
	/// Used to mitigate spam and antag rolling
	var/midround_failure_stallout = 5 MINUTES

	/// The point delta per living antagonist
	var/list/midround_points_per_antag = list(
		"/datum/antagonist/ert" = 0.2,
		"/datum/antagonist/spider" = -0.15,
		"/datum/antagonist/swarmer" = -0.15,
		"/datum/antagonist/xeno" = -0.2,
		"/datum/antagonist/revenant" = -0.6,
		"/datum/antagonist/ninja" = -1.1,
		"/datum/antagonist/space_dragon" = -2.5,
		"/datum/antagonist/wizard" = -2.5,
		"/datum/antagonist/slaughter" = -4,
		"/datum/antagonist/blob" = -4,
		"/datum/antagonist/morph" = -0.3,
		"/datum/antagonist/pirate" = -0.5,
		"/datum/antagonist/pirate/captain" = -0.5,
		"/datum/antagonist/malf_ai" = -0.6,
		"/datum/antagonist/traitor" = -0.2,
		"/datum/antagonist/heretic" = -0.2,
		"/datum/antagonist/brother" = -0.1,
		"/datum/antagonist/changeling" = -0.2,
	)

	/**
	 * Latejoin
	**/

	/// The max amount of latejoin rulesets that can be picked
	var/latejoin_max_rulesets = 1
	/// The probability for a latejoin ruleset to be picked
	var/latejoin_ruleset_probability = 10

/datum/controller/subsystem/dynamic/Initialize()
	configure_variables()

	midround_light_chance = midround_light_starting_chance
	midround_medium_chance = midround_medium_starting_chance
	midround_heavy_chance = midround_heavy_starting_chance
	return SS_INIT_SUCCESS

/**
 * Configure dynamic variables from `dynamic.json`
**/
/datum/controller/subsystem/dynamic/proc/configure_variables()
	if(CONFIG_GET(flag/dynamic_config_enabled))
		var/json_file = file("config/dynamic.json")
		if(fexists(json_file))
			try
				dynamic_configuration = json_decode(file2text(json_file))
			catch(var/exception/error)
				stack_trace("Error while loading dynamic config: [error]")

			if(dynamic_configuration?["Dynamic"])
				for(var/variable in dynamic_configuration["Dynamic"])
					if(isnull(vars[variable]))
						stack_trace("Invalid dynamic configuration variable: [variable]")
						continue
					vars[variable] = dynamic_configuration["Dynamic"][variable]

	// Configure Roundstart
	roundstart_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/roundstart)
	if(!length(roundstart_configured_rulesets))
		stack_trace("DYNAMIC: ROUNDSTART: roundstart_configured_rulesets is empty. It is impossible to roll roundstart rulesets")
		log_dynamic("ROUNDSTART: roundstart_configured_rulesets is empty. It is impossible to roll roundstart rulesets")

	// Configure Midround

	midround_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/midround)
	if(!length(midround_configured_rulesets))
		stack_trace("DYNAMIC: MIDROUND: midround_configured_rulesets is empty. It is impossible to roll midrounds")
		log_dynamic("MIDROUND: midround_configured_rulesets is empty. It is impossible to roll midrounds")

	// Configure Latejoin
	latejoin_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/latejoin)
	if(!length(latejoin_configured_rulesets))
		stack_trace("DYNAMIC: LATEJOIN: latejoin_configured_rulesets is empty. It is impossible to roll latejoins")
		log_dynamic("LATEJOIN: latejoin_configured_rulesets is empty. It is impossible to roll latejoins")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA_STATIC)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA)

/**
 * Called at roundstart, set roundstart points and choose rulesets
**/
/datum/controller/subsystem/dynamic/proc/select_roundstart_antagonists()
	set_roundstart_points()

	log_dynamic("ROUNDSTART: Listing [length(roundstart_configured_rulesets)] roundstart rulesets, and [length(roundstart_candidates)] players ready.")
	if(!length(roundstart_candidates))
		return TRUE

	pick_roundstart_rulesets(roundstart_configured_rulesets)

	// Save us from hard dels
	roundstart_ready_amount = length(roundstart_candidates)
	roundstart_candidates = list()
	return TRUE

/**
 * Generate the amount of roundstart points based on how many people are ready
 * and add those ready people to the list of roundstart candidates
 *
 * A randomized divergence is then applied so rounds are less predictable
**/
/datum/controller/subsystem/dynamic/proc/set_roundstart_points()
	for(var/mob/dead/new_player/authenticated/player as anything in GLOB.auth_new_player_list)
		// Add to candidates if ready
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences())
			roundstart_candidates += player

		if(!roundstart_points_override)
			if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences())
				roundstart_points += roundstart_points_per_ready
			else if(player.ready == PLAYER_NOT_READY)
				roundstart_points += roundstart_points_per_unready
			else if(player.ready == PLAYER_READY_TO_OBSERVE)
				roundstart_points += roundstart_points_per_observer

	roundstart_point_divergence = rand() * ((roundstart_divergence_percent_upper) - (roundstart_divergence_percent_lower)) + (roundstart_divergence_percent_lower)
	roundstart_points = round(roundstart_points * roundstart_point_divergence)

	log_dynamic("ROUNDSTART: Starting with [roundstart_points] roundstart points and a divergence of [round((roundstart_point_divergence - 1) * 100)]%")

/**
 * Pick the roundstart rulesets to run based on their configured variables (weight, cost, flags)
**/
/datum/controller/subsystem/dynamic/proc/pick_roundstart_rulesets(roundstart_rules)
	// Extended was forced, don't pick any rulesets
	if(forced_extended)
		log_dynamic("ROUNDSTART: Starting a round of forced extended.")
		return

	// Check for forced rulesets
	if(!roundstart_blacklist_forced_rulesets)
		for(var/datum/dynamic_ruleset/roundstart/forced_ruleset in roundstart_forced_rulesets)
			forced_ruleset.set_drafted_players_amount()
			forced_ruleset.get_candidates()
			forced_ruleset.trim_candidates()
			forced_ruleset.minimum_players_required = 0 // lel

			if(!forced_ruleset.allowed())
				log_dynamic("ROUNDSTART: Could not force [forced_ruleset]")
				message_admins("DYNAMIC: ROUNDSTART: Could not force [forced_ruleset]")
				continue

			roundstart_executed_rulesets[forced_ruleset] += 1
			forced_ruleset.choose_candidates()

			log_dynamic("ROUNDSTART: Successfully forced [forced_ruleset]")
			message_admins("DYNAMIC: ROUNDSTART: Successfully forced [forced_ruleset]")

	if(roundstart_only_use_forced_rulesets)
		return

	// Trim the rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/roundstart/potential_ruleset in roundstart_rules)
		potential_ruleset.set_drafted_players_amount()
		potential_ruleset.get_candidates()
		potential_ruleset.trim_candidates()

		if(!potential_ruleset.allowed())
			continue

		if(roundstart_blacklist_forced_rulesets && (potential_ruleset in roundstart_forced_rulesets))
			continue

		possible_rulesets[potential_ruleset] = potential_ruleset.weight

	// Pick rulesets
	var/roundstart_points_left = roundstart_points
	var/no_other_rulesets = FALSE
	while(roundstart_points_left > 0)
		if(!length(possible_rulesets))
			break

		var/datum/dynamic_ruleset/roundstart/ruleset = pick_weight(possible_rulesets)

		// Ran out of rulesets
		if(isnull(ruleset))
			log_dynamic("ROUNDSTART: No more rulesets can be applied, stopping with [roundstart_points_left] points left.")
			break

		// Something changed and this ruleset is no longer allowed
		// Most common occurance is all previous candidates were assigned an antag position
		ruleset.trim_candidates()
		if(!ruleset.allowed())
			possible_rulesets -= ruleset
			continue

		// Not enough points left
		if(ruleset.points_cost > roundstart_points_left)
			possible_rulesets -= ruleset
			continue

		// check_is_ruleset_blocked()
		if(check_is_ruleset_blocked(ruleset, roundstart_executed_rulesets))
			possible_rulesets -= ruleset
			continue

		// Apply cost and add ruleset to 'roundstart_executed_rulesets'
		roundstart_points_left -= ruleset.points_cost

		roundstart_executed_rulesets[ruleset] += 1
		ruleset.choose_candidates()

		log_dynamic("ROUNDSTART: Chose [ruleset] with [roundstart_points_left] points left")

		if(CHECK_BITFIELD(ruleset.flags, NO_OTHER_RULESETS))
			no_other_rulesets = TRUE
			break

	// Deal with the NO_OTHER_RULESETS flag
	if(no_other_rulesets)
		for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_executed_rulesets)
			if(CHECK_BITFIELD(ruleset.flags, NO_OTHER_RULESETS))
				continue
			if(ruleset in roundstart_forced_rulesets)
				continue

			// Undraft our previously drafted players
			for(var/mob/chosen_candidate in ruleset.chosen_candidates)
				GLOB.pre_setup_antags -= chosen_candidate.mind

				chosen_candidate.mind.special_role = null
				chosen_candidate.mind.restricted_roles = list()

			log_dynamic("ROUNDSTART: Cancelling [ruleset] because a ruleset with the 'NO_OTHER_RULESETS' was chosen")
			roundstart_executed_rulesets -= ruleset

/**
 * Checks if this ruleset is blocked by any other rulesets or ruleset flags.
 * Return TRUE if the ruleset is blocked
**/
/datum/controller/subsystem/dynamic/proc/check_is_ruleset_blocked(datum/dynamic_ruleset/ruleset, list/datum/dynamic_ruleset/applied_rulesets)
	// Check for blocked rulesets
	for(var/datum/dynamic_ruleset/blocked_ruleset in ruleset.blocking_rulesets)
		for(var/datum/dynamic_ruleset/executed_ruleset in applied_rulesets)
			if(blocked_ruleset.type == executed_ruleset.type)
				log_dynamic("NOT ALLOWED: [ruleset] was blocked by [blocked_ruleset]")
				return TRUE

	// Check for bitflags
	for(var/datum/dynamic_ruleset/other_ruleset in applied_rulesets)
		if(CHECK_BITFIELD(other_ruleset.flags, HIGH_IMPACT_RULESET) && CHECK_BITFIELD(ruleset.flags, HIGH_IMPACT_RULESET))
			return TRUE

		if(CHECK_BITFIELD(other_ruleset.flags, NO_OTHER_RULESETS))
			return TRUE

		if(other_ruleset.type == ruleset.type && CHECK_BITFIELD(other_ruleset.flags, CANNOT_REPEAT))
			return TRUE

	return FALSE

/**
 * Execute roundstart rulesets
**/
/datum/controller/subsystem/dynamic/proc/execute_roundstart_rulesets()
	// Execute Roundstarts
	for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_executed_rulesets)
		var/result = execute_ruleset(ruleset)

		log_dynamic("ROUNDSTART: Executing [ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
		if(result != DYNAMIC_EXECUTE_SUCCESS)
			roundstart_executed_rulesets[ruleset] -= 1

/**
 * Some rulesets need to process each tick. Lets give them the opportunity to do so.
**/
/datum/controller/subsystem/dynamic/proc/process_rulesets()
	for(var/datum/dynamic_ruleset/ruleset in rulesets_to_process)
		if(ruleset.rule_process() == RULESET_STOP_PROCESSING)
			rulesets_to_process -= ruleset

/**
 * Execute a ruleset and if it needs to process, add it to the list of rulesets to process
**/
/datum/controller/subsystem/dynamic/proc/execute_ruleset(datum/dynamic_ruleset/ruleset)
	if(!ruleset)
		return DYNAMIC_EXECUTE_FAILURE

	if(CHECK_BITFIELD(ruleset.flags, SHOULD_PROCESS_RULESET))
		rulesets_to_process += ruleset

	var/result = ruleset.execute()

	// Since we reuse rulesets we need to empty chosen_candidates
	ruleset.candidates = list()
	ruleset.chosen_candidates = list()
	return result

/**
 * Update our midround points and chances
 * Choose a midround ruleset to save up for if one is not already selected
**/
/datum/controller/subsystem/dynamic/fire(resumed)
	if(forced_extended)
		return

	// Antags have done their jobs, good job guys
	if(SSticker.check_finished() || EMERGENCY_ESCAPED_OR_ENDGAMED || EMERGENCY_CALLED || EMERGENCY_AT_LEAST_DOCKED)
		return

	update_midround_chances()
	update_midround_points()

	// Try to choose/execute a ruleset
	if(world.time - SSticker.round_start_time > midround_grace_period && COOLDOWN_FINISHED(src, midround_ruleset_cooldown))
		if(!midround_chosen_ruleset)
			choose_midround_ruleset()
		else if(midround_points >= midround_chosen_ruleset.points_cost)
			var/result = execute_ruleset(midround_chosen_ruleset)
			message_admins("DYNAMIC: MIDROUND: Executing [midround_chosen_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
			log_dynamic("MIDROUND: Executing [midround_chosen_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")

			// If we successfully execute the midround, apply the cost and log it
			if(result == DYNAMIC_EXECUTE_SUCCESS)
				midround_executed_rulesets += midround_chosen_ruleset
				midround_points -= midround_chosen_ruleset.points_cost
				logged_points["logged_points"] += midround_points
			else
				COOLDOWN_START(src, midround_ruleset_cooldown, midround_failure_stallout)

			midround_chosen_ruleset = null

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA)

/**
 * Generate midround points once per minute based off of each player's status
**/
/datum/controller/subsystem/dynamic/proc/update_midround_points()
	if(world.time - SSticker.round_start_time < midround_grace_period)
		return

	var/previous_midround_points = midround_points

	var/living_delta = length(current_players[CURRENT_LIVING_PLAYERS]) * midround_living_delta
	var/observing_delta = length(current_players[CURRENT_OBSERVERS]) * midround_observer_delta
	var/dead_delta = length(current_players[CURRENT_DEAD_PLAYERS]) * midround_dead_delta

	var/dead_security_delta = 0
	for(var/mob/dead_guy in current_players[CURRENT_DEAD_PLAYERS])
		if(HAS_MIND_TRAIT(dead_guy, TRAIT_SECURITY))
			dead_security_delta += midround_dead_security_delta

	var/antag_delta = 0
	for(var/mob/antag in current_players[CURRENT_LIVING_ANTAGS])
		for(var/datum/antagonist/antag_datum in antag.mind?.antag_datums)
			antag_delta += midround_points_per_antag["[antag_datum.type]"]

	// Add points
	midround_points += max(living_delta + observing_delta + dead_delta + dead_security_delta + antag_delta + midround_linear_delta, 0)
	midround_points += midround_linear_delta_forced

	// Log point sources
	logged_points["logged_points"] += midround_points
	logged_points["logged_points_living"] += living_delta
	logged_points["logged_points_observer"] += observing_delta
	logged_points["logged_points_dead"] += dead_delta
	logged_points["logged_points_dead_security"] += dead_security_delta
	logged_points["logged_points_antag"] += antag_delta
	logged_points["logged_points_linear"] += midround_linear_delta
	logged_points["logged_points_linear_forced"] += midround_linear_delta_forced

	log_dynamic("MIDROUND: Updated points. From [previous_midround_points] to [midround_points]")

/**
 * At roundstart the Light Ruleset Chance is 100%
 * As the round progresses, the Light Ruleset Chance decreases and the Medium/Heavy Ruleset Chance increase
 * After reaching 60 minutes, the Light Ruleset Chance will reach 0%
 * Additionally, the Medium Ruleset Chance will start to decrease and the Heavy Ruleset Chance will increase
**/
/datum/controller/subsystem/dynamic/proc/update_midround_chances()
	// How much should we decrease per minute to reach 0% by the configured time?
	var/light_decrease_rate = midround_light_starting_chance / (midround_light_end_time / (1 MINUTES))

	// Decrease light chance
	midround_light_chance = max(midround_light_chance - light_decrease_rate, 0)

	if(world.time > midround_light_end_time)
		// Light is 0%, lets start to lower Medium
		var/medium_decrease_rate = 100 * midround_medium_increase_ratio / ((midround_medium_end_time - midround_light_end_time) / (1 MINUTES))

		midround_medium_chance = max(midround_medium_chance - medium_decrease_rate, 0)
		midround_heavy_chance = min(midround_heavy_chance + medium_decrease_rate, 100)
	else
		// Increase Medium and Heavy chances
		var/medium_ratio = midround_medium_increase_ratio
		var/heavy_ratio = 1 - medium_ratio

		midround_medium_chance += light_decrease_rate * medium_ratio
		midround_heavy_chance += light_decrease_rate * heavy_ratio

	// Do our best to ensure the total chance is 100%, it honestly probably never will be because of floating point imprecision
	var/total_current_chance = midround_light_chance + midround_medium_chance + midround_heavy_chance
	if(total_current_chance != 100)
		var/adjustment_factor = 100 / total_current_chance
		midround_light_chance *= adjustment_factor
		midround_medium_chance *= adjustment_factor
		midround_heavy_chance *= adjustment_factor

	logged_chances["light"] += midround_light_chance / 10
	logged_chances["medium"] += midround_medium_chance / 10
	logged_chances["heavy"] += midround_heavy_chance / 10

	log_dynamic("MIDROUND: Updated chances: Light: [round(midround_light_chance)]%, Medium: [round(midround_medium_chance)]%, Heavy: [round(midround_heavy_chance)]%")

/**
 * Choose the midround ruleset to save towards
 * * First we choose the severity based off the Light/Medium/Heavy Ruleset Chances
 * * We then pick a midround ruleset of the same severity based of weight
**/
/datum/controller/subsystem/dynamic/proc/choose_midround_ruleset(forced_severity)
	// Pick severity

	if(isnull(forced_severity))
		var/random_value = rand(1, 100)
		if(random_value <= midround_light_chance)
			forced_severity = DYNAMIC_MIDROUND_LIGHT
		else if(random_value <= midround_light_chance + midround_medium_chance)
			forced_severity = DYNAMIC_MIDROUND_MEDIUM
		else
			forced_severity = DYNAMIC_MIDROUND_HEAVY

	// Get possible rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/midround/ruleset in midround_configured_rulesets)
		if(!(ruleset.severity & forced_severity))
			continue

		if(check_is_ruleset_blocked(ruleset, midround_executed_rulesets))
			continue

		ruleset.set_drafted_players_amount()
		ruleset.get_candidates()
		ruleset.trim_candidates()

		if(!ruleset.allowed())
			continue

		possible_rulesets[ruleset] = ruleset.weight

	// Tick down to a lower severity ruleset if there are none of the chosen severity
	if(!length(possible_rulesets))
		var/new_severity

		// Don't love this solution, but whatever
		switch(forced_severity)
			if(DYNAMIC_MIDROUND_HEAVY)
				new_severity = DYNAMIC_MIDROUND_MEDIUM
			if(DYNAMIC_MIDROUND_MEDIUM)
				new_severity = DYNAMIC_MIDROUND_LIGHT

		log_dynamic("MIDROUND: FAIL: Tried to roll a [severity_flag_to_text(forced_severity)] midround but there are no possible rulesets.")

		if(!isnull(new_severity))
			choose_midround_ruleset(new_severity)

		return

	// Pick ruleset and log
	midround_chosen_ruleset = pick_weight(possible_rulesets)
	log_dynamic("MIDROUND: Saving up for a new midround: [midround_chosen_ruleset] (COST: [midround_chosen_ruleset.points_cost])")
	message_admins("DYNAMIC: Saving up for a new midround: [midround_chosen_ruleset] (COST: [midround_chosen_ruleset.points_cost])")

/**
 * Latejoin functionality
 *
 * A maximum of 3 people can be chosen for a latejoin ruleset.
 * There is a 10% chance for someone to be picked
**/
/datum/controller/subsystem/dynamic/proc/on_player_latejoin(mob/living/carbon/human/character)
	if(forced_extended || SSticker.check_finished() || EMERGENCY_ESCAPED_OR_ENDGAMED || EMERGENCY_CALLED)
		return

	if(!length(latejoin_configured_rulesets))
		return

	if(length(latejoin_executed_rulesets) >= latejoin_max_rulesets)
		return

	if(!prob(latejoin_ruleset_probability))
		return

	// No latejoin ruleset chosen, lets pick one
	if(!latejoin_forced_ruleset)
		var/list/possible_rulesets = list()
		for(var/datum/dynamic_ruleset/latejoin/ruleset in latejoin_configured_rulesets)
			possible_rulesets[ruleset] = ruleset.weight

		if(!length(possible_rulesets))
			return

		latejoin_forced_ruleset = pick_weight(possible_rulesets)

	// Execute our latejoin ruleset
	latejoin_forced_ruleset.candidates = list(character)
	var/result = execute_ruleset(latejoin_forced_ruleset)

	message_admins("DYNAMIC: Executing [latejoin_forced_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
	log_dynamic("LATEJOIN: Executing [latejoin_forced_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")

	if(result == DYNAMIC_EXECUTE_SUCCESS)
		latejoin_executed_rulesets += latejoin_forced_ruleset
		latejoin_forced_ruleset = null

/**
 * Checks all high impact rulesets for their round result and sets dynamic's round result to that
**/
/datum/controller/subsystem/dynamic/proc/set_round_result()
	var/list/datum/dynamic_ruleset/executed_rulesets = roundstart_executed_rulesets | midround_executed_rulesets | latejoin_executed_rulesets

	for(var/datum/dynamic_ruleset/ruleset in executed_rulesets)
		if(CHECK_BITFIELD(ruleset.flags, HIGH_IMPACT_RULESET))
			ruleset.round_result()
			if(SSticker.news_report)
				return


/**
 * Returns a list of all the configured rulesets of a specific typepath (/datum/dynamic_ruleset/roundstart, etc...)
**/
/datum/controller/subsystem/dynamic/proc/init_rulesets(datum/dynamic_ruleset/ruleset_subtype)
	var/list/datum/dynamic_ruleset/rulesets = list()

	for(var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
		if(!ruleset_type.name)
			continue
		if(!ruleset_type.weight)
			continue
		if(!ruleset_type.points_cost)
			continue

		rulesets += configure_ruleset(new ruleset_type(src))
	return rulesets

/**
 * Sets the variables of a ruleset to those in the dynamic configuration file
**/
/datum/controller/subsystem/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset)
	var/rule_conf = LAZYACCESSASSOC(dynamic_configuration, ruleset.rule_category, ruleset.name)

	// Set variables
	for(var/variable in rule_conf)
		if(!(variable in ruleset.vars))
			stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.rule_category] [ruleset.name].")
			continue
		ruleset.vars[variable] = rule_conf[variable]

	// Check config for additional restricted_roles
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.restricted_roles |= ruleset.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.restricted_roles |= JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		ruleset.restricted_roles |= SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

	return ruleset

/**
 * This is a frequency selection system. You may imagine it like a raffle where each player can have some number of tickets. The more tickets you have the more likely you are to
 * "win". The default is 100 tickets. If no players use any extra tickets (earned with the antagonist rep system) calling this function should be equivalent to calling the normal
 * pick() function. By default you may use up to 100 extra tickets per roll, meaning at maximum a player may double their chances compared to a player who has no extra tickets.
 *
 * The odds of being picked are simply (your_tickets / total_tickets). Suppose you have one player using fifty (50) extra tickets, and one who uses no extra:
 *     Player A: 150 tickets
 *     Player B: 100 tickets
 *        Total: 250 tickets
 *
 * The odds become:
 *     Player A: 150 / 250 = 0.6 = 60%
 *     Player B: 100 / 250 = 0.4 = 40%
 *  The role_preference argument is optional, but candidates will not use their PERSONAL antag rep if the preference is disabled, rather only using the "base" antag rep.
 *  This is mainly used in the situation where someone is drafted for a ruleset despite having the preference disabled (a feature of gamemodes) - we don't want to spend their rep.
**/
/datum/controller/subsystem/dynamic/proc/antag_pick(list/candidates, role_preference)
	if(!CONFIG_GET(flag/use_antag_rep))
		return pick(candidates)

	// Tickets start at 100
	var/DEFAULT_ANTAG_TICKETS = CONFIG_GET(number/default_antag_tickets)

	// You may use up to 100 extra tickets (double your odds)
	var/MAX_TICKETS_PER_ROLL = CONFIG_GET(number/max_tickets_per_roll)

	var/total_tickets = 0

	MAX_TICKETS_PER_ROLL += DEFAULT_ANTAG_TICKETS

	var/p_ckey
	var/p_rep

	for(var/candidate in candidates)
		var/mob/player
		if(istype(candidate, /datum/mind))
			var/datum/mind/mind = candidate
			p_ckey = ckey(mind.key)
			player = get_mob_by_ckey(p_ckey)
		else if(ismob(candidate))
			player = candidate
			p_ckey = player.ckey
		else
			continue
		if(!player)
			candidates -= candidate
			continue
		var/role_enabled = TRUE
		if(role_preference && player.client)
			role_enabled = player.client.role_preference_enabled(role_preference)
		total_tickets += min((role_enabled ? SSpersistence.antag_rep[p_ckey] : 0) + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)

	var/antag_select = rand(1,total_tickets)
	var/current = 1

	for(var/candidate in candidates)
		var/mob/player
		if(istype(candidate, /datum/mind))
			var/datum/mind/mind = candidate
			p_ckey = ckey(mind.key)
			player = get_mob_by_ckey(p_ckey)
		else if(ismob(candidate))
			player = candidate
			p_ckey = player.ckey
		else
			continue
		p_rep = SSpersistence.antag_rep[p_ckey]
		var/role_enabled = TRUE
		if(role_preference && player.client)
			role_enabled = player.client.role_preference_enabled(role_preference)
		var/previous = current
		var/spend = min((role_enabled ? p_rep : 0) + DEFAULT_ANTAG_TICKETS, MAX_TICKETS_PER_ROLL)
		current += spend

		if(antag_select >= previous && antag_select <= (current-1))
			SSpersistence.antag_rep_change[p_ckey] = -(spend - DEFAULT_ANTAG_TICKETS)
			return candidate

	WARNING("Something has gone terribly wrong. /datum/controller/subsystem/dynamic/antag_pick() failed to select a candidate. Falling back to pick()")
	return pick(candidates)

/datum/controller/subsystem/dynamic/proc/severity_flag_to_text(flag)
	var/texts = list()
	if (flag & DYNAMIC_MIDROUND_LIGHT)
		texts += "LIGHT"
	if (flag & DYNAMIC_MIDROUND_MEDIUM)
		texts += "MEDIUM"
	if (flag & DYNAMIC_MIDROUND_HEAVY)
		texts += "HEAVY"
	return jointext(texts, " | ")
