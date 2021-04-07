#define RULESET_STOP_PROCESSING 1

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

	// Threat logging vars
	/// The "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/threat_level = 0

	/// Set at the beginning of the round. Spent by the mode to "purchase" rules. Everything else goes in the postround budget.
	var/round_start_budget = 0

	/// Set at the beginning of the round. Spent by midrounds and latejoins.
	var/mid_round_budget = 0

	/// The initial round start budget for logging purposes, set once at the beginning of the round.
	var/initial_round_start_budget = 0

	/// Running information about the threat. Can store text or datum entries.
	var/list/threat_log = list()
	/// List of roundstart rules used for selecting the rules.
	var/list/roundstart_rules = list()
	/// List of latejoin rules used for selecting the rules.
	var/list/latejoin_rules = list()
	/// List of midround rules used for selecting the rules.
	var/list/midround_rules = list()
	/** # Pop range per requirement.
	  * If the value is five the range is:
	  * 0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	  * If it is six the range is:
	  * 0-5, 6-11, 12-17, 18-23, 24-29, 30-35, 36-41, 42-47, 48-53, 54+
	  * If it is seven the range is:
	  * 0-6, 7-13, 14-20, 21-27, 28-34, 35-41, 42-48, 49-55, 56-62, 63+
	  */
	var/pop_per_requirement = 6
	/// Number of players who were ready on roundstart.
	var/roundstart_pop_ready = 0
	/// List of candidates used on roundstart rulesets.
	var/list/candidates = list()
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
	/// If a high impact ruleset was executed. Only one will run at a time in most circumstances.
	var/high_impact_ruleset_executed = FALSE
	/// If a only ruleset has been executed.
	var/only_ruleset_executed = FALSE
	/// Dynamic configuration, loaded on pre_setup
	var/list/configuration = null
	/// Antags rolled by rules so far, to keep track of and discourage scaling past a certain ratio of crew/antags especially on lowpop.
	var/antags_rolled = 0

	/// When world.time is over this number the mode tries to inject a latejoin ruleset.
	var/latejoin_injection_cooldown = 0

	/// The minimum time the recurring latejoin ruleset timer is allowed to be.
	var/latejoin_delay_min = (5 MINUTES)

	/// The maximum time the recurring latejoin ruleset timer is allowed to be.
	var/latejoin_delay_max = (25 MINUTES)

	/// When world.time is over this number the mode tries to inject a midround ruleset.
	var/midround_injection_cooldown = 0

	/// The minimum time the recurring midround ruleset timer is allowed to be.
	var/midround_delay_min = (15 MINUTES)

	/// The maximum time the recurring midround ruleset timer is allowed to be.
	var/midround_delay_max = (35 MINUTES)

	/// If above this threat, increase the chance of injection
	var/higher_injection_chance_minimum_threat = 70

	/// The chance of injection increase when above higher_injection_chance_minimum_threat
	var/higher_injection_chance = 15

	/// If below this threat, decrease the chance of injection
	var/lower_injection_chance_minimum_threat = 10

	/// The chance of injection decrease when above lower_injection_chance_minimum_threat
	var/lower_injection_chance = 15

	/// A number between -5 and +5.
	/// A negative value will give a more peaceful round and
	/// a positive value will give a round with higher threat.
	var/threat_curve_centre = 0

	/// A number between 0.5 and 4.
	/// Higher value will favour extreme rounds and
	/// lower value rounds closer to the average.
	var/threat_curve_width = 1.8

	/// A number between -5 and +5.
	/// Equivalent to threat_curve_centre, but for the budget split.
	/// A negative value will weigh towards midround rulesets, and a positive
	/// value will weight towards roundstart ones.
	var/roundstart_split_curve_centre = 1

	/// A number between 0.5 and 4.
	/// Equivalent to threat_curve_width, but for the budget split.
	/// Higher value will favour more variance in splits and
	/// lower value rounds closer to the average.
	var/roundstart_split_curve_width = 1.8

	/// The minimum amount of time for antag random events to be hijacked.
	var/random_event_hijack_minimum = 10 MINUTES

	/// The maximum amount of time for antag random events to be hijacked.
	var/random_event_hijack_maximum = 18 MINUTES

	/// A list of recorded "snapshots" of the round, stored in the dynamic.json log
	var/list/datum/dynamic_snapshot/snapshots

	/// The time when the last midround injection was attempted, whether or not it was successful
	var/last_midround_injection_attempt = 0

	/// The amount to inject when a round event is hijacked
	var/hijacked_random_event_injection_chance = 50

	/// Whether or not a random event has been hijacked this midround cycle
	var/random_event_hijacked = HIJACKED_NOTHING

	/// The timer ID for the cancellable midround rule injection
	var/midround_injection_timer_id

	/// The last drafted midround rulesets (without the current one included).
	/// Used for choosing different midround injections.
	var/list/current_midround_rulesets

