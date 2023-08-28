/proc/get_step_multiz(ref, dir)
	var/turf/reference_turf = get_turf(ref)
	if(dir & UP)
		dir &= ~UP
		return get_step(GET_TURF_ABOVE(reference_turf), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(GET_TURF_BELOW(reference_turf), dir)
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/us, turf/them)
	us = get_turf(us)
	them = get_turf(them)
	if(!us || !them)
		return NONE
	if(us.z == them.z)
		return get_dir(us, them)
	else
		var/turf/T = GET_TURF_ABOVE(us)
		var/dir = NONE
		if(T && (T.z == them.z))
			dir = UP
		else
			T = GET_TURF_BELOW(us)
			if(T && (T.z == them.z))
				dir = DOWN
			else
				return get_dir(us, them)
		return (dir | get_dir(us, them))

/proc/dir_inverse_multiz(dir)
	var/holder = dir & (UP|DOWN)
	if((holder == NONE) || (holder == (UP|DOWN)))
		return turn(dir, 180)
	dir &= ~(UP|DOWN)
	if(dir != 0)
		dir = turn(dir, 180)
	if(holder == UP)
		holder = DOWN
	else
		holder = UP
	dir |= holder
	return dir

/proc/get_zs_in_range(z_level, max_z_range)
	. = list(z_level)
	if(max_z_range <= 0)
		return
	var/turf/center_turf = locate(world.maxx / 2, world.maxy / 2, z_level)
	var/turf/temp = GET_TURF_ABOVE(center_turf)
	//Iterate upwards.
	var/i = 0
	while(isturf(temp))
		. += temp.z
		i ++
		if(i >= max_z_range)
			break
		temp = GET_TURF_ABOVE(temp)
	//Iterate downwards.
	temp = GET_TURF_BELOW(center_turf)
	i = 0
	while(isturf(temp))
		. += temp.z
		i ++
		if(i >= max_z_range)
			break
		temp = GET_TURF_BELOW(temp)

/proc/multi_z_dist(turf/T0, turf/T1)
	if(T0.get_virtual_z_level() == T1.get_virtual_z_level())
		return get_dist(T0, T1)
	if(is_station_level(T0.z) && is_station_level(T1.z))
		var/raw_dist = get_dist(T0, T1)
		var/z_dist = abs(T0.z - T1.z) * MULTI_Z_DISTANCE
		var/total_dist = raw_dist + z_dist
		return total_dist
	return INFINITY

/turf/proc/set_below(turf/below_turf, force = FALSE)
	if (!force && (below_turf?.above && below_turf?.above != src))
		return null
	var/was_enabled = shadower
	if (was_enabled)
		cleanup_zmimic()
	if (below)
		below.z_depth = null
		below.above = null
	else if (!below_turf)
		return null
	below = below_turf
	if (!below_turf)
		calculate_zdepth()
		return null
	below_turf.above = src
	calculate_zdepth()
	if (was_enabled)
		setup_zmimic()
	ImmediateCalculateAdjacentTurfs()
	below.ImmediateCalculateAdjacentTurfs()
	return below_turf

/turf/proc/set_above(turf/above_turf, force = FALSE)
	if (!force && (above_turf?.below && above_turf?.below != src))
		return null
	if (above)
		above.z_depth = null
		above.below = null
		// Cleanup z-mimic stuff as it is no longer being used
		above.cleanup_zmimic()
	else if (!above_turf)
		return null
	above = above_turf
	if (!above_turf)
		calculate_zdepth()
		return null
	above_turf.below = src
	var/was_enabled = above.shadower
	if (was_enabled)
		above.cleanup_zmimic()
	calculate_zdepth()
	// Fully reset the z-mimic of the above turf if it is a zmimic turf
	if (was_enabled)
		above.setup_zmimic()
	ImmediateCalculateAdjacentTurfs()
	above.ImmediateCalculateAdjacentTurfs()
	return above_turf

/turf/proc/link_above(turf/above_turf)
	if (above)
		WARNING("Warning: An already linked turf was re-linked to another turf. This behaviour is likely not intentional.")
	set_above(above_turf, TRUE)

/turf/proc/link_below(turf/below_turf)
	if (below)
		WARNING("Warning: An already linked turf was re-linked to another turf. This behaviour is likely not intentional.")
	set_below(below_turf, TRUE)

/// Links a region in the world vertically to another region in the world.
/proc/link_region(turf/below_bottom_left, turf/above_bottom_left, width, height)
	for (var/x in 0 to width - 1)
		for (var/y in 0 to height - 1)
			var/turf/below = locate(below_bottom_left.x + x, below_bottom_left.y + y, below_bottom_left.z)
			var/turf/above = locate(above_bottom_left.x + x, above_bottom_left.y + y, above_bottom_left.z)
			above.link_below(below)
