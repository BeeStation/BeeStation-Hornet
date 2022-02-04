/turf/open/space/transit
	name = "\proper hyperspace"
	icon_state = "black"
	dir = SOUTH
	baseturfs = /turf/open/space/transit
	flags_1 = NOJAUNT_1 //This line goes out to every wizard that ever managed to escape the den. I'm sorry.
	explosion_block = INFINITY

/turf/open/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "speedspace_ns_[get_transit_state(asking_turf)]"
	underlay_appearance.transform = turn(matrix(), get_transit_angle(asking_turf))

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/horizontal
	dir = WEST

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/turf/open/space/transit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!locate(/obj/structure/lattice) in src)
		throw_atom(arrived, old_loc)

/turf/open/space/transit/proc/throw_atom(atom/movable/AM, atom/OldLoc)
	set waitfor = FALSE
	if(!AM || istype(AM, /obj/docking_port) || istype(AM, /obj/effect/abstract))
		return
	if(AM.loc != src) 	// Multi-tile objects are "in" multiple locs but its loc is it's true placement.
		return			// Don't move multi tile objects if their origin isn't in transit
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	//Find our location
	var/_z = 2

	var/should_make_level = ismob(AM)
	if(!should_make_level && isitem(AM))
		var/obj/item/I = AM
		if(I.resistance_flags & INDESTRUCTIBLE)	//incase there is an important item
			should_make_level = TRUE

	if(should_make_level)
		//Check if we are on a shuttle
		var/turf/oldTurf = get_turf(OldLoc)
		var/area/shuttle/shuttleArea = get_area(oldTurf)
		if(istype(shuttleArea))
			var/shuttleId = shuttleArea.mobile_port?.id || "null"
			//Find the shuttle object
			var/datum/orbital_object/shuttle/shuttleObj = SSorbits.assoc_shuttles[shuttleId]
			if(shuttleObj)
				if(length(shuttleObj.can_dock_with?.linked_z_level))
					_z = shuttleObj.can_dock_with.linked_z_level[1].z_value
				else if(length(shuttleObj.docking_target?.linked_z_level))
					_z = shuttleObj.docking_target.linked_z_level[1].z_value
				else
					//Interdiction (Its an empty z-level)
					var/datum/orbital_object/z_linked/beacon/ruin/z_linked = new /datum/orbital_object/z_linked/beacon/ruin/interdiction(
						new /datum/orbital_vector(shuttleObj.position.x, shuttleObj.position.y)
					)
					z_linked.name = "Stranded [AM]"
					z_linked.assign_z_level()
					if(length(z_linked.linked_z_level))
						_z = z_linked.linked_z_level[1].z_value
	if(_z == 2)
		//Chuck them at the space level
		for(var/A in SSmapping.z_list)
			var/datum/space_level/D = A
			if (D.linkage == CROSSLINKED)
				_z = D.z_value
				break

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/turf/T = locate(_x, _y, _z)
	AM.forceMove(T)


/turf/open/space/transit/CanBuildHere()
	return SSshuttle.is_in_shuttle_bounds(src)


/turf/open/space/transit/Initialize()
	. = ..()
	update_icon()
	for(var/atom/movable/AM in src)
		throw_atom(AM, src)

/turf/open/space/transit/update_icon()
	. = ..()
	transform = turn(matrix(), get_transit_angle(src))

/turf/open/space/transit/update_icon_state()
	icon_state = "speedspace_ns_[get_transit_state(src)]"

/proc/get_transit_state(turf/T)
	var/p = 9
	. = 1
	switch(T.dir)
		if(NORTH)
			. = ((-p*T.x+T.y) % 15) + 1
			if(. < 1)
				. += 15
		if(EAST)
			. = ((T.x+p*T.y) % 15) + 1
		if(WEST)
			. = ((T.x-p*T.y) % 15) + 1
			if(. < 1)
				. += 15
		else
			. = ((p*T.x+T.y) % 15) + 1

/proc/get_transit_angle(turf/T)
	. = 0
	switch(T.dir)
		if(NORTH)
			. = 180
		if(EAST)
			. = 90
		if(WEST)
			. = -90
