// If enabled does not accept or execute any rulesets.
GLOBAL_VAR_INIT(dynamic_forced_extended, FALSE)

/*
* pre_setup()
* 	init_rulesets()
* 	configure_ruleset()
* 	pick_roundstart_rulesets()
* post_setup()
* process()
*/

/datum/game_mode/dynamic
	name = "dynamic mode"
	config_tag = "dynamic"
	report_type = "dynamic"

	announce_span = "danger"
	announce_text = "Dynamic mode!" // This needs to be changed maybe

	reroll_friendly = FALSE

	/*
	 * Roundstart variables
	*/

	/// Set at the beginning of the round. Used to purchase rules.
	var/roundstart_points = 0
	/// The list of rulesets to be executed at roundstart
	var/roundstart_executed_rulesets = list()
	/// List of players ready on candidates used on roundstart rulesets.
	var/list/roundstart_candidates = list()

	/*
	 * Midround variables
	*/

	/// A total list of all midrounds executed, for logging purposes
	var/midround_executed_rulesets = list()
	/// How many points we currently have to spend on the next midround. Constantly changing
	var/midround_points = 0
	/// The midround that we are currently saving points up for.
	/// Set in choose_midround_ruleset()
	var/datum/dynamic_ruleset/midround/midround_chosen_ruleset
	/// A list if midround rulesets configured from 'dynamic.json'
	var/list/configured_midround_rulesets

	/// The chances for each type of midround ruleset to be picked
	/// Set in pre_setup()
	var/midround_light_chance
	var/midround_medium_chance
	var/midround_heavy_chance

	/*
	 * Other variables
	*/

	/// Dynamic configuration, loaded on 'pre_setup' from 'dynamic.json'
	var/list/dynamic_configuration = null
	/// Some rulesets (like revolution) need to process
	var/list/rulesets_to_process = list()

	/*
	 * Configurable variables
	 * All of these variables can be customized in 'dynamic.json'
	*/

	/// Roundstart

	/// In order to make rounds less predictable, a randomized divergence percentage is applied to the total point value
	/// These should always be decimals. e.g: 0.8, 1.4
	var/roundstart_divergence_percent_lower = DYNAMIC_POINT_DIVERGENCE_LOWER
	var/roundstart_divergence_percent_upper = DYNAMIC_POINT_DIVERGENCE_UPPER
	/// How many roundstart points should be granted per player based off their ready status (OBSERVING, READY, UNREADY)
	var/roundstart_points_per_ready = DYNAMIC_POINTS_PER_READY
	var/roundstart_points_per_unready = DYNAMIC_POINTS_PER_UNREADY
	var/roundstart_points_per_observer = DYNAMIC_POINTS_PER_OBSERVER

	/// Midround

	/// The chances for each type of midround ruleset to be picked
	var/midround_light_starting_chance = DYNAMIC_MIDROUND_LIGHT_STARTING_CHANCE
	var/midround_medium_starting_chance = DYNAMIC_MIDROUND_MEDIUM_STARTING_CHANCE
	var/midround_heavy_starting_chance = DYNAMIC_MIDROUND_HEAVY_STARTING_CHANCE
	/// At this time the chance for a Light or Medium midround will reach 0%
	/// When configuring these in 'dynamic.json' be sure to have them set in deciseconds (minutes * 600)
	var/midround_light_end_time = DYNAMIC_MIDROUND_LIGHT_END_TIME
	var/midround_medium_end_time = DYNAMIC_MIDROUND_MEDIUM_END_TIME
	/// What percent of the Light Point Decrease should be given to the Medium Ruleset Chance
	/// The heavy ratio is calculated by doing 1 - midround_medium_increase_ratio
	var/midround_medium_increase_ratio = DYNAMIC_MIDROUND_INCREASE_RATIO
	/// The time at which midrounds can start
	var/midround_grace_period = DYNAMIC_MIDROUND_GRACEPERIOD

// Yes, this is copy pasted from game_mode
/datum/game_mode/dynamic/check_finished(force_ending)
	if(!SSticker.setup_done || !gamemode_ready)
		return FALSE
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

/datum/game_mode/dynamic/can_start()
	return TRUE

