/// Returns the world.time of the next midround injection.
/// Will return a cached result from `next_midround_injection`, the variable.
/// If that variable is null, will generate a new one.
/datum/game_mode/dynamic/proc/next_midround_injection()
	if (!isnull(next_midround_injection))
		return next_midround_injection

	// Admins can futz around with the midround threat, and we want to be able to react to that
	var/midround_threat = threat_level - round_start_budget

	var/rolls = CEILING(midround_threat / threat_per_midround_roll, 1)
	var/distance = ((1 / (rolls + 1)) * midround_upper_bound) + midround_lower_bound

	if (last_midround_injection_attempt == 0)
		last_midround_injection_attempt = SSticker.round_start_time

	return last_midround_injection_attempt + distance

/datum/game_mode/dynamic/proc/try_midround_roll()
	if (!forced_injection && next_midround_injection() > world.time)
		return

	if (GLOB.dynamic_forced_extended)
		return

	if (EMERGENCY_ESCAPED_OR_ENDGAMED)
		return

	var/spawn_heavy = prob(get_heavy_midround_injection_chance())

	last_midround_injection_attempt = world.time
	next_midround_injection = null
	forced_injection = FALSE

	dynamic_log("A midround ruleset is rolling, and will be [spawn_heavy ? "HEAVY" : "LIGHT"].")

	random_event_hijacked = HIJACKED_NOTHING

	var/list/drafted_heavies = list()
	var/list/drafted_lights = list()

	for (var/datum/dynamic_ruleset/midround/ruleset in midround_rules)
		if (ruleset.weight == 0)
			log_game("DYNAMIC: FAIL: [ruleset] has a weight of 0")
			continue

		if (!ruleset.acceptable(SSticker.mode.current_players[CURRENT_LIVING_PLAYERS].len, threat_level))
			log_game("DYNAMIC: FAIL: [ruleset] is not acceptable with the current parameters. Alive players: [SSticker.mode.current_players[CURRENT_LIVING_PLAYERS].len], threat level: [threat_level]")
			continue

		if (mid_round_budget < ruleset.cost)
			log_game("DYNAMIC: FAIL: [ruleset] is too expensive, and cannot be bought. Midround budget: [mid_round_budget], ruleset cost: [ruleset.cost]")
			continue

		if (ruleset.minimum_round_time > world.time - SSticker.round_start_time)
			log_game("DYNAMIC: FAIL: [ruleset] is trying to run too early. Minimum round time: [ruleset.minimum_round_time], current round time: [world.time - SSticker.round_start_time]")
			continue

		// If admins have disabled dynamic from picking from the ghost pool
		if(istype(ruleset, /datum/dynamic_ruleset/midround/from_ghosts) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
			log_game("DYNAMIC: FAIL: [ruleset] is a from_ghosts ruleset, but ghost roles are disabled")
			continue

		ruleset.trim_candidates()
		if (!ruleset.ready())
			log_game("DYNAMIC: FAIL: [ruleset] is not ready()")
			continue

		var/ruleset_is_heavy = (ruleset.midround_ruleset_style == MIDROUND_RULESET_STYLE_HEAVY)
		if (ruleset_is_heavy)
			drafted_heavies[ruleset] = ruleset.get_weight()
		else
			drafted_lights[ruleset] = ruleset.get_weight()

	var/heavy_light_log_count = "[drafted_heavies.len] heavies / [drafted_lights.len] lights"

	log_game("DYNAMIC: Rolling [spawn_heavy ? "HEAVY" : "LIGHT"]... [heavy_light_log_count]")

	if (spawn_heavy && drafted_heavies.len > 0 && pick_midround_rule(drafted_heavies, "heavy rulesets"))
		return
	else if (drafted_lights.len > 0 && pick_midround_rule(drafted_lights, "light rulesets"))
		if (spawn_heavy)
			dynamic_log("A heavy ruleset was intended to roll, but there weren't any available. [heavy_light_log_count]")
	else
		dynamic_log("No midround rulesets could be drafted. ([heavy_light_log_count])")

/// Gets the chance for a heavy ruleset midround injection, the dry_run argument is only used for forced injection.
/datum/game_mode/dynamic/proc/get_heavy_midround_injection_chance(dry_run)
	var/chance_modifier = 1
	var/next_midround_roll = next_midround_injection() - SSticker.round_start_time

	if (random_event_hijacked != HIJACKED_NOTHING)
		chance_modifier += (hijacked_random_event_injection_chance_modifier / 100)

	if (SSticker.mode.current_players[CURRENT_LIVING_ANTAGS].len == 0)
		chance_modifier += 0.5

	if (SSticker.mode.current_players[CURRENT_DEAD_PLAYERS].len > SSticker.mode.current_players[CURRENT_LIVING_PLAYERS].len)
		chance_modifier -= 0.3

	var/heavy_coefficient = CLAMP01((next_midround_roll - midround_light_upper_bound) / (midround_heavy_lower_bound - midround_light_upper_bound))

	return 100 * (heavy_coefficient * max(1, chance_modifier))
