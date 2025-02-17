#define FAKE_REPORT_CHANCE 8
#define REPORT_NEG_DIVERGENCE -15
#define REPORT_POS_DIVERGENCE 15

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
	 * Midround
	*/

	/// Rules that are processed, rule_process is called on the rules in this list.
	var/list/current_rules = list()
	/// List of executed rulesets.
	var/list/executed_rules = list()
	/// When TRUE GetInjectionChance returns 100.
	var/forced_injection = FALSE
	/// Forced ruleset to be executed for the next latejoin.
	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null
	/// How many percent of the rounds are more peaceful.
	var/peaceful_percentage = 50
	/// If a only ruleset has been executed.
	var/only_ruleset_executed = FALSE
	/// Dynamic configuration, loaded on pre_setup
	var/list/configuration = null

	/// If not null, use this instead of world.time
	var/simulated_time = null

	/// If we are running simulations and should treat nobody signing up as successful spawns
	var/simulated = FALSE

	/// Should we simulate there being more alive players than there actually are?
	var/simulated_alive_players = 0

	/// When the cached station intactness will expire.
	COOLDOWN_DECLARE(intact_cache_expiry)

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
			configuration = json_decode(file2text(json_file))
			if(configuration["Dynamic"])
				for(var/variable in configuration["Dynamic"])
					if(!vars[variable])
						stack_trace("Invalid dynamic configuration variable [variable] in game mode variable changes.")
						continue
					vars[variable] = configuration["Dynamic"][variable]

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
			//if(config.getvalue(roundstart_points_per_observer) > 0)
			//	roundstart_points += config.getvalue(roundstart_points_per_observer)
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
* Pick the roundstart rulesets to run based off of their configured variables (weight, cost, etc.)
*/
/datum/game_mode/dynamic/proc/pick_roundstart_rulesets(list/roundstart_rules)
	// Extended was forced, don't pick any rulesets
	if(GLOB.dynamic_forced_extended)
		log_game("DYNAMIC: Starting a round of forced extended.")
		return TRUE

	// Trim the rulesets
	var/list/possible_rulesets = list()
	for(var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if(rule.weight == 0 || !rule.check_points_requirement())
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
		executed_roundstart_rulesets[ruleset] += 1

/*
* Checks if a ruleset is allowed to run based off of the other ones.
* A blood and clock cult cannot both run
* Two rulesets with the 'HIGH_IMPACT_RULESET' cannot run
* Returns TRUE if blocked and FALSE if allowed
*/
/datum/game_mode/dynamic/proc/check_is_ruleset_blocked(datum/dynamic_ruleset/ruleset, list/applied_rulesets)
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
	for(var/datum/dynamic_ruleset/roundstart/rule in executed_rules)
		rule.roundstart_candidates.Cut() // The rule should not use roundstart_candidates at this point as they all are null.
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/game_mode/dynamic, execute_roundstart_rule), rule), rule.delay)
	..()

/*
* Some rulesets (like revolution) need to process each tick. Lets give them the opportunity to do so.
* Also try for midrounds.
*/
/datum/game_mode/dynamic/process()
	for(var/datum/dynamic_ruleset/rule in current_rules)
		if(rule.rule_process() == RULESET_STOP_PROCESSING) // If rule_process() returns 1 (RULESET_STOP_PROCESSING), stop processing.
			current_rules -= rule

	try_midround_roll()

/*
* idk what this is
*/
/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/newPlayer)
	if (GLOB.dynamic_forced_extended)
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

