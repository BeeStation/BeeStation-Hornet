// If this is defined, then any storyteller configs which do not have
// a 'Version' tag that match this value will not be loaded.
// #define STORYTELLER_VERSION "GamemodeAntagonists"


SUBSYSTEM_DEF(dynamic)
	name = "Dynamic"
	runlevels = RUNLEVEL_GAME
	wait = 1 MINUTES


	/**
	 * Setup variables
	 */

	/// The amount of people ready at roundstart
	var/roundstart_ready_amount = 0

	/**
	 * Gamemode variables
	 */

	/// A list of configured gamemodes
	var/list/datum/dynamic_ruleset/gamemode/gamemode_configured_rulesets
	/// List of executed gamemodes
	var/list/datum/dynamic_ruleset/gamemode/gamemode_executed_rulesets = list()
	/// The next gamemode ruleset to be triggered, if we want to trigger one late
	var/datum/dynamic_ruleset/gamemode/gamemode_late_ruleset = null

	/// List of forced gamemode rulesets from the dynamic panel
	var/list/datum/dynamic_ruleset/gamemode/gamemode_forced_rulesets = list()
	/// Are we only permitting gamemodes inside of gamemode_forced_rulesets to execute?
	var/gamemode_whitelist_forced = FALSE
	/// Inverse of the above, blacklist the rulesets in `gamemode_forced_rulesets`
	var/gamemode_blacklist_forced = FALSE

	/**
	 * Supplementary variables
	 */

	/// Set at the beginning of the round, our budget for choosing rulesets
	var/supplementary_points = 0
	/// Only here for logging purposes
	var/supplementary_point_divergence = 1
	/// List of players ready on roundstart. Set to null after players are chosen to prevent hard dels.
	var/list/mob/dead/new_player/authenticated/roundstart_candidates = list()
	/// A list of configured roundstart rulesets
	var/list/datum/dynamic_ruleset/supplementary/supplementary_configured_rulesets

	/// List of all roundstart rulesets that have been executed
	var/list/datum/dynamic_ruleset/supplementary/executed_supplementary_rulesets = list()
	/// The supplementary ruleset that was last executed, used for determining elasticity of late-joins
	var/datum/dynamic_ruleset/supplementary/last_executed_supplementary_path = null
	/// The next supplementary ruleset that we want to save up for
	var/datum/dynamic_ruleset/supplementary/next_supplementary = null

	/// Dynamic Panel variables

	/// List of forced roundstart rulesets from the dynamic panel
	var/list/datum/dynamic_ruleset/supplementary/supplementary_forced_rulesets = list()
	/// Do we choose any roundstart rulesets or only use the ones in `supplementary_forced_rulesets`
	var/supplementary_whitelist_forced = FALSE
	/// Inverse of the above, blacklist the rulesets in `supplementary_forced_rulesets`
	var/supplementary_blacklist_forced = FALSE
	/// Whether or not we ignore our roundstart points calculation
	var/roundstart_points_override = FALSE

	/**
	 * Midround variables
	 */

	/// How many points we currently have to spend on the next midround. Constantly changing
	var/midround_points = 0
	/// List of all midround rulesets that have been executed
	var/list/datum/dynamic_ruleset/midround/midround_executed_rulesets = list()
	/// The midround that we are currently saving points up for.
	var/datum/dynamic_ruleset/midround/midround_chosen_ruleset
	/// A list of configured midround rulesets
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
	 * Other variables
	 */

	/// Can dynamic actually do stuff? Execute midrounds, latejoins, etc.
	var/forced_extended = FALSE
	/// The loaded dynamic configuration file (as a decoded .json file)
	var/list/current_storyteller
	/// An associative list of all of the dynamic storytellers
	/// - "Name" : decoded_json
	var/list/list/dynamic_storyteller_jsons
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
	 */

	/**
	 * Roundstart
	 */

	/// In order to make rounds less predictable, a randomized divergence percentage is applied to the total point value
	/// These should be decimals. i.e: 0.20, 0.75, 1.5
	var/roundstart_divergence_percent_lower = 1
	var/roundstart_divergence_percent_upper = 1
	/// How many roundstart points should be granted per player based off ready status
	var/supplementary_points_per_ready = 1
	var/supplementary_points_per_unready = 0
	var/supplementary_points_per_observer = 0

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
	 */

	/// The chances for each type of midround ruleset to be picked at roundstart
	var/midround_light_starting_chance = 100
	var/midround_medium_starting_chance = 0
	var/midround_heavy_starting_chance = 0
	/// At this time the Light/Medium Ruleset Chance will reach 0%
	/// When configuring these be sure to have them set in deciseconds (minutes * 600)
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
	var/midround_living_delta = 0.04
	var/midround_observer_delta = 0
	var/midround_dead_delta = -0.3
	var/midround_dead_security_delta = -0.6
	var/midround_linear_delta = 0.7
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
		"/datum/antagonist/abductor" = -0.3,
		"/datum/antagonist/abductor/agent" = -0.3,
		"/datum/antagonist/abductor/scientist" = -0.3,
		"/datum/antagonist/abductor/scientist/solo" = -0.3,
		"/datum/antagonist/nightmare" = -0.4
	)

	/// Midround ruleset that is currently waiting to execute
	var/datum/dynamic_ruleset/midround/midround_waiting_ruleset