/datum/game_mode/dynamic/admin_panel()
	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Game Mode Panel</title></head><body><h1><B>Game Mode Panel</B></h1>")
	dat += "Dynamic Mode <a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>\[VV\]</a> <a href='?src=\ref[src];[HrefToken()]'>\[Refresh\]</a><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Budgets (Roundstart/Midrounds): <b>[initial_round_start_budget]/[threat_level - initial_round_start_budget]</b><br/>"

	dat += "Midround budget to spend: <b>[mid_round_budget]</b> <a href='?src=\ref[src];[HrefToken()];adjustthreat=1'>\[Adjust\]</A> <a href='?src=\ref[src];[HrefToken()];threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [threat_curve_centre] ; width = [threat_curve_width].<br/>"
	dat += "Split parameters: centre = [roundstart_split_curve_centre] ; width = [roundstart_split_curve_width].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='?src=\ref[src];[HrefToken()];forced_extended=1'><b>[GLOB.dynamic_forced_extended ? "On" : "Off"]</b></a><br/>"
	dat += "No stacking (only one round-ender): <a href='?src=\ref[src];[HrefToken()];no_stacking=1'><b>[GLOB.dynamic_no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: [GLOB.dynamic_stacking_limit] <a href='?src=\ref[src];[HrefToken()];stacking_limit=1'>\[Adjust\]</A>"
	dat += "<br/>"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			dat += "[DR.ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[get_injection_chance(dry_run = TRUE)]%</b> latejoin chance, <b>[get_midround_injection_chance(dry_run = TRUE)]%</b> midround chance)<BR>"
	dat += "Latejoin: [(latejoin_injection_cooldown-world.time)>60*10 ? "[round((latejoin_injection_cooldown-world.time)/60/10,0.1)] minutes" : "[(latejoin_injection_cooldown-world.time)] seconds"] <a href='?src=\ref[src];[HrefToken()];injectlate=1'>\[Now!\]</a><BR>"
	dat += "Midround: [(midround_injection_cooldown-world.time)>60*10 ? "[round((midround_injection_cooldown-world.time)/60/10,0.1)] minutes" : "[(midround_injection_cooldown-world.time)] seconds"] <a href='?src=\ref[src];[HrefToken()];injectmid=1'>\[Now!\]</a><BR>"
	usr << browse(dat.Join(), "window=gamemode_panel;size=500x500")