/*
* Returns a list of all ruleset types (roundstart, midround, latejoin)
* Then configures their variables via configure_ruleset()
*/
/datum/game_mode/dynamic/proc/init_rulesets(ruleset_subtype)
	var/list/rulesets = list()

	for (var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
		if (initial(ruleset_type.name) == "")
			continue

		if (initial(ruleset_type.weight) == 0)
			continue

		var/ruleset = new ruleset_type(src)
		configure_ruleset(ruleset)
		rulesets += ruleset

	return rulesets

/*
* Sets the variables of this ruleset to those in the dynamic.json file
*/
/datum/game_mode/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset)
	var/rule_conf = LAZYACCESSASSOC(configuration, ruleset.ruletype, ruleset.name)

	// Normal variables
	for(var/variable in rule_conf)
		if(!(variable in ruleset.vars))
			stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.ruletype] [ruleset.name].")
			continue
		ruleset.vars[variable] = rule_conf[variable]

	// Protected roles
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.banned_roles |= ruleset.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.banned_roles |= JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		ruleset.banned_roles |= SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

















// Checks if there are any high-impact rulesets and calls the rule's round_result() proc
/datum/game_mode/dynamic/set_round_result()
	// If it got to this part, just pick one high impact ruleset if it exists
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(CHECK_BITFIELD(rule.flags, HIGH_IMPACT_RULESET))
			return rule.round_result()
	return ..()

/*
* Station intercept to alert the crew that its not a greenshift
*/
/datum/game_mode/dynamic/send_intercept()
	. = "<b><i>Central Command Status Summary</i></b><hr>"
	var/shown_threat
	if(prob(FAKE_REPORT_CHANCE))
		shown_threat = rand(1, 100)
	else
		shown_threat = clamp(threat_level + rand(REPORT_NEG_DIVERGENCE, REPORT_POS_DIVERGENCE), 0, 100)
	switch(round(shown_threat))
		if(0 to 19)
			if(!current_players[CURRENT_LIVING_ANTAGS].len)
				. += "<b>Peaceful Waypoint</b></center><BR>"
				. += "Your station orbits deep within controlled, core-sector systems and serves as a waypoint for routine traffic through Nanotrasen's trade empire. Due to the combination of high security, interstellar traffic, and low strategic value, it makes any direct threat of violence unlikely. Your primary enemies will be incompetence and bored crewmen: try to organize team-building events to keep staffers interested and productive."
			else
				. += "<b>Core Territory</b></center><BR>"
				. += "Your station orbits within reliably mundane, secure space. Although Nanotrasen has a firm grip on security in your region, the valuable resources and strategic position aboard your station make it a potential target for infiltrations. Monitor crew for non-loyal behavior, but expect a relatively tame shift free of large-scale destruction. We expect great things from your station."
		if(20 to 39)
			. += "<b>Anomalous Exogeology</b></center><BR>"
			. += "Although your station lies within what is generally considered Nanotrasen-controlled space, the course of its orbit has caused it to cross unusually close to exogeological features with anomalous readings. Although these features offer opportunities for our research department, it is known that these little understood readings are often correlated with increased activity from competing interstellar organizations and individuals, among them the Wizard Federation and Cult of the Geometer of Blood - all known competitors for Anomaly Type B sites. Exercise elevated caution."
		if(40 to 65)
			. += "<b>Contested System</b></center><BR>"
			. += "Your station's orbit passes along the edge of Nanotrasen's sphere of influence. While subversive elements remain the most likely threat against your station, hostile organizations are bolder here, where our grip is weaker. Exercise increased caution against elite Syndicate strike forces, or Executives forbid, some kind of ill-conceived unionizing attempt."
		if(66 to 79)
			. += "<b>Uncharted Space</b></center><BR>"
			. += "Congratulations and thank you for participating in the NT 'Frontier' space program! Your station is actively orbiting a high value system far from the nearest support stations. Little is known about your region of space, and the opportunity to encounter the unknown invites greater glory. You are encouraged to elevate security as necessary to protect Nanotrasen assets."
		if(80 to 99)
			. += "<b>Black Orbit</b></center><BR>"
			. += "As part of a mandatory security protocol, we are required to inform you that as a result of your orbital pattern directly behind an astrological body (oriented from our nearest observatory), your station will be under decreased monitoring and support. It is anticipated that your extreme location and decreased surveillance could pose security risks. Avoid unnecessary risks and attempt to keep your station in one piece."
		if(100)
			. += "<b>Impending Doom</b></center><BR>"
			. += "Your station is somehow in the middle of hostile territory, in clear view of any enemy of the corporation. Your likelihood to survive is low, and station destruction is expected and almost inevitable. Secure any sensitive material and neutralize any enemy you will come across. It is important that you at least try to maintain the station.<BR>"
			. += "Good luck."

	. += generate_station_goal_report()

	print_command_report(., "Central Command Status Summary", announce = FALSE)
	priority_announce("A summary has been copied and printed to all communications consoles.", "Security level elevated.", ANNOUNCER_INTERCEPT)
	if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
		SSsecurity_level.set_level(SEC_LEVEL_BLUE)