/datum/controller/subsystem/dynamic/Initialize()
	configure_variables()
	load_storytellers()
	return SS_INIT_SUCCESS

/**
 * Load all of the files from the storytellers directory
 * Only a proc for debugging purposes and in the event a new storyteller is added midround
 */
/datum/controller/subsystem/dynamic/proc/load_storytellers()
	dynamic_storyteller_jsons = list()
	for (var/file_path in flist(DYNAMIC_STORYTELLERS_DIRECTORY))
		var/list/split = splittext(file_path, ".")
		if (!length(split) || split[length(split)] != "json")
			continue

		// Check the json is valid
		var/json_file = file("[DYNAMIC_STORYTELLERS_DIRECTORY][file_path]")
		var/list/loaded_json
		try
			loaded_json = json_decode(file2text(json_file))
		catch (var/exception/error)
			stack_trace("Error while loading: \"[file_path]\" = [error]")
			continue

		var/json_name = loaded_json["Name"]
		if (!json_name)
			stack_trace("Dynamic config: \"[file_path]\" could not be loaded because it did not have a name.")
			continue
		if (!loaded_json["Description"])
			stack_trace("Dynamic config: \"[file_path]\" could not be loaded because it did not have a description.")
			continue

#ifdef STORYTELLER_VERSION
		if (!loaded_json["Version"])
			log_dynamic("Skipped loading storyteller [json_name], it did not provide a storyteller version but one was required. (Required '[STORYTELLER_VERSION]')")
			continue
		if (loaded_json["Version"] != STORYTELLER_VERSION)
			log_dynamic("Skipped loading storyteller [json_name], it did not have the required storyteller version (Required '[STORYTELLER_VERSION]', got '[loaded_json["Version"]]').")
			continue
#else
		if (loaded_json["Version"])
			log_dynamic("Skipped loading storyteller [json_name] as it has a version of '[loaded_json["Version"]]', but we expected none.")
			continue
#endif

		dynamic_storyteller_jsons[json_name] = loaded_json

/datum/controller/subsystem/dynamic/proc/set_storyteller(new_storyteller)
	revert_storyteller_config()

	if (isnull(new_storyteller))
		current_storyteller = null
	else
		ASSERT(dynamic_storyteller_jsons[new_storyteller], "set_storyteller() called with an invalid storyteller")
		current_storyteller = dynamic_storyteller_jsons[new_storyteller]

	configure_variables()

/**
 * Reverts the changed variables of a specific ruleset.
 * This is the least awful way I could think of reliably setting config values back to default when changing storytellers
 */
/datum/controller/subsystem/dynamic/proc/revert_storyteller_config()
	if (!current_storyteller)
		return

	for (var/variable in current_storyteller["Dynamic"])
		if (isnull(vars[variable]))
			stack_trace("Invalid dynamic storyteller variable: [variable]")
			continue
		vars[variable] = initial(vars[variable])

	for (var/datum/dynamic_ruleset/ruleset in gamemode_configured_rulesets)
		configure_ruleset(ruleset, revert_storyteller_config = TRUE)
	for (var/datum/dynamic_ruleset/ruleset in supplementary_configured_rulesets)
		configure_ruleset(ruleset, revert_storyteller_config = TRUE)
	for (var/datum/dynamic_ruleset/ruleset in midround_configured_rulesets)
		configure_ruleset(ruleset, revert_storyteller_config = TRUE)

/**
 * Configure the dynamic variables from the loaded storyteller
 */
