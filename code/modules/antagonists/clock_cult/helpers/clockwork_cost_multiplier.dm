GLOBAL_VAR_INIT(clockwork_cached_cost_multiplier, 1)

/proc/calculate_clockwork_cost_multiplier()
	var/baseline_power = GLOB.joined_player_list.len
	var/power = 0
	for(var/mob/living/carbon/human/player in GLOB.mob_living_list)
		//Only count alive players that joined the game at roundstart
		if(player.stat != DEAD && player in GLOB.joined_player_list)
			power ++
			if(HAS_TRAIT(player, TRAIT_MINDSHIELD))
				power ++
	. = baseline_power / power

	GLOB.clockwork_cached_cost_multiplier = .
