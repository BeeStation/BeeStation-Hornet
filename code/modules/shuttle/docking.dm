/// This is the main proc. It instantly moves our mobile port to stationary port `new_dock`.
/obj/docking_port/mobile/proc/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	// Crashing this ship with NO SURVIVORS
	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()

	/**************************************************************************************************************
		Both lists are associative with a turf:bitflag structure. (new_turfs bitflag space unused currently)
		The bitflag contains the data for what inhabitants of that coordinate should be moved to the new location
		The bitflags can be found in __DEFINES/shuttles.dm
	*/
	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
	CHECK_TICK
	/**************************************************************************************************************/

	// The underlying old area is the area assumed to be under the shuttle's starting location
	// If it no longer/has never existed it will be created

	// The area that gets placed under where the shuttle moved from
	var/area/underlying_old_area = SHUTTLE_UNDERLYING_AREA(old_dock)

	var/rotation = 0
	if(new_dock.dir != dir) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90) //diagonal rotations not allowed, round up
		rotation = SIMPLIFY_DEGREES(rotation)

	if(!movement_direction)
		movement_direction = turn(preferred_direction, 180)

	var/list/moved_atoms = list() //Everything not a turf that gets moved in the shuttle
	var/list/areas_to_move = list() //unique assoc list of areas on turfs being moved

	. = preflight_check(old_turfs, new_turfs, areas_to_move, rotation)
	if(.)
		remove_ripples()
		return

	/*******************************************Hiding turfs if necessary*******************************************/
	// TODO: Move this somewhere sane
	var/list/new_hidden_turfs
	if(hidden)
		new_hidden_turfs = list()
		for(var/i in 1 to old_turfs.len)
			CHECK_TICK
			var/turf/oldT = old_turfs[i]
			if(old_turfs[oldT] & MOVE_TURF)
				new_hidden_turfs += new_turfs[i]
		SSshuttle.update_hidden_docking_ports(null, new_hidden_turfs)
	/***************************************************************************************************************/

	if(!force)
		if(!check_dock(new_dock))
			remove_ripples()
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	// Moving to the new location will trample the ripples there at the exact
	// same time any mobs there are trampled, to avoid any discrepancy where
	// the ripples go away before it is safe.
	takeoff(new_dock, old_turfs, new_turfs, moved_atoms, rotation, movement_direction, old_dock, underlying_old_area)

	CHECK_TICK

	cleanup_runway(new_dock, old_turfs, new_turfs, areas_to_move, moved_atoms, rotation, movement_direction, underlying_old_area)

	CHECK_TICK

	/*******************************************Unhiding turfs if necessary******************************************/
	if(new_hidden_turfs)
		SSshuttle.update_hidden_docking_ports(hidden_turfs, null)
		hidden_turfs = new_hidden_turfs
	/****************************************************************************************************************/

	check_poddoors()
	new_dock.last_dock_time = world.time
	setDir(new_dock.dir)

	// remove any stragglers just in case, and clear the list
	remove_ripples()
	return DOCKING_SUCCESS

/obj/docking_port/mobile/proc/preflight_check(list/old_turfs, list/new_turfs, list/areas_to_move, rotation)
	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		if(!newT)
			return DOCKING_NULL_DESTINATION
		if(!oldT)
			return DOCKING_NULL_SOURCE

		var/area/old_area = oldT.loc
		var/list/area/all_shuttle_areas = list()
		for(var/obj/docking_port/mobile/M in get_all_towed_shuttles())
			all_shuttle_areas |= M.shuttle_areas
		var/move_mode = old_area.beforeShuttleMove(all_shuttle_areas)											//areas

		var/list/old_contents = oldT.contents
		for(var/k in 1 to old_contents.len)
			CHECK_TICK
			var/atom/movable/moving_atom = old_contents[k]
			if(moving_atom.loc != oldT) //fix for multi-tile objects
				continue
			move_mode = moving_atom.beforeShuttleMove(newT, rotation, move_mode, src)						//atoms

		move_mode = oldT.fromShuttleMove(newT, move_mode)													//turfs
		move_mode = newT.toShuttleMove(oldT, move_mode, src)												//turfs

		if(move_mode & MOVE_AREA)
			areas_to_move[old_area] = TRUE

		old_turfs[oldT] = move_mode

