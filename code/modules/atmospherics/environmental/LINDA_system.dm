/atom/var/can_atmos_pass = ATMOS_PASS_YES
/atom/var/can_atmos_passVertical = ATMOS_PASS_YES

/atom/proc/can_atmos_pass(turf/T)
	switch (can_atmos_pass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return can_atmos_pass

/turf/can_atmos_pass = ATMOS_PASS_NO
/turf/can_atmos_passVertical = ATMOS_PASS_NO

/turf/open/can_atmos_pass = ATMOS_PASS_PROC
/turf/open/can_atmos_passVertical = ATMOS_PASS_PROC

//Do NOT use this to see if 2 turfs are connected, it mutates state, and we cache that info anyhow. Use TURFS_CAN_SHARE or TURF_SHARES depending on your usecase
/turf/open/can_atmos_pass(turf/T, vertical = FALSE)
	var/dir = vertical? get_dir_multiz(src, T) : get_dir(src, T)
	var/opp = REVERSE_DIR(dir)
	var/R = FALSE
	if(vertical && !(zAirOut(dir, T) && T.zAirIn(dir, src)))
		R = TRUE
	if(blocks_air || T.blocks_air)
		R = TRUE
	if (T == src)
		return !R
	for(var/obj/O in contents+T.contents)
		var/turf/other = (O.loc == src ? T : src)
		if(!(vertical? (CANVERTICALATMOSPASS(O, other)) : (CANATMOSPASS(O, other))))
			R = TRUE
			if(O.block_superconductivity()) 	//the direction and open/closed are already checked on can_atmos_pass() so there are no arguments
				atmos_supeconductivity |= dir
				T.atmos_supeconductivity |= opp
				return FALSE						//no need to keep going, we got all we asked

	atmos_supeconductivity &= ~dir
	T.atmos_supeconductivity &= ~opp

	return !R

/atom/movable/proc/block_superconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return FALSE

/turf/proc/immediate_calculate_adjacent_turfs()
	var/canpass = CANATMOSPASS(src, src)
	var/canvpass = CANVERTICALATMOSPASS(src, src)
	for(var/direction in GLOB.cardinals_multiz)
		var/turf/T = get_step_multiz(src, direction)
		if(!isopenturf(T))
			continue
		if(!(blocks_air || T.blocks_air) && ((direction & (UP|DOWN))? (canvpass && CANVERTICALATMOSPASS(T, src)) : (canpass && CANATMOSPASS(T, src))) )
			LAZYINITLIST(atmos_adjacent_turfs)
			LAZYINITLIST(T.atmos_adjacent_turfs)
			atmos_adjacent_turfs[T] = TRUE
			T.atmos_adjacent_turfs[src] = TRUE
		else
			if (atmos_adjacent_turfs)
				atmos_adjacent_turfs -= T
			if (T.atmos_adjacent_turfs)
				T.atmos_adjacent_turfs -= src
			UNSETEMPTY(T.atmos_adjacent_turfs)
	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs

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

	var/turf/current_location = src

	for (var/direction in GLOB.diagonals_multiz)
		var/matching_directions = 0
		var/turf/S = get_step_multiz(current_location, direction)
		if(!S)
			continue

		for (var/check_direction in GLOB.cardinals_multiz)
			var/turf/checkTurf = get_step(S, check_direction)
			if(!S.atmos_adjacent_turfs || !S.atmos_adjacent_turfs[checkTurf])
				continue

			if (adjacent_turfs[checkTurf])
				matching_directions++

			if (matching_directions >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/proc/air_update_turf(update = FALSE, remove = FALSE)
	var/turf/T = get_turf(loc)
	T.air_update_turf(update, remove)

/**
 * A helper proc for dealing with atmos changes
 *
 * Ok so this thing is pretty much used as a catch all for all the situations someone might wanna change something
 * About a turfs atmos. It's real clunky, and someone needs to clean it up, but not today.
 * Arguments:
 * * update - Has the state of the structures in the world changed? If so, update our adjacent atmos turf list, if not, don't.
 * * remove - Are you removing an active turf (Read wall), or adding one
*/
/turf/air_update_turf(update = FALSE, remove = FALSE)
	if(update)
		immediate_calculate_adjacent_turfs()
	if(remove)
		SSair.remove_from_active(src)
	else
		SSair.add_to_active(src)

/atom/movable/proc/move_update_air(turf/T)
	if(isturf(T))
		T.air_update_turf(TRUE, FALSE) //You're empty now
	air_update_turf(TRUE, TRUE) //You aren't

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

	air.merge(G)
	archive()
	SSair.add_to_active(src)
