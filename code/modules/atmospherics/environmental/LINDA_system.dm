/atom/var/CanAtmosPass = ATMOS_PASS_YES
/atom/var/CanAtmosPassVertical = ATMOS_PASS_YES

/atom/proc/CanAtmosPass(turf/T)
	switch (CanAtmosPass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return CanAtmosPass

/turf/CanAtmosPass = ATMOS_PASS_NO
/turf/CanAtmosPassVertical = ATMOS_PASS_NO

/turf/open/CanAtmosPass = ATMOS_PASS_PROC
/turf/open/CanAtmosPassVertical = ATMOS_PASS_PROC

/turf/open/CanAtmosPass(turf/T, vertical = FALSE)
	var/dir = vertical ? get_dir_multiz(src, T) : get_dir(src, T)
	var/opp = REVERSE_DIR(dir)
	. = TRUE
	if(vertical && !(zAirOut(dir, T) && T.zAirIn(dir, src)))
		. = FALSE
	if(isclosedturf(src) || isclosedturf(T))
		. = FALSE
	if (T == src)
		return .
	for(var/obj/O in contents+T.contents)
		var/turf/other = (O.loc == src ? T : src)
		if(!(vertical? (CANVERTICALATMOSPASS(O, other)) : (CANATMOSPASS(O, other))))
			. = FALSE
		if(O.BlockThermalConductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
			conductivity_blocked_directions |= dir
			T.conductivity_blocked_directions |= opp
			if(!.)
				return .

/atom/movable/proc/BlockThermalConductivity() // Objects that don't let heat through.
	return FALSE

/turf/proc/ImmediateCalculateAdjacentTurfs()
	if(SSair.thread_running())
		CALCULATE_ADJACENT_TURFS(src)
		return
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/is_closed = isclosedturf(src)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	var/canpass = CANATMOSPASS(src, src)
	var/canvpass = CANVERTICALATMOSPASS(src, src)
	// I am essentially inlineing two get_dir_multizs here, because they're way too slow on their own. I'm sorry brother
	var/list/z_traits = SSmapping.multiz_levels[z]
	for(var/direction in GLOB.cardinals_multiz)
		// Yes this is a reimplementation of get_step_mutliz. It's faster tho. fuck you
		var/turf/current_turf = (direction & (UP|DOWN)) ? \
			(direction & UP) ? \
				(z_traits[Z_LEVEL_UP]) ? \
					(get_step(locate(x, y, z + 1), NONE)) : \
				(null) : \
				(z_traits[Z_LEVEL_DOWN]) ? \
					(get_step(locate(x, y, z - 1), NONE)) : \
				(null) : \
			(get_step(src, direction))
		if(!isopenturf(current_turf))
			continue
		if(!is_closed && ((direction & (UP|DOWN)) ? (canvpass && CANVERTICALATMOSPASS(current_turf, src)) : (canpass && CANATMOSPASS(current_turf, src))))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
			current_turf.set_sleeping(isclosedturf(current_turf))
		current_turf.__update_auxtools_turf_adjacency_info()
	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	set_sleeping(is_closed)
	__update_auxtools_turf_adjacency_info()

/turf/proc/ImmediateDisableAdjacency(disable_adjacent = TRUE)
	if(SSair.thread_running())
		SSadjacent_air.disable_queue[src] = disable_adjacent
		return
	if(disable_adjacent)
		// I am essentially inlineing two get_dir_multizs here, because they're way too slow on their own. I'm sorry brother
		var/list/z_traits = SSmapping.multiz_levels[z]
		for(var/direction in GLOB.cardinals_multiz)
			// Yes this is a reimplementation of get_step_mutliz. It's faster tho.
			var/turf/current_turf = (direction & (UP|DOWN)) ? \
				(direction & UP) ? \
					(z_traits[Z_LEVEL_UP]) ? \
						(get_step(locate(x, y, z + 1), NONE)) : \
					(null) : \
					(z_traits[Z_LEVEL_DOWN]) ? \
						(get_step(locate(x, y, z - 1), NONE)) : \
					(null) : \
				(get_step(src, direction))
			if(!istype(current_turf))
				continue
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
			current_turf.__update_auxtools_turf_adjacency_info()
	LAZYCLEARLIST(atmos_adjacent_turfs)
	__update_auxtools_turf_adjacency_info()

/turf/proc/set_sleeping(should_sleep)

/turf/proc/__update_auxtools_turf_adjacency_info()

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	var/adjacent_turfs
	if (atmos_adjacent_turfs)
		adjacent_turfs = atmos_adjacent_turfs.Copy()
	else
		adjacent_turfs = list()

	if (!alldir)
		return adjacent_turfs

	var/turf/curloc = src

	for (var/direction in GLOB.diagonals_multiz)
		var/matchingDirections = 0
		var/turf/S = get_step_multiz(curloc, direction)
		if(!S)
			continue

		for (var/checkDirection in GLOB.cardinals_multiz)
			var/turf/checkTurf = get_step(S, checkDirection)
			if(!S.atmos_adjacent_turfs || !S.atmos_adjacent_turfs[checkTurf])
				continue

			if (adjacent_turfs[checkTurf])
				matchingDirections++

			if (matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/proc/air_update_turf(command = 0)
	if(!SSair.initialized) // I'm sorry for polutting user code, I'll do 10 hail giacom's
		return
	if(!isturf(loc) && command)
		return
	var/turf/T = get_turf(loc)
	T.air_update_turf(command)

/turf/air_update_turf(command = 0)
	if(!SSair.initialized) // I'm sorry for polutting user code, I'll do 10 hail giacom's
		return
	if(command)
		ImmediateCalculateAdjacentTurfs()

/atom/movable/proc/move_update_air(turf/T)
    if(isturf(T))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make an easy proc to spawn your plasma fires
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text)

/turf/open/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/G = new
	G.parse_gas_string(text)
	assume_air(G)
