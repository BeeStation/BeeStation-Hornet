GLOBAL_VAR_INIT(clockwork_cached_cost_multiplier, 1)

/proc/calculate_clockwork_cost_multiplier()
	if(GLOB.gateway_opening)
		GLOB.clockwork_cached_cost_multiplier = 1
		return 1
	var/baseline_power = GLOB.joined_player_list.len
	var/power = 1
	for(var/mob/living/carbon/human/player in GLOB.joined_player_list)
		//Only count alive players that joined the game at roundstart
		if(player.stat == DEAD)
			continue
		power ++
		if(HAS_TRAIT(player, TRAIT_MINDSHIELD))
			power ++
	. = CLAMP(baseline_power / power, 2, 0.5)

	GLOB.clockwork_cached_cost_multiplier = .