/datum/controller/subsystem/dynamic/proc/configure_variables()
	if (current_storyteller)
		for (var/variable in current_storyteller["Dynamic"])
			if (isnull(vars[variable]))
				stack_trace("Invalid dynamic storyteller variable: [variable]")
				continue
			vars[variable] = current_storyteller["Dynamic"][variable]

	gamemode_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/gamemode, gamemode_configured_rulesets)
	supplementary_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/supplementary, supplementary_configured_rulesets)
	midround_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/midround, midround_configured_rulesets)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA_STATIC)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA)

/**
 * Returns a list of all the configured rulesets of a specific ruleset typepath
 * If `preconfigured_rulesets` is passed through, we iterate through all of those instances instead of replacing the pre-existing ones.
 */
/datum/controller/subsystem/dynamic/proc/init_rulesets(datum/dynamic_ruleset/ruleset_subtype, list/datum/dynamic_ruleset/preconfigured_rulesets)
	ASSERT(ispath(ruleset_subtype), "init_rulesets() called without `ruleset_subtype` being a typepath!")

	var/list/datum/dynamic_ruleset/rulesets

	if (length(preconfigured_rulesets))
		rulesets = preconfigured_rulesets
		for (var/datum/dynamic_ruleset/ruleset in rulesets)
			configure_ruleset(ruleset)
	else
		rulesets = list()
		for (var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
			if (!initial(ruleset_type.name))
				continue
			if (!initial(ruleset_type.weight))
				continue
			if (!initial(ruleset_type.points_cost))
				continue

			rulesets += configure_ruleset(new ruleset_type())

	return rulesets

/**
 * Sets the variables of a ruleset to those in the loaded configuration file
 */
/datum/controller/subsystem/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset, revert_storyteller_config = FALSE)
	// Set variables
	if (current_storyteller)
		var/rule_config = LAZYACCESSASSOC(current_storyteller, ruleset.rule_category, ruleset.name)
		for (var/variable in rule_config)
			if (isnull(ruleset.vars[variable]))
				stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.rule_category] [ruleset.name].")
				continue

			if (revert_storyteller_config)
				ruleset.vars[variable] = initial(ruleset.vars[variable])
			else
				ruleset.vars[variable] = rule_config[variable]

	// Check config for additional restricted_roles
	if (CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.restricted_roles |= ruleset.protected_roles
	if (CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.restricted_roles |= JOB_NAME_ASSISTANT
	if (CONFIG_GET(flag/protect_heads_from_antagonist))
		ruleset.restricted_roles |= SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

	return ruleset

/**
 * Called at roundstart, set roundstart points and choose rulesets
 */
/datum/controller/subsystem/dynamic/proc/select_roundstart_antagonists()
	set_roundstart_points()

	log_dynamic("ROUNDSTART: Listing [length(supplementary_configured_rulesets)] roundstart rulesets, and [length(roundstart_candidates)] players ready.")
	if(!length(roundstart_candidates))
		return TRUE

	log_dynamic("Starting a round with the storyteller: \"[current_storyteller?["Name"] || "None"]\"")
	execute_gamemode_roundstart(gamemode_configured_rulesets)
	execute_supplementary_roundstart_rulesets(supplementary_configured_rulesets)

	// Save us from hard dels
	roundstart_ready_amount = length(roundstart_candidates)
	roundstart_candidates = null
	return TRUE

/**
 * Select the gamemode to be ran
 */
/datum/controller/subsystem/dynamic/proc/execute_gamemode_roundstart(list/gamemodes)
	if(forced_extended)
		log_dynamic("GAMEMODE: Starting a round of forced extended.")
		return
	var/list/possible_gamemodes = list()
	// Apply whitelist rules
	if (gamemode_whitelist_forced)
		for (var/datum/dynamic_ruleset/gamemode/forced_gamemode in gamemode_forced_rulesets)
			// It was forced after all
			forced_gamemode.minimum_players_required = 0
			possible_gamemodes += forced_gamemode
	else
		possible_gamemodes = gamemodes.Copy()
	// Apply blacklisting rules
	if (gamemode_blacklist_forced)
		for (var/datum/dynamic_ruleset/gamemode/forced_gamemode in gamemode_forced_rulesets)
			possible_gamemodes -= forced_gamemode
	// Select the ruleset we want
	var/datum/dynamic_ruleset/gamemode/selected_mode = pick_ruleset(get_weighted_rulesets(possible_gamemodes), TRUE)
	// Ignore the user input
	if (!selected_mode && (gamemode_whitelist_forced || gamemode_blacklist_forced))
		log_dynamic("GAMEMODE: Could not find a valid gamemode when filtering rules were applied, attempting to pick gamemode ignoring user rules.")
		message_admins("DYNAMIC: Forced/Banned gamemodes were ignored because a valid gamemode could not be selected with filtering rules applied.")
		selected_mode = pick_ruleset(get_weighted_rulesets(gamemodes), TRUE)
	// Failed to select a moed
	if (!selected_mode)
		log_dynamic("GAMEMODE: Fatal error, could not find any gamemodes to be executed; round will have no primary antagonist.")
		return FALSE
	execute_gamemode_ruleset(selected_mode)
	return TRUE

/**
 * Generate the amount of roundstart points based on how many people are ready
 * and add those ready people to the list of roundstart candidates
 *
 * A randomized divergence is then applied so rounds are less predictable
 */
/datum/controller/subsystem/dynamic/proc/set_roundstart_points()
	for(var/mob/dead/new_player/authenticated/player as anything in GLOB.auth_new_player_list)
		// Add to candidates if ready
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences())
			roundstart_candidates += player

		if(!roundstart_points_override)
			if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences())
				supplementary_points += supplementary_points_per_ready
			else if(player.ready == PLAYER_NOT_READY)
				supplementary_points += supplementary_points_per_unready
			else if(player.ready == PLAYER_READY_TO_OBSERVE)
				supplementary_points += supplementary_points_per_observer

	supplementary_point_divergence = rand() * ((roundstart_divergence_percent_upper) - (roundstart_divergence_percent_lower)) + (roundstart_divergence_percent_lower)
	supplementary_points = round(supplementary_points * supplementary_point_divergence)

	log_dynamic("ROUNDSTART: Starting with [supplementary_points] roundstart points and a divergence of [round((supplementary_point_divergence - 1) * 100)]%")