/*
* Admin panel
*/
/datum/game_mode/dynamic/admin_panel()
	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Game Mode Panel</title></head><body><h1><B>Game Mode Panel</B></h1>")
	dat += "Dynamic Mode <a href='?_src_=vars;[HrefToken()];Vars=[FAST_REF(src)]'>\[VV\]</a> <a href='?src=[FAST_REF(src)];[HrefToken()]'>\[Refresh\]</a><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Budgets (Roundstart/Midrounds): <b>[initial_round_start_budget]/[threat_level - initial_round_start_budget]</b><br/>"

	dat += "Midround budget to spend: <b>[mid_round_budget]</b> <a href='?src=[FAST_REF(src)];[HrefToken()];adjustthreat=1'>\[Adjust\]</A> <a href='?src=[FAST_REF(src)];[HrefToken()];threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [threat_curve_centre] ; width = [threat_curve_width].<br/>"
	dat += "            reduction_threshold = [threat_curve_centre_lowpop_reduction_threshold] ; reduction_coeff = [threat_curve_centre_lowpop_reduction_coeff].<br/>"
	dat += "Split parameters: centre = [roundstart_split_curve_centre] ; width = [roundstart_split_curve_width].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='?src=[FAST_REF(src)];[HrefToken()];forced_extended=1'><b>[GLOB.dynamic_forced_extended ? "On" : "Off"]</b></a><br/>"
	dat += "No stacking (only one round-ender): <a href='?src=[FAST_REF(src)];[HrefToken()];no_stacking=1'><b>[GLOB.dynamic_no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: [GLOB.dynamic_stacking_limit] <a href='?src=[FAST_REF(src)];[HrefToken()];stacking_limit=1'>\[Adjust\]</A>"
	dat += "<br/>"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			dat += "[DR.ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[get_heavy_midround_injection_chance(dry_run = TRUE)]%</b> heavy midround chance)<BR>"
	dat += "Latejoin: [(latejoin_injection_cooldown-world.time)>60*10 ? "[round((latejoin_injection_cooldown-world.time)/60/10,0.1)] minutes" : "[(latejoin_injection_cooldown-world.time)] seconds"] <a href='?src=[FAST_REF(src)];[HrefToken()];injectlate=1'>\[Now!\]</a><BR>"

	var/next_injection = next_midround_injection()
	if (next_injection == INFINITY)
		dat += "All midrounds have been exhausted."
	else
		dat += "Midround: [DisplayTimeText(next_injection - world.time)] <a href='?src=[FAST_REF(src)];[HrefToken()];injectmid=1'>\[Now!\]</a><BR>"

	usr << browse(dat.Join(), "window=gamemode_panel;size=500x500")