/*
* Load dynamic.json
* Configure roundstart_rulesets variables
* Set roundstart points
* Pick rulesets to execute
*/
/datum/game_mode/dynamic/pre_setup()
	// Load the 'dynamic.json' configurations
	if(CONFIG_GET(flag/dynamic_config_enabled))
		var/json_file = file("config/dynamic.json")
		if(fexists(json_file))
			dynamic_configuration = json_decode(file2text(json_file))
			if(dynamic_configuration["Dynamic"])
				for(var/variable in dynamic_configuration["Dynamic"])
					if(!vars[variable])
						stack_trace("Invalid dynamic configuration variable [variable] in game mode variable changes.")
						continue
					vars[variable] = dynamic_configuration["Dynamic"][variable]

	midround_light_chance = midround_light_starting_chance
	midround_medium_chance = midround_medium_starting_chance
	midround_heavy_chance = midround_heavy_starting_chance

	// Apply 'dynamic.json' configurations into each roundstart ruleset
	var/list/configured_roundstart_rulesets = init_rulesets(/datum/dynamic_ruleset/roundstart)

	// Set our points according to pop and a bit of RNG
	set_roundstart_points()

	// Log stuff
	if(length(roundstart_candidates))
		log_game("DYNAMIC: Listing [length(configured_roundstart_rulesets)] round start rulesets, and [length(roundstart_candidates)] players ready.")
	else
		log_game("DYNAMIC: FAIL: no roundstart candidates.")
		return TRUE

	// Pick rulesets to be executed from 'configured_roundstart_rulesets'
	pick_roundstart_rulesets(configured_roundstart_rulesets)
	return TRUE

/*
* Returns a list of all ruleset types (Roundstart, Midround, Latejoin) and configures their variables by calling configure_ruleset()
*/
/datum/game_mode/dynamic/proc/init_rulesets(ruleset_subtype)
	var/list/rulesets = list()

	for(var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
		if(!ruleset_type.name)
			continue
		if(!ruleset_type.weight)
			continue

		rulesets += configure_ruleset(new ruleset_type(src))
	return rulesets

/*
* Sets the variables of this ruleset to those in the dynamic.json file
*/
/datum/game_mode/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset)
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

/*
* Ready players add 1
* Unready players add 0.5
* Observing players add 0
* TODO: make these config values
* Add some RNG at the end so we don't have super predictable rounds
*/
/datum/game_mode/dynamic/proc/set_roundstart_points()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(!player.mind || player.ready == PLAYER_READY_TO_OBSERVE)
			roundstart_points += roundstart_points_per_observer
			continue
		if(player.ready == PLAYER_READY_TO_PLAY)
			roundstart_points += roundstart_points_per_ready
			roundstart_candidates.Add(player)
			continue
		else
			roundstart_points += roundstart_points_per_unready

	roundstart_points *= rand(roundstart_divergence_percent_lower, roundstart_divergence_percent_upper)

	roundstart_points = round(roundstart_points, 1)

/*
* Pick the roundstart rulesets to run based off of their configured variables (weight, cost, etc.)
*/
/datum/game_mode/dynamic/proc/pick_roundstart_rulesets(roundstart_rules)
	// Extended was forced, don't pick any rulesets
	if(GLOB.dynamic_forced_extended)
		log_game("DYNAMIC: Starting a round of forced extended.")
		return TRUE

	// Trim the rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_rules)
		if(!ruleset.weight)
			continue
		if(!ruleset.points_cost)
			continue

		ruleset.candidates = roundstart_candidates.Copy()
		ruleset.trim_candidates()

		if(!ruleset.allowed())
			continue

		possible_rulesets[ruleset] = ruleset.weight

	// Pick rulesets
	var/roundstart_points_left = roundstart_points
	while(roundstart_points_left > 0)
		var/datum/dynamic_ruleset/roundstart/ruleset = pick_weight_allow_zero(possible_rulesets)

		// Ran out of rulesets
		if(isnull(ruleset))
			log_game("DYNAMIC: No more rulesets can be applied, stopping with [roundstart_points_left] points left.")
			break

		// Something changed and this ruleset is no longer allowed
		// Most common occurance is all previous candidates were assigned an antag position
		ruleset.trim_candidates()
		if(!ruleset.allowed())
			possible_rulesets[ruleset] = null
			continue

		// Not enough points left
		if(ruleset.points_cost > roundstart_points_left)
			possible_rulesets[ruleset] = null
			continue

		// check_is_ruleset_blocked()
		if(check_is_ruleset_blocked(ruleset, roundstart_executed_rulesets))
			possible_rulesets[ruleset] = null
			continue

		// Apply cost and add ruleset to 'roundstart_executed_rulesets'
		roundstart_points_left -= ruleset.points_cost
		roundstart_executed_rulesets[ruleset] += 1
		ruleset.pre_execute()

		log_game("DYNAMIC: Chose [ruleset] with [roundstart_points_left] points left")

