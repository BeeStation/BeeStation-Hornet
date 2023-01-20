/// Gets all contents of contents and returns them all in a list.
/atom/proc/GetAllContents(var/T, ignore_flag_1)
	var/list/processing_list = list(src)
	var/list/assembled = list()
	if(T)
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			processing_list += A.contents
			if(istype(A,T))
				assembled += A
	else
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			if(!(A.flags_1 & ignore_flag_1))
				processing_list += A.contents
			assembled += A
	return assembled

/// Gets all contents of contents and returns them all in a list, ignoring a chosen typecache.
//Update GetAllContentsIgnoring to get_all_contents_ignoring so it easier to read in
/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	var/list/assembled = list()
	while(processing.len)
		var/atom/A = processing[1]
		processing.Cut(1,2)
		if(!ignore_typecache[A.type])
			processing += A.contents
			assembled += A
	return assembled

//Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/our_turf = get_turf(atom_on_location)
	while(location && location != our_turf)
		. += location
		location = location.loc
	if(our_turf && include_turf) //At this point, only the turf is left, provided it exists.
		. += our_turf

/// Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 1
	if(current != target_turf)
		current = get_step_towards(current, target_turf)
		while(current != target_turf)
			if(steps > length)
				return 0
			if(current.opacity)
				return 0
			for(var/thing in current)
				var/atom/A = thing
				if(A.opacity)
					return 0
			current = get_step_towards(current, target_turf)
			steps++

	return 1

///Get the cardinal direction between two atoms
/proc/get_cardinal_dir(atom/start, atom/end)
	var/dx = abs(end.x - start.x)
	var/dy = abs(end.y - start.y)
	return get_dir(start, end) & (rand() * (dx+dy) < dy ? 3 : 12)

/**
 * Finds the distance between two atoms, in pixels
 * centered = FALSE counts from turf edge to edge
 * centered = TRUE counts from turf center to turf center
 * of course mathematically this is just adding world.icon_size on again
**/
/proc/get_pixel_distance(atom/start, atom/end, centered = TRUE)
	if(!istype(start) || !istype(end))
		return 0
	. = bounds_dist(start, end) + sqrt((((start.pixel_x + end.pixel_x) ** 2) + ((start.pixel_y + end.pixel_y) ** 2)))
	if(centered)
		. += world.icon_size

/**
 * Check if there is already a wall item on the turf loc
 * floor_loc = floor tile in front of the wall
 * dir_toward_wall = direction from the floor tile in front of the wall towards the wall
 * check_external = truthy if we should be checking against items coming out of the wall, rather than visually on top of the wall.
**/
/proc/check_wall_item(floor_loc, dir_toward_wall, check_external = 0)
	var/wall_loc = get_step(floor_loc, dir_toward_wall)
	for(var/obj/checked_object in floor_loc)
		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_INTERIOR) && !check_external)
			//Direction works sometimes
			if(checked_object.dir == dir_toward_wall)
				return TRUE

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			//That's exactly what get_turf_pixel() does
			if(get_turf_pixel(checked_object) == wall_loc)
				return TRUE

		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_EXTERIOR) && check_external)
			if(checked_object.dir == dir_toward_wall)
				return TRUE

	//Some stuff is placed directly on the wallturf (signs).
	//If we're only checking for external entities, we don't need to look though these.
	if (check_external)
		return FALSE
	for(var/obj/checked_object in wall_loc)
		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_INTERIOR))
			if(checked_object.pixel_x == 0 && checked_object.pixel_y == 0)
				return TRUE
	return FALSE

