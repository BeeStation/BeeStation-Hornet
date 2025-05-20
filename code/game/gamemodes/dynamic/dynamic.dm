// If enabled does not accept or execute any rulesets.
GLOBAL_VAR_INIT(dynamic_forced_extended, FALSE)

/*
* Order of operations
*
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
	/// Only here for logging purposes
	var/roundstart_point_divergence = 1
	/// List of all roundstart rulesets that have been executed
	var/roundstart_executed_rulesets = list()
	/// List of players ready on candidates used on roundstart rulesets.
	var/list/roundstart_candidates = list()

	/*
	 * Midround variables
	*/

	/// List of all midround rulesets that have been executed
	var/midround_executed_rulesets = list()
	/// How many points we currently have to spend on the next midround. Constantly changing
	var/midround_points = 0
	/// The midround that we are currently saving points up for.
	var/datum/dynamic_ruleset/midround/midround_chosen_ruleset
	/// A list if midround rulesets configured from 'dynamic.json'
	var/list/midround_configured_rulesets

	/// The chances for each type of midround ruleset to be picked
	/// Set in init_midround()
	var/midround_light_chance
	var/midround_medium_chance
	var/midround_heavy_chance

	/*
	 * Latejoin variables
	*/

	/// List of all roundstart rulesets that have been executed
	var/latejoin_executed_rulesets = list()
	/// Only defined for admin interaction purposes
	var/datum/dynamic_ruleset/latejoin/latejoin_forced_ruleset
	/// A list if latejoin rulesets configured from 'dynamic.json'
	var/list/latejoin_configured_rulesets

	/*
	 * Other variables
	*/

	/// Dynamic configuration, loaded on 'pre_setup' from 'dynamic.json'
	var/list/dynamic_configuration = null
	/// Some rulesets (like revolution) need to process
	var/list/rulesets_to_process = list()

	/*
	 * Configurable variables
	 * All of these can be changed in 'dynamic.json'
	 * None of the variables above should be configured!
	*/

	/*
	 * Roundstart
	*/

	/// In order to make rounds less predictable, a randomized divergence percentage is applied to the total point value
	/// These should be decimals. i.e: 0.20, 0.75, 1.5
	var/roundstart_divergence_percent_lower = 0.8
	var/roundstart_divergence_percent_upper = 1.4
	/// How many roundstart points should be granted per player based off ready status (OBSERVING, READY, UNREADY)
	var/roundstart_points_per_ready = 1
	var/roundstart_points_per_unready = 0.5
	var/roundstart_points_per_observer = 0

	/*
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
	 * The rest is pretty simple, the chosen midround ruleset is picked based off
	 * the Light/Medium/Heavy Ruleset Chances and once chosen
	 * we will save up until we have enough points to execute it.
	*/

	/// The chances for each type of midround ruleset to be picked at roundstart, by default this is 100%, 0%, 0%
	var/midround_light_starting_chance = 100
	var/midround_medium_starting_chance = 0
	var/midround_heavy_starting_chance = 0
	/// At this time the Light/Medium Ruleset Chance will reach 0%
	/// When configuring these in 'dynamic.json' be sure to have them set in deciseconds (minutes * 600)
	var/midround_light_end_time = 60 MINUTES
	var/midround_medium_end_time = 90 MINUTES
	/// The ratio of the Light Ruleset Chance decrease rate that is given to the Medium Ruleset Chance
	/// The Heavy Ratio is the remainder of the Medium Increase Ratio
	/// These should always be on a range of 0 - 1. i.e: 0.25, 0.75, 1.0
	var/midround_medium_increase_ratio = 0.75
	/// The time at which midrounds can start rolling
	var/midround_grace_period = 15 MINUTES
	/// The amount of midround points given per minute for every type of player
	var/midround_points_per_living = 0.1
	var/midround_points_per_observer = 0
	var/midround_points_per_dead = -0.2
	/// Every time we update midround points we add this value to the points and to itself
	/// For example: Minute 1, +0.05. Minute 2, +0.1. Minute 3, +0.15...
	var/midround_linear_point_increase = 0.05

	/*
	 * Latejoin
	*/

	/// The max amount of latejoin rulesets that can be picked
	var/latejoin_max_rulesets = 3
	/// The probability for a latejoin ruleset to be picked
	var/latejoin_ruleset_probability = 10


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
* Load 'dynamic.json'
* Configure roundstart_rulesets variables
* Set roundstart points
* Pick rulesets to execute
*/
/datum/game_mode/dynamic/pre_setup()
	// Ok, this is stupid and should be a TEMPORARY solution
	// Dynamic is not initialized until roundstart... for some reason
	// Which MEANS anyone that started observing before roundstart is not added to current_players[CURRENT_OBSERVERS], thus blacklisting them from ghost roles
	// So, lets go over every observer in GLOB.player_list and add them to dynamic's list of observers
	for(var/mob/player in GLOB.player_list)
		if(isobserver(player))
			var/mob/dead/observer/observer_player = player
			current_players[CURRENT_OBSERVERS] |= observer_player

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

	// Apply 'dynamic.json' configurations into each roundstart ruleset
	var/list/configured_roundstart_rulesets = init_rulesets(/datum/dynamic_ruleset/roundstart)

	// Set our roundstart points
	set_roundstart_points()

	log_dynamic("ROUNDSTART: Listing [length(configured_roundstart_rulesets)] roundstart rulesets, and [length(roundstart_candidates)] players ready.")
	if(!length(roundstart_candidates))
		return TRUE

	// Pick rulesets to be executed from 'configured_roundstart_rulesets'
	pick_roundstart_rulesets(configured_roundstart_rulesets)
	return TRUE

