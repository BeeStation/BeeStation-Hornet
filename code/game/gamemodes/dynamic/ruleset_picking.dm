#define ADMIN_CANCEL_MIDROUND_TIME (30 SECONDS)

/// From a list of rulesets, returns one based on weight and availability.
/// Mutates the list that is passed into it to remove invalid rules.
/datum/game_mode/dynamic/proc/pick_ruleset(list/drafted_rules)
	if (only_ruleset_executed)
		log_game("DYNAMIC: FAIL: only_ruleset_executed")
		return null

	while (TRUE)
		var/datum/dynamic_ruleset/rule = pick_weight(drafted_rules)
		if (!rule)
			var/list/leftover_rules = list()
			for (var/leftover_rule in drafted_rules)
				leftover_rules += "[leftover_rule]"

			log_game("DYNAMIC: FAIL: No rulesets left to pick. Leftover rules: [leftover_rules.Join(", ")]")

			return null

		if (check_blocking(rule, executed_rules))
			drafted_rules -= rule
			if(drafted_rules.len <= 0)
				return null
			continue
		else if (
			rule.flags & HIGH_IMPACT_RULESET \
			&& threat_level < GLOB.dynamic_stacking_limit \
			&& GLOB.dynamic_no_stacking \
			&& high_impact_ruleset_active() \
		)
			log_game("DYNAMIC: FAIL: [rule] can't execute as a high impact ruleset was already executed.")
			drafted_rules -= rule
			if(drafted_rules.len <= 0)
				return null
			continue

		return rule

/// Executes a random midround ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_midround_rule(list/drafted_rules, description)
	log_game("DYNAMIC: Rolling [drafted_rules.len] [description]")

	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return null

	current_midround_rulesets = drafted_rules - rule

	midround_injection_timer_id = addtimer(
		CALLBACK(src, PROC_REF(execute_midround_rule), rule), \
		ADMIN_CANCEL_MIDROUND_TIME, \
		TIMER_STOPPABLE, \
	)

	log_game("DYNAMIC: [rule] ruleset executing...")
	message_admins("DYNAMIC: Executing midround ruleset [rule] in [DisplayTimeText(ADMIN_CANCEL_MIDROUND_TIME)]. \
		<a href='?src=[REF(src)];cancelmidround=[midround_injection_timer_id]'>CANCEL</a> | \
		<a href='?src=[REF(src)];differentmidround=[midround_injection_timer_id]'>SOMETHING ELSE</a>")
	play_sound_to_all_admins('sound/effects/admin_alert.ogg')

	return rule

/// Fired after admins do not cancel a midround injection.
/datum/game_mode/dynamic/proc/execute_midround_rule(datum/dynamic_ruleset/rule)
	current_midround_rulesets = null
	midround_injection_timer_id = null
	if (!rule.repeatable)
		midround_rules = remove_from_list(midround_rules, rule.type)
	addtimer(CALLBACK(src, PROC_REF(execute_midround_latejoin_rule), rule), rule.delay)

/// Executes a random latejoin ruleset from the list of drafted rules.
/datum/game_mode/dynamic/proc/pick_latejoin_rule(list/drafted_rules)
	var/datum/dynamic_ruleset/rule = pick_ruleset(drafted_rules)
	if (isnull(rule))
		return
	if (!rule.repeatable)
		latejoin_rules = remove_from_list(latejoin_rules, rule.type)
	addtimer(CALLBACK(src, PROC_REF(execute_midround_latejoin_rule), rule), rule.delay)
	return TRUE

/// Mainly here to facilitate delayed rulesets. All midround/latejoin rulesets are executed with a timered callback to this proc.
/datum/game_mode/dynamic/proc/execute_midround_latejoin_rule(sent_rule)
	var/datum/dynamic_ruleset/rule = sent_rule
	spend_midround_budget(rule.cost, threat_log, "[worldtime2text()]: [rule.ruletype] [rule.name]")
	rule.pre_execute(current_players[CURRENT_LIVING_PLAYERS].len)
	var/execute_result = rule.execute()
	if(execute_result == DYNAMIC_EXECUTE_SUCCESS)
		log_game("DYNAMIC: Injected a [rule.ruletype == "latejoin" ? "latejoin" : "midround"] ruleset [rule.name].")
		if(rule.flags & ONLY_RULESET)
			only_ruleset_executed = TRUE
		if(rule.ruletype == "Latejoin")
			var/mob/M = pick(rule.candidates)
			dynamic_log("[key_name(M)] joined the station, and was selected by the [rule.name] ruleset.")
		executed_rules += rule
		rule.candidates.Cut()
		if (rule.persistent)
			current_rules += rule
		new_snapshot(rule)
		return TRUE
	if(!execute_result || execute_result == DYNAMIC_EXECUTE_FAILURE) // not enough players is an expected failure. Any other should be reported
		CRASH("The [rule.ruletype] rule \"[rule.name]\" failed to execute.")
	return FALSE

/// Fired when an admin cancels the current midround injection.
/datum/game_mode/dynamic/proc/admin_cancel_midround(mob/user, timer_id)
	if (midround_injection_timer_id != timer_id || !deltimer(midround_injection_timer_id))
		to_chat(user, "<span class='notice'>Too late!</span>")
		return

	dynamic_log("[key_name(user)] cancelled the next midround injection.")
	midround_injection_timer_id = null
	current_midround_rulesets = null

/// Fired when an admin requests a different midround injection.
/datum/game_mode/dynamic/proc/admin_different_midround(mob/user, timer_id)
	if (midround_injection_timer_id != timer_id || !deltimer(midround_injection_timer_id))
		to_chat(user, "<span class='notice'>Too late!</span>")
		return

	midround_injection_timer_id = null

	if (isnull(current_midround_rulesets) || current_midround_rulesets.len == 0)
		dynamic_log("[key_name(user)] asked for a different midround injection, but there were none left.")
		return

	dynamic_log("[key_name(user)] asked for a different midround injection.")
	message_admins("[key_name(user)] asked for a different midround injection.")
	pick_midround_rule(current_midround_rulesets, "different midround rulesets")

#undef ADMIN_CANCEL_MIDROUND_TIME