/**
 * Pick the roundstart rulesets to run based on their configured variables (weight, cost, flags)
 */
/datum/controller/subsystem/dynamic/proc/execute_supplementary_roundstart_rulesets(unfiltered_rules)
	// Extended was forced, don't pick any rulesets
	if(forced_extended)
		log_dynamic("SUPPLEMENTARY: Starting a round of forced extended.")
		return

	// Cancel if the gamemode prevents other rulesets from spawning
	for (var/datum/dynamic_ruleset/gamemode/gamemode in gamemode_executed_rulesets)
		if (gamemode.ruleset_flags & NO_OTHER_RULESETS)
			log_dynamic("SUPPLEMENTARY: A gamemode ruleset has executed which prevents the execution of supplementary rulesets!")
			return

	// Check for forced rulesets
	if(!supplementary_blacklist_forced)
		for(var/datum/dynamic_ruleset/supplementary/forced_ruleset in supplementary_forced_rulesets)
			forced_ruleset.set_drafted_players_amount()
			forced_ruleset.get_candidates()
			forced_ruleset.trim_candidates()
			forced_ruleset.minimum_players_required = 0 // lel

			if(!forced_ruleset.allowed())
				log_dynamic("SUPPLEMENTARY: Could not force [forced_ruleset]")
				message_admins("DYNAMIC: SUPPLEMENTARY: Could not force [forced_ruleset]")
				continue

			var/datum/dynamic_ruleset/supplementary/new_forced_roundstart_ruleset = forced_ruleset.duplicate()
			executed_supplementary_rulesets += new_forced_roundstart_ruleset
			new_forced_roundstart_ruleset.choose_candidates()

			forced_ruleset.candidates = null

			log_dynamic("SUPPLEMENTARY: Forced [new_forced_roundstart_ruleset]")
			message_admins("DYNAMIC: SUPPLEMENTARY: Forced [new_forced_roundstart_ruleset]")

	if(supplementary_whitelist_forced)
		return

	// Trim the rulesets
	var/list/possible_rulesets = get_weighted_executable_rulesets(unfiltered_rules, FALSE)

	// Swap out a gamemode for a supplementary
	var/free_ruleset = !length(gamemode_executed_rulesets)

	// Pick rulesets
	var/no_other_rulesets = FALSE
	while(supplementary_points > 0 && length(possible_rulesets))
		var/datum/dynamic_ruleset/supplementary/new_roundstart_ruleset = pick_ruleset(possible_rulesets, free_ruleset)
		if (!new_roundstart_ruleset)
			log_dynamic("SUPPLEMENTARY: Failed to select a ruleset with [supplementary_points] points left")
			break
		// We only get 1 ruleset for free
		free_ruleset = FALSE
		execute_supplementary_ruleset(new_roundstart_ruleset)

	// Deal with the NO_OTHER_RULESETS flag
	if(no_other_rulesets)
		for(var/datum/dynamic_ruleset/supplementary/ruleset in executed_supplementary_rulesets)
			if(CHECK_BITFIELD(ruleset.ruleset_flags, NO_OTHER_RULESETS))
				continue

			var/are_we_forced = FALSE
			for(var/datum/dynamic_ruleset/supplementary/forced_ruleset in supplementary_forced_rulesets)
				if(ruleset.type == forced_ruleset.type)
					are_we_forced = TRUE
			if(are_we_forced)
				continue

			// Undraft our previously drafted players
			for(var/datum/mind/chosen_candidate in ruleset.chosen_candidates)
				GLOB.pre_setup_antags -= chosen_candidate

				chosen_candidate.special_role = null
				chosen_candidate.restricted_roles = list()

			ruleset.candidates = null
			ruleset.chosen_candidates = null

			log_dynamic("SUPPLEMENTARY: Cancelling [ruleset] because a ruleset with the 'NO_OTHER_RULESETS' was chosen")
			executed_supplementary_rulesets -= ruleset