///Forces the atom to take a step in a random direction
/proc/random_step(atom/movable/moving_atom, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(moving_atom, pick(GLOB.alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

//Compare source's dir, the clockwise dir of source and the anticlockwise dir of source
//To the opposite dir of the dir returned by get_dir(target,source)
//If one of them is a match, then source is facing target
/proc/is_source_facing_target(atom/source,atom/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(isliving(source))
		var/mob/living/source_mob = source
		if(source_mob.mobility_flags & MOBILITY_STAND)
			return FALSE
	var/goal_dir = get_dir(source, target)
	var/clockwise_source_dir = turn(source.dir, -45)
	var/anticlockwise_source_dir = turn(source.dir, 45)

	if(source.dir == goal_dir || clockwise_source_dir == goal_dir || anticlockwise_source_dir == goal_dir)
		return TRUE
	return FALSE

/*
rough example of the "cone" made by the 3 dirs checked
 B
  \
   \
    >
      <
       \
        \
B --><-- A
        /
       /
      <
     >
    /
   /
 B
*/

///ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist = 0, atom/center = usr, orange = FALSE, areas = FALSE)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/turf/checked_turf as anything in turfs)
		. += checked_turf
		. += checked_turf.contents
		if(areas)
			. |= checked_turf.loc

///similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/spiral_range(dist = 0, center = usr, orange = FALSE)
	var/list/atom_list = list()
	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	if(!orange)
		atom_list += t_center
		atom_list += t_center.contents

	if(!dist)
		return atom_list


	var/turf/checked_turf
	var/y
	var/x
	var/c_dist = 1


	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y - c_dist to y)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x - c_dist to x)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents
		c_dist++

	return atom_list

///Returns the closest atom of a specific type in a list from a source
/proc/get_closest_atom(type, list/atom_list, source)
	var/closest_atom
	var/closest_distance
	for(var/atom in atom_list)
		if(!istype(atom, type))
			continue
		var/distance = get_dist(source, atom)
		if(!closest_atom)
			closest_distance = distance
			closest_atom = atom
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = atom
	return closest_atom

///Returns a chosen path that is the closest to a list of matches
/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if (value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if (isnull(value))
			return
	value = trim(value)

	var/random = FALSE
	if(findtext(value, "?"))
		value = replacetext(value, "?", "")
		random = TRUE

	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else if(random)
		chosen = pick(matches) || null
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in sort_list(matches)
	if(!chosen)
		return
	chosen = matches[chosen]
	return chosen

///Creates new items inside an atom based on a list
/proc/generate_items_inside(list/items_list, where_to)
	for(var/each_item in items_list)
		for(var/i in 1 to items_list[each_item])
			new each_item(where_to)

///Returns the atom type in the specified loc
/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

///Returns true if the src countain the atom target
/atom/proc/contains(atom/target)
	if(!target)
		return FALSE
	for(var/atom/location = target.loc, location, location = location.loc)
		if(location == src)
			return TRUE

///A do nothing proc
/proc/pass(...)
	return

/proc/get_final_z(atom/A)
	var/turf/T = get_turf(A)
	return T ? T.z : A.z

//Proc currently not used
/proc/get_step_towards2(atom/ref , atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile)
			return get_step(ref, base_dir)
		else
			return get_step_towards(ref,free_tile)

	else
		return get_step(ref, base_dir)

/// same as do_mob except for movables and it allows both to drift and doesn't draw progressbar
/proc/do_atom(atom/movable/user , atom/movable/target, time = 30, uninterruptible = 0,datum/callback/extra_checks = null)
	if(!user || !target)
		return TRUE
	var/user_loc = user.loc

	var/drifting = FALSE
	if(SSmove_manager.processing_on(user, SSspacedrift))
		drifting = TRUE

	var/target_drifting = FALSE
	if(SSmove_manager.processing_on(user, SSspacedrift))
		target_drifting = TRUE

	var/target_loc = target.loc

	var/endtime = world.time+time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if(QDELETED(user) || QDELETED(target))
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && SSmove_manager.processing_on(user, SSspacedrift))
			drifting = FALSE
			user_loc = user.loc

		if(target_drifting && SSmove_manager.processing_on(user, SSspacedrift))
			target_drifting = FALSE
			target_loc = target.loc

		if((!drifting && user.loc != user_loc) || (!target_drifting && target.loc != target_loc) || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break