/datum/game_mode/dynamic/Topic(href, href_list)
	if (..()) // Sanity, maybe ?
		return
	if(!check_rights(R_ADMIN))
		message_admins("[usr.key] has attempted to override the game mode panel!")
		log_admin("[key_name(usr)] tried to use the game mode panel without authorization.")
		return
	if (href_list["forced_extended"])
		GLOB.dynamic_forced_extended = !GLOB.dynamic_forced_extended
	else if (href_list["no_stacking"])
		GLOB.dynamic_no_stacking = !GLOB.dynamic_no_stacking
	else if (href_list["adjustthreat"])
		var/threatadd = input("Specify how much threat to add (negative to subtract). This can inflate the threat level.", "Adjust Threat", 0) as null|num
		if(!threatadd)
			return
		if(threatadd > 0)
			create_threat(threatadd)
			threat_log += "[worldtime2text()]: [key_name(usr)] increased threat by [threatadd] threat."
		else
			spend_midround_budget(-threatadd)
			threat_log += "[worldtime2text()]: [key_name(usr)] decreased threat by [-threatadd] threat."
	else if (href_list["injectlate"])
		latejoin_injection_cooldown = 0
		forced_injection = TRUE
		message_admins("[key_name(usr)] forced a latejoin injection.", 1)
	else if (href_list["injectmid"])
		midround_injection_cooldown = 0
		forced_injection = TRUE
		message_admins("[key_name(usr)] forced a midround injection.", 1)
	else if (href_list["threatlog"])
		show_threatlog(usr)
	else if (href_list["stacking_limit"])
		GLOB.dynamic_stacking_limit = input(usr,"Change the threat limit at which round-endings rulesets will start to stack.", "Change stacking limit", null) as num
	else if(href_list["force_latejoin_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force upon the next latejoiner? This will bypass threat level and population restrictions.", "Rigging Latejoin", null) as null|anything in sortList(latejoin_rules)
		if (!added_rule)
			return
		forced_latejoin_rule = added_rule
		dynamic_log("[key_name(usr)] set [added_rule] to proc on the next latejoin.")
	else if(href_list["clear_forced_latejoin"])
		forced_latejoin_rule = null
		dynamic_log("[key_name(usr)] cleared the forced latejoin ruleset.")
	else if(href_list["force_midround_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force right now? This will bypass threat level and population restrictions.", "Execute Ruleset", null) as null|anything in sortList(midround_rules)
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

// Checks if there are HIGH_IMPACT_RULESETs and calls the rule's round_result() proc
/datum/game_mode/dynamic/set_round_result()
	// If it got to this part, just pick one high impact ruleset if it exists
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags & HIGH_IMPACT_RULESET)
			return rule.round_result()
	return ..()

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

	if(station_goals.len)
		. += "<hr><b>Special Orders for [station_name()]:</b>"
		for(var/datum/station_goal/G in station_goals)
			G.on_report()
			. += G.get_report()

	print_command_report(., "Central Command Status Summary", announce=FALSE)
	priority_announce("A summary has been copied and printed to all communications consoles.", "Security level elevated.", 'sound/ai/intercept.ogg')
	if(GLOB.security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)

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

/datum/game_mode/dynamic/proc/show_threatlog(mob/admin)
	if(!SSticker.HasRoundStarted())
		alert("The round hasn't started yet!")
		return

	if(!check_rights(R_ADMIN))
		return

	var/list/out = list("<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [threat_level]<BR>")

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [mid_round_budget]/[threat_level]"

	usr << browse(out.Join(), "window=threatlog;size=700x500")

/// Generates the threat level using lorentz distribution and assigns peaceful_percentage.
/datum/game_mode/dynamic/proc/generate_threat()
	var/relative_threat = LORENTZ_DISTRIBUTION(threat_curve_centre, threat_curve_width)
	threat_level = round(lorentz_to_amount(relative_threat), 0.1)

	peaceful_percentage = round(LORENTZ_CUMULATIVE_DISTRIBUTION(relative_threat, threat_curve_centre, threat_curve_width), 0.01)*100

/// Generates the midround and roundstart budgets
/datum/game_mode/dynamic/proc/generate_budgets()
	var/relative_round_start_budget_scale = LORENTZ_DISTRIBUTION(roundstart_split_curve_centre, roundstart_split_curve_width)
	round_start_budget = round((lorentz_to_amount(relative_round_start_budget_scale) / 100) * threat_level, 0.1)
	initial_round_start_budget = round_start_budget
	mid_round_budget = threat_level - round_start_budget

/datum/game_mode/dynamic/can_start()
	return TRUE

/datum/game_mode/dynamic/proc/setup_parameters()
	log_game("DYNAMIC: Dynamic mode parameters for the round:")
	log_game("DYNAMIC: Centre is [threat_curve_centre], Width is [threat_curve_width], Forced extended is [GLOB.dynamic_forced_extended ? "Enabled" : "Disabled"], No stacking is [GLOB.dynamic_no_stacking ? "Enabled" : "Disabled"].")
	log_game("DYNAMIC: Stacking limit is [GLOB.dynamic_stacking_limit].")
	if(GLOB.dynamic_forced_threat_level >= 0)
		threat_level = round(GLOB.dynamic_forced_threat_level, 0.1)
	else
		generate_threat()
	generate_budgets()
	set_cooldowns()
	dynamic_log("Dynamic Mode initialized with a Threat Level of... [threat_level]! ([round_start_budget] round start budget)")
	return TRUE

/datum/game_mode/dynamic/proc/set_cooldowns()
	var/latejoin_injection_cooldown_middle = 0.5*(latejoin_delay_max + latejoin_delay_min)
	latejoin_injection_cooldown = round(clamp(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), latejoin_delay_min, latejoin_delay_max)) + world.time

	var/midround_injection_cooldown_middle = 0.5*(midround_delay_max + midround_delay_min)
	midround_injection_cooldown = round(clamp(EXP_DISTRIBUTION(midround_injection_cooldown_middle), midround_delay_min, midround_delay_max)) + world.time