/datum/controller/subsystem/dynamic/proc/get_weighted_rulesets(list/rulesets)
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/potential_ruleset in rulesets)
		potential_ruleset.set_drafted_players_amount()
		possible_rulesets[potential_ruleset] = potential_ruleset.get_weight()
	return possible_rulesets

/datum/controller/subsystem/dynamic/proc/get_weighted_executable_rulesets(list/rulesets, for_midround = FALSE)
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/potential_ruleset in rulesets)
		potential_ruleset.set_drafted_players_amount()
		if (!for_midround)
			potential_ruleset.get_candidates()
			potential_ruleset.trim_candidates()

		if (for_midround && (potential_ruleset.ruleset_flags & NO_LATE_JOIN))
			log_dynamic("NOT ALLOWED: Ruleset [potential_ruleset.name] had the NO_LATE_JOIN flag set and for_midround was set to TRUE.")
			continue

		if(!potential_ruleset.allowed(require_drafted = !for_midround))
			continue

		if(supplementary_blacklist_forced && (potential_ruleset in supplementary_forced_rulesets))
			log_dynamic("NOT ALLOWED: Ruleset [potential_ruleset.name] was blacklisted.")
			continue

		possible_rulesets[potential_ruleset] = potential_ruleset.get_weight()
	return possible_rulesets

/**
 * Picks a ruleset to be executed. Does not execute the selected ruleset.
 * possible_rulesets: The rulesets to be selected from
 * ignore_points: If set to true, then we will not care about the point cost of this ruleset
 * ignore_candidates: If set to true, then we will not care about needing candidates and trim_candidates will not be called.
 * blacklist_types: If a list is provided, then rulesets whose type is in this list will be excluded.
 */
/datum/controller/subsystem/dynamic/proc/pick_ruleset(list/possible_rulesets, ignore_points = FALSE, ignore_candidates = FALSE, list/blacklist_types = null)
	var/list/remaining_to_pick = possible_rulesets.Copy()

	while (length(remaining_to_pick))
		var/datum/dynamic_ruleset/ruleset = pick_weight(remaining_to_pick)

		// Elasticity selection
		if (istype(ruleset, /datum/dynamic_ruleset/supplementary) && last_executed_supplementary_path && prob(last_executed_supplementary_path::elasticity))
			var/datum/dynamic_ruleset/override_ruleset = locate(last_executed_supplementary_path) in possible_rulesets
			ruleset = override_ruleset
			log_dynamic("PICK_RULESET: Attempting to force-select [ruleset.name] due to the elasticity chance of [last_executed_supplementary_path::elasticity] being met.")

		remaining_to_pick -= ruleset

		// Ran out of rulesets
		if(isnull(ruleset))
			log_dynamic("PICK_RULESET: Ran out of rulesets to select. Returning null.")
			return null

		if (blacklist_types && (ruleset.type in blacklist_types))
			remaining_to_pick -= ruleset
			log_dynamic("PICK_RULESET: Ruleset [ruleset.name] was blacklisted.")
			continue

		// Determine all available candidates, if that's something we care about
		if (!ignore_candidates)
			ruleset.get_candidates()
			ruleset.trim_candidates()
		// Check if we are allowed to be executed
		if(!ruleset.allowed(!ignore_candidates))
			remaining_to_pick -= ruleset
			log_dynamic("PICK_RULESET: Ruleset [ruleset.name] did not have enough candidates.")
			continue

		// Not enough points left
		if(!ignore_points && ruleset.points_cost > supplementary_points)
			remaining_to_pick -= ruleset
			log_dynamic("PICK_RULESET: Ruleset [ruleset.name] did not have enough points ([supplementary_points]/[ruleset.points_cost]).")
			continue

		// check_is_ruleset_blocked()
		if(check_is_ruleset_blocked(ruleset, executed_supplementary_rulesets))
			remaining_to_pick -= ruleset
			log_dynamic("PICK_RULESET: Ruleset [ruleset.name] was blocked.")
			continue

		var/datum/dynamic_ruleset/new_roundstart_ruleset = ruleset.duplicate()
		return new_roundstart_ruleset