/*
* Returns a list of all ruleset types (Roundstart, Midround, Latejoin) and configures their variables by calling configure_ruleset()
*/
/datum/game_mode/dynamic/proc/init_rulesets(datum/dynamic_ruleset/ruleset_subtype)
	var/list/rulesets = list()

	for(var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
		if(!ruleset_type.name)
			continue
		if(!ruleset_type.weight)
			continue
		if(!ruleset_type.points_cost)
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
* Roundstart points are calculated per player's ready status
* A randomized divergence is applied so we don't have super predictable rounds
*/
/datum/game_mode/dynamic/proc/set_roundstart_points()
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(!player.mind || player.ready == PLAYER_READY_TO_OBSERVE)
			roundstart_points += roundstart_points_per_observer
			continue
		if(player.ready == PLAYER_READY_TO_PLAY)
			roundstart_points += roundstart_points_per_ready
			roundstart_candidates.Add(player)
			continue
		else
			roundstart_points += roundstart_points_per_unready

	// Kapu wrote this code for the randomized point divergence
	roundstart_point_divergence = rand() * ((roundstart_divergence_percent_upper) - (roundstart_divergence_percent_lower)) + (roundstart_divergence_percent_lower)
	roundstart_points = round(roundstart_points * roundstart_point_divergence, 1)

	log_dynamic("ROUNDSTART: Starting with [roundstart_points] roundstart points and a divergence of [round((roundstart_point_divergence - 1) * 100, 1)]%")

/*
* Pick the roundstart rulesets to run based off of their configured variables (weight, cost, etc.)
*/
/datum/game_mode/dynamic/proc/pick_roundstart_rulesets(roundstart_rules)
	// Extended was forced, don't pick any rulesets
	if(GLOB.dynamic_forced_extended)
		log_dynamic("ROUNDSTART: Starting a round of forced extended.")
		return

	// Trim the rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_rules)
		ruleset.set_drafted_players_amount()
		ruleset.get_candidates()
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
			log_dynamic("ROUNDSTART: No more rulesets can be applied, stopping with [roundstart_points_left] points left.")
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

		roundstart_executed_rulesets[ruleset] += 1 // We do this here and not in post_setup() because there will be rulesets that this one will block
		ruleset.choose_candidates()

		log_dynamic("ROUNDSTART: Chose [ruleset] with [roundstart_points_left] points left")

/*
* Checks if a ruleset is allowed to run based off of the other ruleset flags.
*/
/datum/game_mode/dynamic/proc/check_is_ruleset_blocked(datum/dynamic_ruleset/ruleset, applied_rulesets)
	// Check for blocked rulesets
	if(length(ruleset.blocking_rulesets))
		for(var/datum/dynamic_ruleset/blocked_ruleset in ruleset.blocking_rulesets)
			for(var/datum/dynamic_ruleset/executed_ruleset in applied_rulesets)
				if(blocked_ruleset.type == executed_ruleset.type)
					log_dynamic("NOT ALLOWED: [ruleset] blocked by [blocked_ruleset]")
					return TRUE

	for(var/datum/dynamic_ruleset/other_ruleset in applied_rulesets)
		// Check for 'HIGH_IMPACT_RULESET'
		if(CHECK_BITFIELD(other_ruleset.flags, HIGH_IMPACT_RULESET) && CHECK_BITFIELD(ruleset.flags, HIGH_IMPACT_RULESET))
			return TRUE

		// Check for 'CANNOT_REPEAT'
		if(other_ruleset.type == ruleset.type && CHECK_BITFIELD(other_ruleset.flags, CANNOT_REPEAT))
			return TRUE
	return FALSE

/*
* Execute all roundstart rulesets and initiate midrounds
*/
/datum/game_mode/dynamic/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/ruleset in roundstart_executed_rulesets)
		var/result = execute_ruleset(ruleset)

		log_dynamic("ROUNDSTART: Executing [ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
		if(result != DYNAMIC_EXECUTE_SUCCESS)
			roundstart_executed_rulesets[ruleset] -= 1

	init_midround()

	// Configure Latejoin rulesets
	latejoin_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/latejoin)
	if(!length(latejoin_configured_rulesets))
		stack_trace("DYNAMIC: latejoin_configured_rulesets is empty. It is impossible to roll latejoins")

	. = ..()

