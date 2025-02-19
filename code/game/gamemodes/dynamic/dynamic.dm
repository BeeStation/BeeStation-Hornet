// Are HIGH_IMPACT_RULESETs allowed to stack?
GLOBAL_VAR_INIT(dynamic_no_stacking, TRUE)
// If enabled does not accept or execute any rulesets.
GLOBAL_VAR_INIT(dynamic_forced_extended, FALSE)
// How high threat is required for HIGH_IMPACT_RULESETs stacking.
// This is independent of dynamic_no_stacking.
GLOBAL_VAR_INIT(dynamic_stacking_limit, 90)
// List of forced roundstart rulesets.
GLOBAL_LIST_EMPTY(dynamic_forced_roundstart_ruleset)
// Forced threat level, setting this to zero or higher forces the roundstart threat to the value.
GLOBAL_VAR_INIT(dynamic_forced_threat_level, -1)

/*
* pre_setup()
* init_rulesets()
* configure_ruleset()
* pick_roundstart_rulesets()
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
	 * Roundstart
	*/

	/// Set at the beginning of the round. Spent to 'purchase' rules.
	var/roundstart_points = 0
	/// The list of rulesets to be executed at roundstart
	var/executed_roundstart_rulesets = list()
	/// List of candidates used on roundstart rulesets.
	var/list/roundstart_candidates = list()

	/*
	 * Other variables
	*/

	/// Dynamic configuration, loaded on pre_setup from 'dynamic.json'
	var/list/dynamic_configuration = null
	/// Some rulesets (like revolution) need to process
	var/list/rulesets_to_process = list()



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
	// Load the dynamic.json configurations
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

	// Load dynamic.json configurations into each roundstart ruleset
	var/list/configured_roundstart_rulesets = init_rulesets(/datum/dynamic_ruleset/roundstart)

	/*
	 * Ready players add 1
	 * Unready players add 0.5
	 * Observing players add 0
	 * TODO: make these config values
	*/
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(!player.mind || player.ready == PLAYER_READY_TO_OBSERVE)
			continue
		if(player.ready == PLAYER_READY_TO_PLAY)
			roundstart_points += 1
			roundstart_candidates.Add(player)
		else
			roundstart_points += 0.5
	roundstart_points = round(roundstart_points, 1)

	// Log ready the configured roundstart rulesets and ready players
	log_game("DYNAMIC: Listing [configured_roundstart_rulesets.len] round start rulesets, and [roundstart_candidates.len] players ready.")
	if(!length(roundstart_candidates))
		log_game("DYNAMIC: FAIL: [roundstart_candidates.len] roundstart_candidates.")
		return TRUE

	// Pick rulesets to be executed from 'configured_roundstart_rulesets'
	if(length(GLOB.dynamic_forced_roundstart_ruleset))
		//rigged_roundstart()
	else
		pick_roundstart_rulesets(configured_roundstart_rulesets)

/*
* Returns a list of all ruleset types (roundstart, midround, latejoin)
* Then configures their variables via configure_ruleset()
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
			stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.ruletype] [ruleset.name].")
			continue
		ruleset.vars[variable] = rule_conf[variable]

	// Check config for additional banned_roles
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.banned_roles |= ruleset.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.banned_roles |= JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		ruleset.banned_roles |= SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)
	return ruleset

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
	for(var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if(!rule.weight)
			continue
		if(roundstart_points < rule.minimum_points_required)
			log_game("DYNAMIC: FAIL: [rule.name] is not allowed: The minimum point requirement (minimum: [rule.minimum_points_required]) was not met! (points: [roundstart_points])")
			continue

		rule.candidates = roundstart_candidates.Copy()
		rule.trim_candidates()

		if(rule.allowed)
			possible_rulesets[rule] = rule.weight

	// Pick rulesets
	var/roundstart_points_left = roundstart_points
	while(roundstart_points_left > 0)
		var/datum/dynamic_ruleset/roundstart/ruleset = pick_weight_allow_zero(possible_rulesets)

		// Uh oh, ran out of rulesets
		if(isnull(ruleset))
			log_game("DYNAMIC: No more rules can be applied, stopping with [roundstart_points_left] points left.")
			break

		// Not enough points left
		if(ruleset.points_cost > roundstart_points_left)
			possible_rulesets[ruleset] = null
			continue

		// check_is_ruleset_blocked()
		if(check_is_ruleset_blocked(ruleset, executed_roundstart_rulesets))
			possible_rulesets[ruleset] = null
			continue

		// Apply cost and add ruleset to 'executed_roundstart_rulesets'
		roundstart_points_left -= ruleset.points_cost
		executed_roundstart_rulesets += ruleset

		if(CHECK_BITFIELD(ruleset.flags, SHOULD_PROCESS_RULESET))
			rulesets_to_process += ruleset

/*
* Checks if a ruleset is allowed to run based off of the other ones.
* A blood and clock cult cannot both run
* Two rulesets with the 'HIGH_IMPACT_RULESET' cannot run
* Returns TRUE if blocked and FALSE if allowed
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

		// Check for 'NO_OTHER_ROUNDSTARTS_RULESET'
		if(CHECK_BITFIELD(other_ruleset.flags, NO_OTHER_ROUNDSTARTS_RULESET))
			return TRUE

		// Check for 'LONE_RULESET'
		if(other_ruleset.type == ruleset.type && CHECK_BITFIELD(other_ruleset.flags, LONE_RULESET))
			return TRUE
	return FALSE

/*
* Execute all roundstart rulesets
*/
/datum/game_mode/dynamic/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/rule in executed_roundstart_rulesets)
		rule.execute()
	. = ..()

/*
* Some rulesets (like revolution) need to process each tick. Lets give them the opportunity to do so.
* Also try for midrounds.
*/
/datum/game_mode/dynamic/process()
	for(var/datum/dynamic_ruleset/rule in rulesets_to_process)
		if(rule.rule_process() == RULESET_STOP_PROCESSING) // If rule_process() returns 1 (RULESET_STOP_PROCESSING), stop processing.
			rulesets_to_process -= rule

	// TODO: try_midround_roll()

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