/**
 * Execute the provided supplementary ruleset
 */
/datum/controller/subsystem/dynamic/proc/execute_supplementary_ruleset(datum/dynamic_ruleset/supplementary/ruleset)
	// Apply cost and add ruleset to 'executed_supplementary_rulesets'
	supplementary_points -= ruleset.points_cost
	executed_supplementary_rulesets += ruleset
	ruleset.choose_candidates()

	log_dynamic("SUPPLEMENTARY: Executed [ruleset] with [supplementary_points] points left")

	ruleset.candidates = null
	last_executed_supplementary_path = ruleset.type

/**
 * Execute the provided supplementary ruleset
 */
/datum/controller/subsystem/dynamic/proc/execute_gamemode_ruleset(datum/dynamic_ruleset/gamemode/ruleset)
	// Apply cost and add ruleset to 'gamemode_executed_rulesets'
	gamemode_executed_rulesets += ruleset
	ruleset.choose_candidates()

	log_dynamic("GAMEMODE: Executed [ruleset]")

/**
 * Checks if this ruleset is blocked by any other rulesets or ruleset flags.
 * Return TRUE if the ruleset is blocked
 */
/datum/controller/subsystem/dynamic/proc/check_is_ruleset_blocked(datum/dynamic_ruleset/ruleset, list/datum/dynamic_ruleset/applied_rulesets)
	// Check for blocked rulesets
	for(var/datum/dynamic_ruleset/blocked_ruleset_path as anything in ruleset.blocking_rulesets)
		for(var/datum/dynamic_ruleset/executed_ruleset in applied_rulesets)
			if(executed_ruleset.type == blocked_ruleset_path)
				log_dynamic("NOT ALLOWED: [ruleset] was blocked by [initial(blocked_ruleset_path.name)]")
				return TRUE

	// Check for bitflags
	for(var/datum/dynamic_ruleset/other_ruleset in applied_rulesets)
		if(CHECK_BITFIELD(other_ruleset.ruleset_flags, HIGH_IMPACT_RULESET) && CHECK_BITFIELD(ruleset.ruleset_flags, HIGH_IMPACT_RULESET))
			return TRUE

		if(CHECK_BITFIELD(other_ruleset.ruleset_flags, NO_OTHER_RULESETS))
			return TRUE

		if(other_ruleset.type == ruleset.type && CHECK_BITFIELD(other_ruleset.ruleset_flags, CANNOT_REPEAT))
			return TRUE

	return FALSE

/**
 * Execute roundstart rulesets
 */