/*
* Checks if a ruleset is allowed to run based off of the other ruleset flags.
*/
/datum/game_mode/dynamic/proc/check_is_ruleset_blocked(datum/dynamic_ruleset/ruleset, applied_rulesets)
	// Check for blocked rulesets
	if(length(ruleset.blocking_rulesets))
		for(var/datum/dynamic_ruleset/blocked_ruleset in ruleset.blocking_rulesets)
			for(var/datum/dynamic_ruleset/executed_ruleset in applied_rulesets)
				if(blocked_ruleset.type == executed_ruleset.type)
					log_game("DYNAMIC: FAIL: [ruleset] blocked by [blocked_ruleset]")
					return TRUE

	for(var/datum/dynamic_ruleset/other_ruleset in applied_rulesets)
		// Check for 'HIGH_IMPACT_RULESET'
		if(CHECK_BITFIELD(other_ruleset.flags, HIGH_IMPACT_RULESET) && CHECK_BITFIELD(ruleset.flags, HIGH_IMPACT_RULESET))
			return TRUE

		// Check for 'LONE_RULESET'
		if(other_ruleset.type == ruleset.type && CHECK_BITFIELD(other_ruleset.flags, LONE_RULESET))
			return TRUE
	return FALSE

/*
* Execute all roundstart rulesets and initiate midrounds
*/
/datum/game_mode/dynamic/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_executed_rulesets)
		execute_ruleset(ruleset)

	init_midround()
	. = ..()

/*
* Some rulesets need to process each tick. Lets give them the opportunity to do so.
*/
/datum/game_mode/dynamic/process()
	for(var/datum/dynamic_ruleset/rule in rulesets_to_process)
		if(rule.rule_process() == RULESET_STOP_PROCESSING)
			rulesets_to_process -= rule

/*
* Execute a ruleset and if it needs to process, add it to the list
*/
/datum/game_mode/dynamic/proc/execute_ruleset(datum/dynamic_ruleset/ruleset)
	ruleset.execute()

	if(CHECK_BITFIELD(ruleset.flags, SHOULD_PROCESS_RULESET))
		rulesets_to_process += ruleset

/*
* Configure the midround rulesets from 'dynamic.json' and start rolling midrounds
*/
/datum/game_mode/dynamic/proc/init_midround()
	configured_midround_rulesets = init_rulesets(/datum/dynamic_ruleset/roundstart)

	addtimer(CALLBACK(src, PROC_REF(try_midround_roll)), 1 MINUTES, TIMER_LOOP)

/*
* Set the chosen midround ruleset based off a severity
* Leave the 'severity' variable blank if you want to pick from any midround type
*/
/datum/game_mode/dynamic/proc/try_midround_roll()
	update_midround_points()
	update_midround_chances()

	if(midround_chosen_ruleset)
		if(midround_points >= midround_chosen_ruleset.points_cost)
			execute_ruleset(midround_chosen_ruleset)
			midround_executed_rulesets += midround_chosen_ruleset
			midround_chosen_ruleset = null
	else if(world.time >= DYNAMIC_MIDROUND_GRACEPERIOD)
		choose_midround_ruleset()


/datum/game_mode/dynamic/proc/update_midround_points()
	var/previous_midround_points = midround_points
	midround_points++

	log_game("DYNAMIC: Updated midround points. [previous_midround_points] --> [midround_points]")