/datum/game_mode/dynamic/pre_setup()
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

	setup_parameters()
	setup_hijacking()

	var/valid_roundstart_ruleset = 0
	for (var/rule in subtypesof(/datum/dynamic_ruleset))
		var/datum/dynamic_ruleset/ruleset = new rule()
		// Simple check if the ruleset should be added to the lists.
		if(ruleset.name == "")
			continue
		configure_ruleset(ruleset)
		switch(ruleset.ruletype)
			if("Roundstart")
				roundstart_rules += ruleset
				if(ruleset.weight)
					valid_roundstart_ruleset++
			if ("Latejoin")
				latejoin_rules += ruleset
			if ("Midround")
				midround_rules += ruleset
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			roundstart_pop_ready++
			candidates.Add(player)
	log_game("DYNAMIC: Listing [roundstart_rules.len] round start rulesets, and [candidates.len] players ready.")
	if (candidates.len <= 0)
		log_game("DYNAMIC: [candidates.len] candidates.")
		return TRUE

	if(GLOB.dynamic_forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else if(valid_roundstart_ruleset < 1)
		log_game("DYNAMIC: [valid_roundstart_ruleset] enabled roundstart rulesets.")
		return TRUE
	else
		roundstart()

	dynamic_log("[round_start_budget] round start budget was left, donating it to midrounds.")
	threat_log += "[worldtime2text()]: [round_start_budget] round start budget was left, donating it to midrounds."
	mid_round_budget += round_start_budget

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	log_game("DYNAMIC: Picked the following roundstart rules: [starting_rulesets]")
	candidates.Cut()
	return TRUE

/datum/game_mode/dynamic/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/rule in executed_rules)
		rule.candidates.Cut() // The rule should not use candidates at this point as they all are null.
		addtimer(CALLBACK(src, /datum/game_mode/dynamic/.proc/execute_roundstart_rule, rule), rule.delay)
	..()