/obj/docking_port/mobile/proc/takeoff(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, old_dock, area/underlying_old_area)
	var/obj/docking_port/mobile/all_towed_shuttles = get_all_towed_shuttles()
	var/list/parent_shuttles = list() //Keep track of what shuttles we're landing on in case we're relanding on a shuttle we were on.
	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		var/move_mode = old_turfs[oldT]
		if(move_mode & MOVE_CONTENTS)
			for(var/k in oldT)
				var/atom/movable/moving_atom = k
				if(moving_atom.loc != oldT) //fix for multi-tile objects
					continue
				moving_atom.onShuttleMove(newT, oldT, movement_force, movement_direction, old_dock, src)				//atoms
				moved_atoms[moving_atom] = oldT

		if(move_mode & MOVE_TURF)
			var/shuttle_layers = 1
			var/area/shuttle/A = oldT.loc
			var/obj/docking_port/mobile/M = A.mobile_port
			while(M && M != src) //We found a shuttle and its not ourselves
				shuttle_layers++
				A = M.underlying_turf_area[oldT]
				if(!A || istype(A)) //Area is no longer a shuttle area (This assumes there will never be a value for GLOB.areas_by_type[/area/shuttle])
					break
				M = A.mobile_port
			oldT.onShuttleMove(newT, movement_force, movement_direction, shuttle_layers)								//turfs

		if(move_mode & MOVE_AREA)
			var/area/shuttle/shuttle_area = oldT.loc //The area on the shuttle, typecasted for the checks further down
			var/area/shuttle/target_area = newT.loc //The area we're landing on
			var/area/shuttle/new_area //The area that we leave behind
			var/obj/docking_port/mobile/M = istype(shuttle_area) ? shuttle_area?.mobile_port : null
			var/obj/docking_port/mobile/bottom_shuttle = src //I'm just going to swallow my pride and make this its own var
			var/obj/docking_port/stationary/S
			var/area/new_dock_underlying_area
			while(M in all_towed_shuttles)
				S = M.get_docked()
				new_dock_underlying_area = S?.get_underlying_area() //If there's no area, we're relying completely on the assoc list
				new_area = M.underlying_turf_area[oldT] ? M.underlying_turf_area[oldT] : new_dock_underlying_area //Grab before we make changes
				if(oldT in M.underlying_turf_area) //Update nested shuttle's underlying_turf_area list
					underlying_turf_area -= oldT
					underlying_turf_area[newT] =  new_area
				bottom_shuttle = M // ):
				M = istype(new_area) ? new_area?.mobile_port : null //Next shuttle
			if(new_dock_underlying_area != target_area) //Place the target area under our shuttle
				bottom_shuttle.underlying_turf_area[newT] =  target_area
			if(!new_area) //This needs to not be null
				new_area = SHUTTLE_UNDERLYING_AREA(S)
			if(istype(new_area) && new_area.mobile_port && !(new_area.mobile_port in parent_shuttles) && (bottom_shuttle in new_area.mobile_port.towed_shuttles)) //Remove bottom shuttle from old parent shuttle's towed_shuttles
				new_area.mobile_port.towed_shuttles -= bottom_shuttle
			if(istype(target_area) && target_area.mobile_port) //Add bottom shuttle from new parent shuttle's towed_shuttles
				target_area.mobile_port.towed_shuttles |= bottom_shuttle
				parent_shuttles |= target_area.mobile_port

			shuttle_area.onShuttleMove(oldT, newT, new_area)															//areas



/obj/docking_port/mobile/proc/cleanup_runway(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/areas_to_move, list/moved_atoms, rotation, movement_direction, area/underlying_old_area)
	underlying_old_area.afterShuttleMove()

	// Parallax handling
	// This needs to be done before the atom after move
	var/new_parallax_dir = FALSE
	if(istype(new_dock, /obj/docking_port/stationary/transit))
		new_parallax_dir = preferred_direction
	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.afterShuttleMove(new_parallax_dir)													//areas

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.afterShuttleMove(oldT, rotation)																//turfs

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.afterShuttleMove(oldT, movement_force, dir, preferred_direction, movement_direction, rotation)//atoms

	// lateShuttleMove (There had better be a really good reason for additional stages beyond this)

	underlying_old_area.lateShuttleMove()

	for(var/i in 1 to areas_to_move.len)
		CHECK_TICK
		var/area/internal_area = areas_to_move[i]
		internal_area.lateShuttleMove()

	for(var/i in 1 to old_turfs.len)
		CHECK_TICK
		if(!(old_turfs[old_turfs[i]] & MOVE_CONTENTS | MOVE_TURF))
			continue
		var/turf/oldT = old_turfs[i]
		var/turf/newT = new_turfs[i]
		newT.lateShuttleMove(oldT)

	for(var/i in 1 to moved_atoms.len)
		CHECK_TICK
		var/atom/movable/moved_object = moved_atoms[i]
		if(QDELETED(moved_object))
			continue
		var/turf/oldT = moved_atoms[moved_object]
		moved_object.lateShuttleMove(oldT, movement_force, movement_direction)

/obj/docking_port/mobile/proc/reset_air()
	var/list/turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to length(turfs))
		var/turf/open/T = turfs[i]
		if(istype(T))
			T.air.copy_from_turf(T)
