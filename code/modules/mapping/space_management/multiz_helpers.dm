/proc/get_step_multiz(ref, dir)
	if(dir & UP)
		dir &= ~UP
		return get_step(GET_TURF_ABOVE(get_turf(ref)), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(GET_TURF_BELOW(get_turf(ref)), dir)
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/us, turf/them)
	us = get_turf(us)
	them = get_turf(them)
	if(!us || !them)
		return NONE
	if(us.z == them.z)
		return get_dir(us, them)
	else
		var/turf/T = us.above()
		var/dir = NONE
		if(T && (T.z == them.z))
			dir = UP
		else
			T = us.below()
			if(T && (T.z == them.z))
				dir = DOWN
			else
				return get_dir(us, them)
		return (dir | get_dir(us, them))

/turf/proc/above()
	return get_step_multiz(src, UP)

/turf/proc/below()
	return get_step_multiz(src, DOWN)

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
	var/turf/temp = center_turf.above()
	//Iterate upwards.
	var/i = 0
	while(isturf(temp))
		. += temp.z
		i ++
		if(i >= max_z_range)
			break
		temp = temp.above()
	//Iterate downwards.
	temp = center_turf.below()
	i = 0
	while(isturf(temp))
		. += temp.z
		i ++
		if(i >= max_z_range)
			break
		temp = temp.below()

/proc/multi_z_dist(turf/T0, turf/T1)
	if(T0.get_virtual_z_level() == T1.get_virtual_z_level())
		return get_dist(T0, T1)
	if(is_station_level(T0.z) && is_station_level(T1.z))
		var/raw_dist = get_dist(T0, T1)
		var/z_dist = abs(T0.z - T1.z) * MULTI_Z_DISTANCE
		var/total_dist = raw_dist + z_dist
		return total_dist
	return INFINITY