/// A simple roundstart proc used when dynamic_forced_roundstart_ruleset has rules in it.
/datum/game_mode/dynamic/proc/rigged_roundstart()
	message_admins("[GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	log_game("DYNAMIC: [GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	for (var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
		configure_ruleset(rule)
		message_admins("Drafting players for forced ruleset [rule.name].")
		log_game("DYNAMIC: Drafting players for forced ruleset [rule.name].")
		rule.mode = src
		rule.acceptable(roundstart_pop_ready, threat_level) // Assigns some vars in the modes, running it here for consistency
		rule.candidates = candidates.Copy()
		rule.trim_candidates()
		if (rule.ready(roundstart_pop_ready, TRUE))
			var/cost = rule.cost
			var/scaled_times = 0
			if (rule.scaling_cost)
				scaled_times = round(max(round_start_budget - cost, 0) / rule.scaling_cost)
				cost += rule.scaling_cost * scaled_times

			spend_roundstart_budget(picking_roundstart_rule(rule, scaled_times, forced = TRUE))

/datum/game_mode/dynamic/proc/roundstart()
	if (GLOB.dynamic_forced_extended)
		log_game("DYNAMIC: Starting a round of forced extended.")
		return TRUE
	var/list/drafted_rules = list()
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (!rule.weight)
			continue
		if (rule.acceptable(roundstart_pop_ready, threat_level) && round_start_budget >= rule.cost)	// If we got the population and threat required
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready(roundstart_pop_ready) && rule.candidates.len > 0)
				drafted_rules[rule] = rule.weight

	var/list/rulesets_picked = list()

	// Kept in case a ruleset can't be initialized for whatever reason, we want to be able to only spend what we can use.
	var/round_start_budget_left = round_start_budget

	while (round_start_budget_left > 0)
		var/datum/dynamic_ruleset/roundstart/ruleset = pickweightAllowZero(drafted_rules)
		if (isnull(ruleset))
			log_game("DYNAMIC: No more rules can be applied, stopping with [round_start_budget] left.")
			break

		var/cost = (ruleset in rulesets_picked) ? ruleset.scaling_cost : ruleset.cost
		if (cost == 0)
			stack_trace("[ruleset] cost 0, this is going to result in an infinite loop.")
			drafted_rules[ruleset] = null
			continue

		if (cost > round_start_budget_left)
			drafted_rules[ruleset] = null
			continue

		if (check_blocking(ruleset.blocking_rules, rulesets_picked))
			drafted_rules[ruleset] = null
			continue

		round_start_budget_left -= cost

		rulesets_picked[ruleset] += 1

		if (ruleset.flags & HIGH_IMPACT_RULESET)
			for (var/_other_ruleset in drafted_rules)
				var/datum/dynamic_ruleset/other_ruleset = _other_ruleset
				if (other_ruleset.flags & HIGH_IMPACT_RULESET)
					drafted_rules[other_ruleset] = null

		if (ruleset.flags & LONE_RULESET)
			drafted_rules[ruleset] = null

	for (var/ruleset in rulesets_picked)
		spend_roundstart_budget(picking_roundstart_rule(ruleset, rulesets_picked[ruleset] - 1))

/// Initializes the round start ruleset provided to it. Returns how much threat to spend.
/datum/game_mode/dynamic/proc/picking_roundstart_rule(datum/dynamic_ruleset/roundstart/ruleset, scaled_times = 0, forced = FALSE)
	log_game("DYNAMIC: Picked a ruleset: [ruleset.name], scaled [scaled_times] times")

	ruleset.trim_candidates()
	var/added_threat = ruleset.scale_up(roundstart_pop_ready, scaled_times)

	if(ruleset.pre_execute(roundstart_pop_ready))
		threat_log += "[worldtime2text()]: Roundstart [ruleset.name] spent [ruleset.cost + added_threat]. [ruleset.scaling_cost ? "Scaled up [ruleset.scaled_times]/[scaled_times] times." : ""]"
		if(ruleset.flags & ONLY_RULESET)
			only_ruleset_executed = TRUE
		if(ruleset.flags & HIGH_IMPACT_RULESET)
			high_impact_ruleset_executed = TRUE
		executed_rules += ruleset
		return ruleset.cost + added_threat
	else
		stack_trace("The starting rule \"[ruleset.name]\" failed to pre_execute.")
	return 0

/// Mainly here to facilitate delayed rulesets. All roundstart rulesets are executed with a timered callback to this proc.
/datum/game_mode/dynamic/proc/execute_roundstart_rule(sent_rule)
	var/datum/dynamic_ruleset/rule = sent_rule
	if(rule.execute())
		if(rule.persistent)
			current_rules += rule
		new_snapshot(rule)
		return TRUE
	rule.clean_up()	// Refund threat, delete teams and so on.
	executed_rules -= rule
	stack_trace("The starting rule \"[rule.name]\" failed to execute.")
	return FALSE

/// An experimental proc to allow admins to call rules on the fly or have rules call other rules.
/datum/game_mode/dynamic/proc/picking_specific_rule(ruletype, forced = FALSE)
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype() // You should only use it to call midround rules though.
		configure_ruleset(new_rule)
	else if(istype(ruletype, /datum/dynamic_ruleset))
		new_rule = ruletype
	else
		return FALSE

	if(!new_rule)
		return FALSE

	if(!forced)
		if(only_ruleset_executed)
			return FALSE
		// Check if a blocking ruleset has been executed.
		else if(check_blocking(new_rule.blocking_rules, executed_rules))
			return FALSE
		// Check if the ruleset is high impact and if a high impact ruleset has been executed
		else if(new_rule.flags & HIGH_IMPACT_RULESET)
			if(threat_level < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
				if(high_impact_ruleset_executed)
					return FALSE

	var/population = current_players[CURRENT_LIVING_PLAYERS].len
	if((new_rule.acceptable(population, threat_level) && new_rule.cost <= mid_round_budget) || forced)
		new_rule.trim_candidates()
		if (new_rule.ready(forced))
			spend_midround_budget(new_rule.cost)
			threat_log += "[worldtime2text()]: Forced rule [new_rule.name] spent [new_rule.cost]"
			new_rule.pre_execute(population)
			if (new_rule.execute()) // This should never fail since ready() returned 1
				if(new_rule.flags & HIGH_IMPACT_RULESET)
					high_impact_ruleset_executed = TRUE
				else if(new_rule.flags & ONLY_RULESET)
					only_ruleset_executed = TRUE
				log_game("DYNAMIC: Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				if (new_rule.persistent)
					current_rules += new_rule
				return TRUE
		else if (forced)
			log_game("DYNAMIC: The ruleset [new_rule.name] couldn't be executed due to lack of elligible players.")
	return FALSE

/datum/game_mode/dynamic/process()
	for (var/datum/dynamic_ruleset/rule in current_rules)
		if(rule.rule_process() == RULESET_STOP_PROCESSING) // If rule_process() returns 1 (RULESET_STOP_PROCESSING), stop processing.
			current_rules -= rule

	if (midround_injection_cooldown < world.time)
		if (GLOB.dynamic_forced_extended)
			return

		// Somehow it managed to trigger midround multiple times so this was moved here.
		// There is no way this should be able to trigger an injection twice now.
		var/midround_injection_cooldown_middle = 0.5*(midround_delay_max + midround_delay_min)
		midround_injection_cooldown = (round(clamp(EXP_DISTRIBUTION(midround_injection_cooldown_middle), midround_delay_min, midround_delay_max)) + world.time)

		// Time to inject some threat into the round
		if(EMERGENCY_ESCAPED_OR_ENDGAMED) // Unless the shuttle is gone
			return

		dynamic_log("Checking for midround injection.")

		last_midround_injection_attempt = world.time

		if (prob(get_midround_injection_chance()))
			var/list/drafted_rules = list()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (!rule.weight)
					continue
				if (rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len, threat_level) && mid_round_budget >= rule.cost)
					// If admins have disabled dynamic from picking from the ghost pool
					if(rule.ruletype == "Latejoin" && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
						continue
					// If admins have disabled dynamic from picking from the ghost pool
					if(rule.ruletype == "Latejoin" && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
						continue
					rule.trim_candidates()
					if (rule.ready())
						drafted_rules[rule] = rule.get_weight()
			if (drafted_rules.len > 0)
				pick_midround_rule(drafted_rules)
		else if (random_event_hijacked == HIJACKED_TOO_SOON)
			log_game("DYNAMIC: Midround injection failed when random event was hijacked. Spawning another random event in its place.")

			// A random event antag would have rolled had this injection check passed.
			// As a refund, spawn a non-ghost-role random event.
			SSevents.spawnEvent()
			SSevents.reschedule()

		random_event_hijacked = HIJACKED_NOTHING

/// Gets the chance for latejoin injection, the dry_run argument is only used for forced injection.
/datum/game_mode/dynamic/proc/get_injection_chance(dry_run = FALSE)
	if(forced_injection)
		forced_injection = dry_run
		return 100
	var/chance = 0
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(current_players[CURRENT_LIVING_PLAYERS].len/5))
	if (!current_players[CURRENT_LIVING_ANTAGS].len)
		chance += 50 // No antags at all? let's boost those odds!
	else
		var/current_pop_per_antag = current_players[CURRENT_LIVING_PLAYERS].len / current_players[CURRENT_LIVING_ANTAGS].len
		if (current_pop_per_antag > max_pop_per_antag)
			chance += min(50, 25+10*(current_pop_per_antag-max_pop_per_antag))
		else
			chance += 25-10*(max_pop_per_antag-current_pop_per_antag)
	if (current_players[CURRENT_DEAD_PLAYERS].len > current_players[CURRENT_LIVING_PLAYERS].len)
		chance -= 30 // More than half the crew died? ew, let's calm down on antags
	if (mid_round_budget > higher_injection_chance_minimum_threat)
		chance += higher_injection_chance
	if (mid_round_budget < lower_injection_chance_minimum_threat)
		chance -= lower_injection_chance
	return round(max(0,chance))

/// Gets the chance for midround injection, the dry_run argument is only used for forced injection.
/// Usually defers to the latejoin injection chance.
/datum/game_mode/dynamic/proc/get_midround_injection_chance(dry_run)
	var/chance = get_injection_chance(dry_run)

	if (random_event_hijacked != HIJACKED_NOTHING)
		chance += hijacked_random_event_injection_chance

	return chance

/// Removes type from the list
/datum/game_mode/dynamic/proc/remove_from_list(list/type_list, type)
	for(var/I in type_list)
		if(istype(I, type))
			type_list -= I
	return type_list

/// Checks if a type in blocking_list is in rule_list.
/datum/game_mode/dynamic/proc/check_blocking(list/blocking_list, list/rule_list)
	if(blocking_list.len > 0)
		for(var/blocking in blocking_list)
			for(var/_executed in rule_list)
				var/datum/executed = _executed
				if(blocking == executed.type)
					return TRUE
	return FALSE

/// Checks if client age is age or older.
/datum/game_mode/dynamic/proc/check_age(client/C, age)
	enemy_minimum_age = age
	if(get_remaining_days(C) == 0)
		enemy_minimum_age = initial(enemy_minimum_age)
		return TRUE // Available in 0 days = available right now = player is old enough to play.
	enemy_minimum_age = initial(enemy_minimum_age)
	return FALSE

/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/newPlayer)
	if (GLOB.dynamic_forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED) // No more rules after the shuttle has left
		return

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		log_game("DYNAMIC: Forcing ruleset [forced_latejoin_rule]")
		if (forced_latejoin_rule.ready(TRUE))
			if (!forced_latejoin_rule.repeatable)
				latejoin_rules = remove_from_list(latejoin_rules, forced_latejoin_rule.type)
			addtimer(CALLBACK(src, /datum/game_mode/dynamic/.proc/execute_midround_latejoin_rule, forced_latejoin_rule), forced_latejoin_rule.delay)
		forced_latejoin_rule = null

	else if (latejoin_injection_cooldown < world.time && prob(get_injection_chance()))
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (!rule.weight)
				continue
			if (rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len, threat_level) && mid_round_budget >= rule.cost)
				// No stacking : only one round-ender, unless threat level > stacking_limit.
				if (threat_level < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
					if(rule.flags & HIGH_IMPACT_RULESET && high_impact_ruleset_executed)
						continue

				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && pick_latejoin_rule(drafted_rules))
			var/latejoin_injection_cooldown_middle = 0.5*(latejoin_delay_max + latejoin_delay_min)
			latejoin_injection_cooldown = round(clamp(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), latejoin_delay_min, latejoin_delay_max)) + world.time

/// Apply configurations to rule.
/datum/game_mode/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset)
	var/rule_conf = LAZYACCESSASSOC(configuration, ruleset.ruletype, ruleset.name)
	for(var/variable in rule_conf)
		if(!(variable in ruleset.vars))
			stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.ruletype] [ruleset.name].")
			continue
		ruleset.vars[variable] = rule_conf[variable]
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.restricted_roles |= ruleset.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.restricted_roles |= "Assistant"
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		ruleset.restricted_roles |= GLOB.command_positions

