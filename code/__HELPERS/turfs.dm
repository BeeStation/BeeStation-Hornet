///Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = FALSE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are separate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry += distance
			yoffset += eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(2)//South
			diry -= distance
			yoffset -= eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(4)//East
			dirx += distance
			yoffset += eoffsetx//Flipped.
			xoffset += eoffsety
			b1xerror -= errory//Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx
		if(8)//West
			dirx -= distance
			yoffset -= eoffsetx//Flipped.
			xoffset += eoffsety
			b1xerror -= errory//Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx

	var/turf/destination = locate(location.x+dirx,location.y+diry,location.z)

	if(!destination)//If there isn't a destination.
		return

	if(!errorx && !errory)//If errorx or y were not specified.
		if(density&&destination.density)
			return
		if(destination.x>world.maxx || destination.x<1)
			return
		if(destination.y>world.maxy || destination.y<1)
			return

	var/destination_list[] = list()//To add turfs to list.
	//destination_list = new()
	/*This will draw a block around the target turf, given what the error is.
	Specifying the values above will basically draw a different sort of block.
	If the values are the same, it will be a square. If they are different, it will be a rectengle.
	In either case, it will center based on offset. Offset is position from center.
	Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
	the offset should remain positioned in relation to destination.*/

	var/turf/center = locate((destination.x + xoffset), (destination.y + yoffset), location.z)//So now, find the new center.

	//Now to find a box from center location and make that our destination.
	for(var/turf/current_turf in block(locate(center.x + b1xerror, center.y + b1yerror, location.z), locate(center.x + b2xerror, center.y + b2yerror, location.z)))
		if(density && current_turf.density)
			continue//If density was specified.
		if(current_turf.x > world.maxx || current_turf.x < 1)
			continue//Don't want them to teleport off the map.
		if(current_turf.y > world.maxy || current_turf.y < 1)
			continue
		destination_list += current_turf

	if(!destination_list.len)
		return

	destination = pick(destination_list)
	return destination

//Returns the atom sitting on the turf.
//For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
//Optional arg 'type' to stop once it reaches a specific type instead of a turf.
/proc/get_atom_on_turf(atom/movable/M, stop_type)
	var/atom/loc = M
	while(loc && loc.loc && !isturf(loc.loc))
		loc = loc.loc
		if(stop_type && istype(loc, stop_type))
			break
	return loc
	
//Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/AM, include_turf = FALSE)
	. = list()
	var/atom/location = AM.loc
	var/turf/turf = get_turf(AM)
	while(location && location != turf)
		. += location
		location = location.loc
	if(location && include_turf) //At this point, only the turf is left, provided it exists.
		. += location
		
/// Returns the turf located at the map edge in the specified direction relative to A. Used for mass driver
/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH|EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = world.maxy
	else if(direction & SOUTH) //you should not have both NORTH and SOUTH in the provided direction
		y = 1
	if(direction & EAST)
		x = world.maxx
	else if(direction & WEST)
		x = 1
	if(direction in GLOB.diagonals) //let's make sure it's accurately-placed for diagonals
		var/lowest_distance_to_map_edge = min(abs(x - A.x), abs(y - A.y))
		return get_ranged_target_turf(A, direction, lowest_distance_to_map_edge)
	return locate(x,y,A.z)
	
/// Returns turf relative to A in given direction at set range, result is bounded to map size. Note: range is non-pythagorean. Used for disposal system
/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST) //if you have both EAST and WEST in the provided direction, then you're gonna have issues
		x = max(1, x - range)

	return locate(x,y,A.z)

/// returns turf relative to A offset in dx and dy tiles, bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/**
 * Lets the turf this atom's *ICON* appears to inhabit
 * it takes into account:
 * Pixel_x/y
 * Matrix x/y
 * NOTE: if your atom has non-standard bounds then this proc
 * will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 * this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned
**/
/proc/get_turf_pixel(atom/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	var/icon/AMicon = icon(AM.icon, AM.icon_state)
	var/AMiconheight = AMicon.Height()
	var/AMiconwidth = AMicon.Width()
	if(AMiconheight != world.icon_size || AMiconwidth != world.icon_size)
		pixel_x_offset += ((AMiconwidth/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMiconheight/world.icon_size)-1)*(world.icon_size*0.5)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

///Returns a turf based on text inputs, original turf and viewing client
/proc/params_to_turf(scr_loc, turf/origin, client/viewing_client)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(viewing_client ? viewing_client.view : world.view)
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

///Almost identical to the params_to_turf(), but unused (remove?)
/proc/screen_loc_to_turf(text, turf/origin, client/C)
	if(!text)
		return null
	var/tZ = splittext(text, ",")
	var/tX = splittext(tZ[1], "-")
	var/tY = text2num(tX[2])
	tX = splittext(tZ[2], "-")
	tX = text2num(tX[2])
	tZ = origin.z
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + round(actual_view[1] / 2) - tX, 1, world.maxx)
	tY = clamp(origin.y + round(actual_view[2] / 2) - tY, 1, world.maxy)
	return locate(tX, tY, tZ)

/// similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like spiral_range, but only turfs)
/proc/spiral_range_turfs(dist=0, center=usr, orange=0, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return L

/proc/get_random_station_turf()
	return safepick(get_area_turfs(pick(GLOB.the_station_areas)))

///Returns a random turf on the station, excludes dense turfs (like walls) and areas that have valid_territory set to FALSE
/proc/get_safe_random_station_turf(list/areas_to_pick_from = GLOB.the_station_areas)
	for (var/i in 1 to 5)
		var/list/turf_list = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target
		while (turf_list.len && !target)
			var/I = rand(1, turf_list.len)
			var/turf/checked_turf = turf_list[I]
			var/area/turf_area = get_area(checked_turf)
			if(!checked_turf.density && (turf_area.area_flags & VALID_TERRITORY))
				var/clear = TRUE
				for(var/obj/checked_object in checked_turf)
					if(checked_object.density)
						clear = FALSE
						break
				if(clear)
					target = checked_turf
			if (!target)
				turf_list.Cut(I, I + 1)
		if (target)
			return target

/**
 * Checks whether the target turf is in a valid state to accept a directional window
 * or other directional pseudo-dense object such as railings.
 *
 * Returns FALSE if the target turf cannot accept a directional window or railing.
 * Returns TRUE otherwise.
 *
 * Arguments:
 * * dest_turf - The destination turf to check for existing windows and railings
 * * test_dir - The prospective dir of some atom you'd like to put on this turf.
 * * is_fulltile - Whether the thing you're attempting to move to this turf takes up the entire tile or whether it supports multiple movable atoms on its tile.
 */
//can a window be here, or is there a window blocking it?
/proc/valid_window_location(turf/T, dir_to_check)
	if(!T)
		return FALSE
	for(var/obj/O in T)
		if(istype(O, /obj/machinery/door/window) && (O.dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR))
			return FALSE
		if(istype(O, /obj/structure/windoor_assembly))
			var/obj/structure/windoor_assembly/W = O
			if(W.ini_dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
		if(istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			if(W.ini_dir == dir_to_check || W.ini_dir == FULLTILE_WINDOW_DIR || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
		if(istype(O, /obj/structure/railing))
			var/obj/structure/railing/rail = O
			if(rail.ini_dir == dir_to_check || rail.ini_dir == FULLTILE_WINDOW_DIR || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
	return TRUE