/*
* At roundstart the chance for a Light ruleset to spawn is 100%
* As the round progresses, this chance will decrease and the chance to spawn a Medium and Heavy ruleset will increase.
* After reaching 60 minutes the chance for a Light ruleset to spawn will reach 0%
* Alongside this, the chance to roll a Medium ruleset will start to decrease and the chance to roll a Heavy ruleset will increase.
*/
/datum/game_mode/dynamic/proc/update_midround_chances()
	// How much should we decrease per minute to reach 0% by the configured time?
	var/light_decrease_rate = midround_light_starting_chance / (midround_light_end_time / (1 MINUTES))

	// Decrease light chance
	midround_light_chance = max(0, midround_light_chance - light_decrease_rate)

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

    // Ensure the total chance is 100%
	var/total_current_chance = midround_light_chance + midround_medium_chance + midround_heavy_chance
	if(total_current_chance != 100)
		var/adjustment_factor = 100 / total_current_chance
		midround_light_chance *= adjustment_factor
		midround_medium_chance *= adjustment_factor
		midround_heavy_chance *= adjustment_factor

	log_game("DYNAMIC: Updated midround chances: Light: [midround_light_chance]%, Medium: [midround_medium_chance]%, Heavy: [midround_heavy_chance]%")

/*
* Choose the midround ruleset to save towards
*/
/datum/game_mode/dynamic/proc/choose_midround_ruleset()
	if(!length(configured_midround_rulesets))
		stack_trace("configured_midround_rulesets is empty.")
		return

	// Pick severity
	var/severity
	var/random_value = rand(1, 100)
	if(random_value <= midround_light_chance)
		severity = DYNAMIC_MIDROUND_LIGHT
	else if(random_value <= midround_light_chance + midround_medium_chance)
		severity = DYNAMIC_MIDROUND_MEDIUM
	else
		severity = DYNAMIC_MIDROUND_HEAVY

	// Get possible rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/midround/rule in configured_midround_rulesets)
		if(!rule.weight)
			continue
		if(!rule.allowed())
			continue
		if(severity && rule.severity != severity)
			continue

		rule.trim_candidates()
		possible_rulesets[rule] = rule.weight

	midround_chosen_ruleset = pick_weight_allow_zero(possible_rulesets)
	log_game("DYNAMIC: A new midround has been chosen to save up for: [midround_chosen_ruleset]")

/*
* latejoin
*/
/*
/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/newPlayer)
	if(GLOB.dynamic_forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED) // No more rules after the shuttle has left
		return

	if (forced_latejoin_rule)
		forced_latejoin_rule.roundstart_candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		log_game("DYNAMIC: Forcing ruleset [forced_latejoin_rule]")
		if (forced_latejoin_rule.ready(TRUE))
			if (!forced_latejoin_rule.repeatable)
				latejoin_rules = remove_from_list(latejoin_rules, forced_latejoin_rule.type)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/game_mode/dynamic, execute_midround_latejoin_rule), forced_latejoin_rule), forced_latejoin_rule.delay)
		forced_latejoin_rule = null

	else if (latejoin_injection_cooldown < get_time() && (forced_injection || prob(latejoin_roll_chance)))
		forced_injection = FALSE

		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (!rule.weight)
				continue
			if (CHECK_BITFIELD(rule.flags, INTACT_STATION_RULESET) && !is_station_intact())
				continue
			if (rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len, threat_level) && (mid_round_budget >= rule.cost || is_lategame()))
				// No stacking : only one round-ender, unless threat level > stacking_limit.
				if (threat_level < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
					if(CHECK_BITFIELD(rule.flags, HIGH_IMPACT_RULESET) && high_impact_ruleset_active())
						continue

				rule.roundstart_candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && pick_latejoin_rule(drafted_rules))
			var/latejoin_injection_cooldown_middle = 0.5*(latejoin_delay_max + latejoin_delay_min)
			latejoin_injection_cooldown = round(clamp(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), latejoin_delay_min, latejoin_delay_max)) + get_time()
*/

/*
* Station intercept to alert the crew that its not a greenshift
*/
/datum/game_mode/dynamic/send_intercept()
	priority_announce("A summary has been copied and printed to all communications consoles.", "Security level elevated.", ANNOUNCER_INTERCEPT)
	if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
		SSsecurity_level.set_level(SEC_LEVEL_BLUE)