/// Refund threat, but no more than threat_level.
/datum/game_mode/dynamic/proc/refund_threat(regain)
	mid_round_budget = min(threat_level, mid_round_budget + regain)

/// Generate threat and increase the threat_level if it goes beyond, capped at 100
/datum/game_mode/dynamic/proc/create_threat(gain)
	mid_round_budget = min(100, mid_round_budget + gain)
	if(mid_round_budget > threat_level)
		threat_level = mid_round_budget

/// Expend round start threat, can't fall under 0.
/datum/game_mode/dynamic/proc/spend_roundstart_budget(cost)
	round_start_budget = max(round_start_budget - cost,0)

/// Expend midround threat, can't fall under 0.
/datum/game_mode/dynamic/proc/spend_midround_budget(cost)
	mid_round_budget = max(mid_round_budget - cost,0)

/// Turns the value generated by lorentz distribution to number between 0 and 100.
/// Used for threat level and splitting the budgets.
/datum/game_mode/dynamic/proc/lorentz_to_amount(x)
	switch (x)
		if (-INFINITY to -20)
			return rand(0, 10)
		if (-20 to -10)
			return RULE_OF_THREE(-40, -20, x) + 50
		if (-10 to -5)
			return RULE_OF_THREE(-30, -10, x) + 50
		if (-5 to -2.5)
			return RULE_OF_THREE(-20, -5, x) + 50
		if (-2.5 to -0)
			return RULE_OF_THREE(-10, -2.5, x) + 50
		if (0 to 2.5)
			return RULE_OF_THREE(10, 2.5, x) + 50
		if (2.5 to 5)
			return RULE_OF_THREE(20, 5, x) + 50
		if (5 to 10)
			return RULE_OF_THREE(30, 10, x) + 50
		if (10 to 20)
			return RULE_OF_THREE(40, 20, x) + 50
		if (20 to INFINITY)
			return rand(90, 100)

/// Log to messages and to the game
/datum/game_mode/dynamic/proc/dynamic_log(text)
	message_admins("DYNAMIC: [text]")
	log_game("DYNAMIC: [text]")

#undef FAKE_REPORT_CHANCE
#undef REPORT_NEG_DIVERGENCE
#undef REPORT_POS_DIVERGENCE