/*
* Some rulesets need to process each tick. Lets give them the opportunity to do so.
*/
/datum/game_mode/dynamic/process()
	for(var/datum/dynamic_ruleset/ruleset in rulesets_to_process)
		if(ruleset.rule_process() == RULESET_STOP_PROCESSING)
			rulesets_to_process -= ruleset

/*
* Execute a ruleset and if it needs to process, add it to the list of rulesets to process
*/
/datum/game_mode/dynamic/proc/execute_ruleset(datum/dynamic_ruleset/ruleset)
	if(!ruleset)
		return DYNAMIC_EXECUTE_FAILURE

	if(CHECK_BITFIELD(ruleset.flags, SHOULD_PROCESS_RULESET))
		rulesets_to_process += ruleset

	return ruleset.execute()

/*
* Configure the midround rulesets from 'dynamic.json' and start rolling midrounds
*/
/datum/game_mode/dynamic/proc/init_midround()
	midround_configured_rulesets = init_rulesets(/datum/dynamic_ruleset/midround)
	if(!length(midround_configured_rulesets))
		stack_trace("DYNAMIC: MIDROUND: midround_configured_rulesets is empty. It is impossible to roll midrounds")
		return

	midround_light_chance = midround_light_starting_chance
	midround_medium_chance = midround_medium_starting_chance
	midround_heavy_chance = midround_heavy_starting_chance

	addtimer(CALLBACK(src, PROC_REF(try_midround_roll)), 1 MINUTES, TIMER_LOOP)