/datum/controller/subsystem/dynamic/proc/execute_roundstart_rulesets()
	// Gamemodes
	for(var/datum/dynamic_ruleset/gamemode/ruleset in gamemode_executed_rulesets)
		var/result = execute_ruleset(ruleset)

		log_dynamic("GAMEMODE: Executing [ruleset] - [DYNAMIC_EXECUTE_STRINGIFY(result)]")
		if(result != DYNAMIC_EXECUTE_SUCCESS)
			gamemode_executed_rulesets -= ruleset
	// Supplementary
	for(var/datum/dynamic_ruleset/supplementary/ruleset in executed_supplementary_rulesets)
		var/result = execute_ruleset(ruleset)

		log_dynamic("SUPPLEMENTARY: Executing [ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
		if(result != DYNAMIC_EXECUTE_SUCCESS)
			executed_supplementary_rulesets -= ruleset

/**
 * Some rulesets need to process each tick. Lets give them the opportunity to do so.
 */
/datum/controller/subsystem/dynamic/proc/process_rulesets()
	for(var/datum/dynamic_ruleset/ruleset in rulesets_to_process)
		if(ruleset.rule_process() == RULESET_STOP_PROCESSING)
			rulesets_to_process -= ruleset

/**
 * Execute a ruleset and if it needs to process, add it to the list of rulesets to process
 */
/datum/controller/subsystem/dynamic/proc/execute_ruleset(datum/dynamic_ruleset/ruleset)
	var/result = ruleset.execute()
	// Successful execution
	if(result == DYNAMIC_EXECUTE_SUCCESS)
		ruleset.success()

	// I would love to keep this logged, but we must avoid hard dels.
	ruleset.candidates = null
	ruleset.chosen_candidates = null

	return result

/**
 * Update our midround points and chances
 * Choose a midround ruleset to save up for if one is not already selected
 */
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
			var/datum/dynamic_ruleset/midround/new_midround_ruleset = midround_chosen_ruleset.duplicate()

			if (midround_waiting_ruleset)
				midround_waiting_ruleset.abort()
				midround_waiting_ruleset = null

			var/result = execute_ruleset(new_midround_ruleset)
			message_admins("DYNAMIC: MIDROUND: Executing [new_midround_ruleset] - [DYNAMIC_EXECUTE_STRINGIFY(result)]")
			log_dynamic("MIDROUND: Executing [new_midround_ruleset] - [DYNAMIC_EXECUTE_STRINGIFY(result)]")

			if (result == DYNAMIC_EXECUTE_WAITING)
				midround_waiting_ruleset = new_midround_ruleset

			// If we successfully execute the midround, apply the cost and log it
			if(result == DYNAMIC_EXECUTE_SUCCESS || result == DYNAMIC_EXECUTE_WAITING)
				midround_executed_rulesets += new_midround_ruleset
				midround_points -= new_midround_ruleset.points_cost
				logged_points["logged_points"] += midround_points
			else
				COOLDOWN_START(src, midround_ruleset_cooldown, midround_failure_stallout)

			midround_chosen_ruleset = null

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA)

/**
 * Generate midround points once per minute based off of each player's status
 */
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
 */
/datum/controller/subsystem/dynamic/proc/update_midround_chances()
	var/time_elapsed = world.time - SSticker.round_start_time

	// Light decreases linearly until midround_light_end_time
	if (time_elapsed < midround_light_end_time)
		var/light_progress = clamp(time_elapsed / midround_light_end_time, 0, 1)
		midround_light_chance = max(midround_light_starting_chance * (1 - light_progress), 0)

		var/heavy_ratio = 1 - midround_medium_increase_ratio

		midround_medium_chance = light_progress * midround_light_starting_chance * midround_medium_increase_ratio
		midround_heavy_chance = light_progress * midround_light_starting_chance * heavy_ratio
	else
		// After light reaches 0, shift Medium into Heavy until midround_medium_end_time
		var/medium_duration = midround_medium_end_time - midround_light_end_time
		var/medium_progress = clamp((time_elapsed - midround_light_end_time) / medium_duration, 0, 1)

		midround_light_chance = 0
		midround_medium_chance = max(100 * (1 - medium_progress) * midround_medium_increase_ratio, 0)
		midround_heavy_chance = min(100 - midround_medium_chance, 100)

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
 */
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

		// Do not require drafted players to exist for the one we pick
		if(!ruleset.allowed(FALSE))
			continue

		ruleset.candidates = null

		possible_rulesets[ruleset] = ruleset.get_weight()

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
 */