/*
* Menu from the game-panel verb
*/
/datum/game_mode/dynamic/Topic(href, href_list)
	if (..()) // Sanity, maybe ?
		return
	if(!check_rights(R_ADMIN))
		message_admins("[key_name(usr)] has attempted to override the game mode panel!")
		log_admin("[usr.key] tried to use the game mode panel without authorization.")
		return
	if(href_list["forced_extended"])
		GLOB.dynamic_forced_extended = !GLOB.dynamic_forced_extended
		message_admins("[key_name(usr)] toggled dynamic's Forced Extended setting to [GLOB.dynamic_forced_extended].")
		dynamic_log("[usr.key] toggled dynamic's Forced Extended setting to [GLOB.dynamic_forced_extended].")
	else if(href_list["no_stacking"])
		GLOB.dynamic_no_stacking = !GLOB.dynamic_no_stacking
		message_admins("[key_name(usr)] toggled dynamic's No Stacking setting to [GLOB.dynamic_no_stacking].")
		dynamic_log("[usr.key] toggled dynamic's No Stacking setting to [GLOB.dynamic_no_stacking].")
	else if(href_list["adjustthreat"])
		var/threatadd = input("Specify how much threat to add (negative to subtract). This can inflate the threat level.", "Adjust Threat", 0) as null|num
		if(!threatadd)
			return
		if(threatadd > 0)
			create_threat(threatadd, threat_log, "[worldtime2text()]: increased by [key_name(usr)]")
		else
			spend_midround_budget(-threatadd, threat_log, "[worldtime2text()]: decreased by [key_name(usr)]")
		message_admins("[key_name(usr)] adjusted the dynamic threat level by [threatadd] threat.")
		dynamic_log("[usr.key] adjusted the dynamic threat level by [threatadd] threat.")
	else if(href_list["injectlate"])
		latejoin_injection_cooldown = 0
		forced_injection = TRUE
		message_admins("[key_name(usr)] forced a latejoin injection.", 1)
		dynamic_log("[usr.key] forced a latejoin injection.")
	else if(href_list["injectmid"])
		forced_injection = TRUE
		message_admins("[key_name(usr)] forced a midround injection.", 1)
		dynamic_log("[usr.key] forced a midround injection.")
		try_midround_roll()
	else if(href_list["threatlog"])
		show_threatlog(usr)
	else if(href_list["stacking_limit"])
		GLOB.dynamic_stacking_limit = input(usr,"Change the threat limit at which round-endings rulesets will start to stack.", "Change stacking limit", null) as num
		message_admins("[key_name(usr)] adjusted dynamic's Stacking Limit setting to [GLOB.dynamic_stacking_limit].")
		dynamic_log("[usr.key] adjusted dynamic's Stacking Limit setting to [GLOB.dynamic_stacking_limit].")
	else if(href_list["force_latejoin_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force upon the next latejoiner? This will bypass threat level and population restrictions.", "Rigging Latejoin", null) as null|anything in sort_names(init_rulesets(/datum/dynamic_ruleset/latejoin))
		if (!added_rule)
			return
		forced_latejoin_rule = added_rule
		dynamic_log("[key_name(usr)] set [added_rule] to proc on the next latejoin.")
	else if(href_list["clear_forced_latejoin"])
		forced_latejoin_rule = null
		dynamic_log("[key_name(usr)] cleared the forced latejoin ruleset.")
	else if(href_list["force_midround_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force right now? This will bypass threat level and population restrictions.", "Execute Ruleset", null) as null|anything in sort_names(init_rulesets(/datum/dynamic_ruleset/midround))
		if (!added_rule)
			return
		dynamic_log("[key_name(usr)] executed the [added_rule] ruleset.")
		picking_specific_rule(added_rule, TRUE)
	else if(href_list["cancelmidround"])
		admin_cancel_midround(usr, href_list["cancelmidround"])
		return
	else if (href_list["differentmidround"])
		admin_different_midround(usr, href_list["differentmidround"])
		return

	admin_panel() // Refreshes the window

#undef FAKE_REPORT_CHANCE
#undef REPORT_NEG_DIVERGENCE
#undef REPORT_POS_DIVERGENCE