/*
* Update our midround points and chances
* If we don't already have one, choose a midround ruleset to save up for
* If we do, check if we have enough points to execute it
*/
/datum/game_mode/dynamic/proc/try_midround_roll()
	if(GLOB.dynamic_forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return

	update_midround_chances()

	if(world.time < midround_grace_period)
		return

	update_midround_points()

	if(!midround_chosen_ruleset)
		choose_midround_ruleset()
	else if(midround_points >= midround_chosen_ruleset.points_cost)
		// Try to execute our ruleset
		var/result = execute_ruleset(midround_chosen_ruleset)
		message_admins("DYNAMIC: MIDROUND: Executing [midround_chosen_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
		log_dynamic("MIDROUND: Executing [midround_chosen_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")

		// If we successfully execute the midround, apply the cost and log it
		if(result == DYNAMIC_EXECUTE_SUCCESS)
			midround_executed_rulesets += midround_chosen_ruleset
			midround_points -= midround_chosen_ruleset.points_cost

		midround_chosen_ruleset = null

/*
* Generate midround points once per minute based off of each person's status
*/
/datum/game_mode/dynamic/proc/update_midround_points()
	var/previous_midround_points = midround_points

	var/living_amount = length(current_players[CURRENT_LIVING_PLAYERS])
	var/observer_amount = length(current_players[CURRENT_OBSERVERS])
	var/dead_amount = length(current_players[CURRENT_DEAD_PLAYERS])

	midround_points += living_amount * midround_points_per_living
	midround_points += observer_amount * midround_points_per_observer
	midround_points += dead_amount * midround_points_per_dead

	for(var/mob/antag in current_players[CURRENT_LIVING_ANTAGS])
		for(var/datum/antagonist/antag_datum in antag.mind?.antag_datums)
			midround_points += antag_datum.get_dynamic_midround_points()

	midround_points = max(midround_points, 0)

	midround_points += midround_linear_point_increase
	midround_linear_point_increase += initial(midround_linear_point_increase)

	log_dynamic("MIDROUND: Updated points. From [previous_midround_points] to [midround_points]")

/*
* At roundstart the Light Ruleset Chance is 100%
* As the round progresses, the Light Ruleset Chance and the Medium/Heavy Ruleset Chance will increase
* After reaching 60 minutes, the Light Ruleset Chance will reach 0%
* Additionally, the Medium Ruleset Chance will start to decrease and the Heavy Ruleset Chance will increase
*/
/datum/game_mode/dynamic/proc/update_midround_chances()
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

	log_dynamic("MIDROUND: Updated chances: Light: [midround_light_chance]%, Medium: [midround_medium_chance]%, Heavy: [midround_heavy_chance]%")

/*
* Choose the midround ruleset to save towards
*/
/datum/game_mode/dynamic/proc/choose_midround_ruleset()
	// Pick severity
	var/severity = DYNAMIC_MIDROUND_LIGHT

	var/random_value = rand(1, 100)
	if(random_value <= midround_light_chance)
		severity = DYNAMIC_MIDROUND_LIGHT
	else if(random_value <= midround_light_chance + midround_medium_chance)
		severity = DYNAMIC_MIDROUND_MEDIUM
	else
		severity = DYNAMIC_MIDROUND_HEAVY

	// Get possible rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/midround/ruleset in midround_configured_rulesets)
		if(ruleset.severity != severity)
			continue

		if(check_is_ruleset_blocked(ruleset, midround_executed_rulesets))
			continue

		ruleset.set_drafted_players_amount()
		ruleset.get_candidates()
		ruleset.trim_candidates()

		if(!ruleset.allowed())
			continue

		possible_rulesets[ruleset] = ruleset.weight

	if(!length(possible_rulesets))
		message_admins("DYNAMIC: FAIL: Tried to roll a [severity] midround but there are no possible rulesets.")
		log_dynamic("MIDROUND: FAIL: Tried to roll a [severity] midround but there are no possible rulesets.")
		return

	// Pick ruleset and log
	midround_chosen_ruleset = pick_weight_allow_zero(possible_rulesets)
	log_dynamic("MIDROUND: A new midround has been chosen to save up for: [midround_chosen_ruleset]. cost: [midround_chosen_ruleset.points_cost]")
	message_admins("DYNAMIC: A new midround ruleset has been chosen to save up for: [midround_chosen_ruleset] cost: [midround_chosen_ruleset.points_cost]")

/*
* Latejoin functionality.
*
* A maximum of 3 people can be chosen for a latejoin ruleset.
* There is a 10% chance for someone to be picked
*/

/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/character)
	// Extended
	if(GLOB.dynamic_forced_extended)
		return
	// Shuttle at centcom
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return
	// Already executed the max amount
	if(length(latejoin_executed_rulesets) >= latejoin_max_rulesets)
		return
	// No possible rulesets
	if(!length(latejoin_configured_rulesets))
		return

	if(prob(latejoin_ruleset_probability))
		if(!latejoin_forced_ruleset)
			// No latejoin ruleset chosen, lets pick one
			var/list/possible_rulesets = list()
			for(var/datum/dynamic_ruleset/latejoin/ruleset in latejoin_configured_rulesets)
				ruleset.candidates = list(character)
				ruleset.trim_candidates()

				if(!ruleset.allowed())
					continue

				possible_rulesets[ruleset] = ruleset.weight

			// No allowed rulesets, our latejoin is probably a security officer.
			if(!length(possible_rulesets))
				return

			latejoin_forced_ruleset = pick_weight_allow_zero(possible_rulesets)
		else
			latejoin_forced_ruleset.candidates = list(character)
			latejoin_forced_ruleset.trim_candidates()

			// Forced Ruleset isn't allowed, our latejoin is probably a security officer.
			if(!latejoin_forced_ruleset.allowed())
				return

		// Execute our latejoin ruleset
		var/result = execute_ruleset(latejoin_forced_ruleset)

		message_admins("DYNAMIC: Executing [latejoin_forced_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
		log_dynamic("LATEJOIN: Executing [latejoin_forced_ruleset] - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")

		if(result == DYNAMIC_EXECUTE_SUCCESS)
			latejoin_executed_rulesets += latejoin_forced_ruleset
			latejoin_forced_ruleset = null

/*
* Station intercept to alert the crew that its not a greenshift
*/
/datum/game_mode/dynamic/send_intercept()
	priority_announce("A summary has been copied and printed to all communications consoles.", "Security level elevated.", ANNOUNCER_INTERCEPT)
	if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
		SSsecurity_level.set_level(SEC_LEVEL_BLUE)

/*
* Admin interaction
*/
/datum/game_mode/dynamic/admin_panel()
	var/list/dat = list()
	dat += "Dynamic Mode <a href='byond://?_src_=vars;[HrefToken()];Vars=[FAST_REF(src)]'><b>VV</b></a> <a href='byond://?src=[FAST_REF(src)];[HrefToken()]'><b>Refresh</b></a><br/>"

	dat += "Forced extended: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];forced_extended=1'><b>[GLOB.dynamic_forced_extended ? "On" : "Off"]</b></a><br/>"

	dat += "Roundstart points: <b>[roundstart_points]</b>"
	dat += "Roundstart point divergence: <b>[round((roundstart_point_divergence - 1) * 100, 1)]%</b>"
	dat += "Roundstart candidates: <b>[length(roundstart_candidates)]</b><br/>"

	dat += "Midround grace period: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_midround_graceperiod=1'><b>[midround_grace_period ? DisplayTimeText(midround_grace_period) : "0 seconds"]</b></a>"
	dat += "Current midround points: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_midround_points=1'><b>[midround_points]</b></a>"
	dat += "Current midround percentages: Light: [round(midround_light_chance, 1)]%, Medium: [round(midround_medium_chance, 1)]%, Heavy: [round(midround_heavy_chance, 1)]%"
	dat += "Chosen midround ruleset: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_midround_ruleset=1'><b>[midround_chosen_ruleset ? midround_chosen_ruleset.name : "None"]</b></a><br/>"

	dat += "Latejoin probability: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_latejoin_prob=1'><b>[latejoin_ruleset_probability]%</b></a>"
	dat += "Max latejoin rulesets: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_latejoin_max=1'><b>[latejoin_max_rulesets]</b></a>"
	dat += "Forced latejoin ruleset: <a href='byond://?src=[FAST_REF(src)];[HrefToken()];set_latejoin_ruleset=1'><b>[latejoin_forced_ruleset ? latejoin_forced_ruleset.name : "None"]</b></a><br/>"

	dat += "Executed roundstart rulesets:"
	var/list/roundstart_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in roundstart_executed_rulesets)
		if(roundstart_rule_counts[rule])
			roundstart_rule_counts[rule]++
		else
			roundstart_rule_counts[rule] = 1
	for(var/datum/dynamic_ruleset/rule in roundstart_rule_counts)
		dat += "<b>[FOURSPACES][rule.name]</b>" + (roundstart_rule_counts[rule] > 1 ? " - [roundstart_rule_counts[rule]]x" : "")

	dat += "Executed midround rulesets:"
	var/list/midround_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in midround_executed_rulesets)
		if(midround_rule_counts[rule])
			midround_rule_counts[rule]++
		else
			midround_rule_counts[rule] = 1
	for(var/datum/dynamic_ruleset/rule in midround_rule_counts)
		dat += "<b>[FOURSPACES][rule.name]</b>" + (midround_rule_counts[rule] > 1 ? " - [midround_rule_counts[rule]]x" : "")

	dat += "Executed latejoin rulesets:"
	var/list/latejoin_rule_counts = list()
	for(var/datum/dynamic_ruleset/rule in latejoin_executed_rulesets)
		if(latejoin_rule_counts[rule])
			latejoin_rule_counts[rule]++
		else
			latejoin_rule_counts[rule] = 1
	for(var/datum/dynamic_ruleset/rule in latejoin_rule_counts)
		dat += "[FOURSPACES]<b>[rule.name]</b>" + (latejoin_rule_counts[rule] > 1 ? " - [latejoin_rule_counts[rule]]x" : "")

	var/datum/browser/browser = new(usr, "gamemode_panel", "Game Mode Panel", 500, 500)
	browser.set_content(dat.Join("<br/>"))
	browser.open()