/datum/controller/subsystem/dynamic/proc/on_player_latejoin(mob/living/carbon/human/character)
	log_dynamic("LATEJOIN: Checking latejoin for [character.mind?.name].")
	if(forced_extended || SSticker.check_finished() || EMERGENCY_ESCAPED_OR_ENDGAMED || EMERGENCY_CALLED || EMERGENCY_AT_LEAST_DOCKED)
		log_dynamic("LATEJOIN: Latejoin rejected due to round preparing to end.")
		return

	// Cancel if the gamemode prevents other rulesets from spawning
	for (var/datum/dynamic_ruleset/gamemode/gamemode in gamemode_executed_rulesets)
		if (gamemode.ruleset_flags & NO_OTHER_RULESETS)
			log_dynamic("LATEJOIN: A gamemode ruleset is active with the NO_OTHER_RULESETS flag enabled.")
			return

	// Check if we need to inject a gamemode antagonist
	var/gamemode_executed = FALSE
	for (var/datum/dynamic_ruleset/executed_ruleset in gamemode_executed_rulesets)
		// Ignore removed rulesets
		if (executed_ruleset.removed)
			continue
		gamemode_executed = TRUE
	// Check if a gamemode antagonist is in existance, even if not spawned through us
	for (var/datum/antagonist/antagonist in GLOB.antagonists)
		for (var/datum/dynamic_ruleset/gamemode/gamemode_antagonist as anything in subtypesof(/datum/dynamic_ruleset/gamemode))
			if (gamemode_antagonist::antag_datum && ispath(antagonist.type, gamemode_antagonist))
				gamemode_executed = TRUE
				break
		if (gamemode_executed)
			break
	if (!gamemode_executed)
		if (!gamemode_late_ruleset)
			gamemode_late_ruleset = pick_ruleset(get_weighted_executable_rulesets(gamemode_configured_rulesets, TRUE), ignore_points = TRUE, ignore_candidates = TRUE)
		if (gamemode_late_ruleset)
			var/result = try_late_execute_ruleset(gamemode_late_ruleset, character)
			if (result == DYNAMIC_EXECUTE_SUCCESS)
				gamemode_late_ruleset = null
				return

	supplementary_points += supplementary_points_per_ready * supplementary_point_divergence

	if (!next_supplementary)
		next_supplementary = pick_ruleset(get_weighted_executable_rulesets(supplementary_configured_rulesets, TRUE), ignore_candidates = TRUE)
		if (next_supplementary)
			log_dynamic("LATEJOIN: Selected [next_supplementary.name] as the new supplementary ruleset to save for.")
	if (!next_supplementary)
		log_dynamic("LATEJOIN: Failed to select new supplementary ruleset.")
		return

	if (supplementary_points < next_supplementary.points_cost)
		log_dynamic("LATEJOIN: Could not run [next_supplementary.name], points: [supplementary_points]/[next_supplementary.points_cost]")
		return
	var/result = try_late_execute_ruleset(next_supplementary, character)
	if(result == DYNAMIC_EXECUTE_SUCCESS)
		next_supplementary = null

/datum/controller/subsystem/dynamic/proc/try_late_execute_ruleset(datum/dynamic_ruleset/ruleset, mob/living/carbon/human/character)
	// Execute our latejoin ruleset
	var/datum/dynamic_ruleset/new_latejoin_ruleset = ruleset.duplicate()

	new_latejoin_ruleset.candidates = list(character)
	new_latejoin_ruleset.trim_candidates()
	if (!new_latejoin_ruleset.allowed())
		log_dynamic("LATEJOIN: Could not run [new_latejoin_ruleset]")
		message_admins("DYNAMIC: LATEJOIN: Could not run [new_latejoin_ruleset], moving to next joiner")
		return
	if (istype(new_latejoin_ruleset, /datum/dynamic_ruleset/supplementary))
		execute_supplementary_ruleset(new_latejoin_ruleset)
	else if (istype(new_latejoin_ruleset, /datum/dynamic_ruleset/gamemode))
		execute_gamemode_ruleset(new_latejoin_ruleset)
	else
		CRASH("Attempted to late-execute a ruleset that wasn't supplementary or gamemode.")
	var/result = execute_ruleset(new_latejoin_ruleset)

	message_admins("DYNAMIC: Executing [new_latejoin_ruleset] - [DYNAMIC_EXECUTE_STRINGIFY(result)]")
	log_dynamic("LATEJOIN: Executing [new_latejoin_ruleset] - [DYNAMIC_EXECUTE_STRINGIFY(result)]")
	return result

/**
 * Checks all high impact rulesets for their round result and sets dynamic's round result to that
 */
/datum/controller/subsystem/dynamic/proc/set_round_result()
	var/list/datum/dynamic_ruleset/executed_rulesets = executed_supplementary_rulesets | midround_executed_rulesets | gamemode_executed_rulesets

	for(var/datum/dynamic_ruleset/ruleset in executed_rulesets)
		if(CHECK_BITFIELD(ruleset.ruleset_flags, HIGH_IMPACT_RULESET))
			ruleset.round_result()
			if(SSticker.news_report)
				return

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
 */
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

#ifdef STORYTELLER_VERSION
#undef STORYTELLER_VERSION
#endif