/datum/game_mode/dynamic/Topic(href, href_list)
	if(!check_rights(R_FUN))
		message_admins("[ADMIN_LOOKUPFLW(usr)] has attempted to access the dynamic panel without authorization!")
		log_admin("[usr.key] tried to use the dynamic panel without authorization.")
		return

	if(href_list["forced_extended"])
		GLOB.dynamic_forced_extended = !GLOB.dynamic_forced_extended

		message_admins("[ADMIN_LOOKUPFLW(usr)] toggled dynamic's Forced Extended to [GLOB.dynamic_forced_extended].")
		log_dynamic("[usr.key] toggled dynamic's Forced Extended to [GLOB.dynamic_forced_extended].")
	else if(href_list["set_midround_graceperiod"])
		var/new_grace_period = tgui_input_number(usr, "What do you want to set dynamic's grace period to? (in minutes)", "Set Grace Period")
		if(isnull(new_grace_period))
			return

		midround_grace_period = new_grace_period * (1 MINUTES)

		message_admins("[ADMIN_LOOKUPFLW(usr)] set dynamic's grace period to [midround_grace_period].")
		log_dynamic("[usr.key] set dynamic's grace period to [midround_grace_period].")

	else if(href_list["set_midround_points"])
		var/new_midround_points = tgui_input_number(usr, "What do you want to set dynamic's midround points to?", "Set Midround Points")
		if(isnull(new_midround_points))
			return

		midround_points = new_midround_points

		message_admins("[ADMIN_LOOKUPFLW(usr)] set dynamic's midround points to [midround_points].")
		log_dynamic("[usr.key] set dynamic's midround points to [midround_points].")
	else if(href_list["set_midround_ruleset"])
		var/added_rule = tgui_input_list(usr, "What midround ruleset do you want dynamic to save up for?", "Set Midround Ruleset", midround_configured_rulesets)
		if(!added_rule)
			return

		midround_chosen_ruleset = added_rule

		message_admins("[ADMIN_LOOKUPFLW(usr)] set dynamic's midround ruleset to [midround_chosen_ruleset].")
		log_dynamic("[usr.key] set dynamic's midround ruleset to [midround_chosen_ruleset].")
	else if(href_list["set_latejoin_prob"])
		var/new_latejoin_probability = tgui_input_number(usr, "What do you want to set the latejoin probability to?", "Set Latejoin Probability", max_value = 100)
		if(!new_latejoin_probability)
			return

		latejoin_ruleset_probability = new_latejoin_probability

		message_admins("[ADMIN_LOOKUPFLW(usr)] set dynamic's latejoin probability to [latejoin_ruleset_probability].")
		log_dynamic("[usr.key] set dynamic's latejoin probability to [latejoin_ruleset_probability].")
	else if(href_list["set_latejoin_max"])
		var/new_latejoin_max = tgui_input_number(usr, "What do you want to set the max amount of latejoin rulesets to?", "Set Latejoin Max Rulesets")
		if(isnull(new_latejoin_max))
			return

		latejoin_max_rulesets = new_latejoin_max

		message_admins("[ADMIN_LOOKUPFLW(usr)] set dynamic's latejoin probability to [latejoin_max_rulesets].")
		log_dynamic("[usr.key] set dynamic's latejoin probability to [latejoin_max_rulesets].")
	else if(href_list["set_latejoin_ruleset"])
		var/forced_ruleset = tgui_input_list(usr, "What latejoin ruleset do you want to force?", "Force Latejoin Ruleset", latejoin_configured_rulesets)
		if(!forced_ruleset)
			return

		latejoin_forced_ruleset = forced_ruleset

		message_admins("[ADMIN_LOOKUPFLW(usr)] forced dynamic's latejoin ruleset to [latejoin_forced_ruleset].")
		log_dynamic("[usr.key] forced dynamic's latejoin ruleset to [latejoin_forced_ruleset].")

	// Refresh window
	admin_panel()
