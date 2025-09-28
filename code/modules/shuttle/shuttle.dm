//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
#ifdef TESTING
#define DOCKING_PORT_HIGHLIGHT
#endif

GLOBAL_LIST_INIT(shuttle_turf_blacklist, typecacheof(list(
	/turf/baseturf_bottom,
	/turf/open/space,
	/turf/open/lava,
	/turf/open/floor/dock/drydock
)))

CREATION_TEST_IGNORE_SUBTYPES(/obj/docking_port)

//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "pinonfar"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	/// The identifier of the port or ship.
	/// This will be used in numerous other places like the console,
	/// stationary ports and whatnot to tell them your ship's mobile
	/// port can be used in these places, or the docking port is compatible, etc.
	var/id
	///Common standard is for this to point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	///size of covered area, perpendicular to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/width = 0
	///size of covered area, parallel to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/height = 0
	///position relative to covered area, perpendicular to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/dwidth = 0
	///position relative to covered area, parallel to dir. You shouldn't modify this for mobile dockingports, set automatically.
	var/dheight = 0

	///are we invisible to shuttle navigation computers?
	var/hidden = FALSE

	///Delete this port after ship fly off.
	var/delete_after = FALSE

	//The shuttle docked here/dock we're parked at.
	var/obj/docking_port/docked

/obj/docking_port/get_save_vars()
	return list("pixel_x", "pixel_y", "dir", "name", "req_access", "req_access_txt", "piping_layer", "color", "icon_state", "pipe_color", "amount", "width", "height", "dwidth", "dheight")

	//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		if(docked)
			docked.docked = null
			docked = null
		..()
		. = QDEL_HINT_QUEUE
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/has_gravity(turf/current_turf)
	return TRUE

/obj/docking_port/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	return

/obj/docking_port/singularity_pull()
	return
/obj/docking_port/singularity_act()
	return 0

//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y

	//In relative shuttle space, (dwidth, dheight) is the vector pointing from the bottom left corner of the bounding box to the obj/docking_port.
	//Therefore, the negative of this vector (-dwidth,-dheight) points to one corner of the bounding box when the obj/docking_port is at the origin.
	//Next, we rotate according to the specified direction and translate to our location in world space, the translate vector in the matrix, mat0, is one of the coordinates.
	var/matrix/mat0 = matrix(-dwidth, -dheight, MATRIX_TRANSLATE) * matrix(dir2angle(_dir), MATRIX_ROTATE) * matrix(_x, _y, MATRIX_TRANSLATE)
	//The opposite corner of the bounding box in relative shuttle vector space is at (width-dwidth-1,height-dheight-1)
	//Because matrix multipication is associative, all we need to do is left multiply the missing parts of this vector to mat0 to get the other coordinate in world space.
	var/matrix/mat1 = matrix(width-1, height-1, MATRIX_TRANSLATE) * mat0

	return list(
		mat0.c,
		mat0.f,
		mat1.c,
		mat1.f
		)

//returns the dwidth, dheight, width, and height in that order of the union bounds of all shuttles relative to our shuttle.
/obj/docking_port/proc/return_union_bounds(list/obj/docking_port/others)
	var/list/coords =  return_union_coords(others, 0, 0, NORTH)
	var/X0 = min(coords[1],coords[3]) //This will be the negative dwidth of the combined bounds
	var/Y0 = min(coords[2],coords[4]) //This will be the negative dheight of the combined bounds
	var/X1 = max(coords[1],coords[3]) //equal to width-dwidth-1
	var/Y1 = max(coords[2],coords[4]) //equal to height-dheight-1
	return list(-X0, -Y0, X1-X0+1,Y1-Y0+1)

//Returns the the bounding box fully containing all provided docking ports
/obj/docking_port/proc/return_union_coords(list/obj/docking_port/others, _x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y
	if(!islist(others))
		others = list(others)
	others |= src
	. = list(_x,_y,_x,_y)
	//Right multiply with this matrix to transform a vector in world space to the our shuttle space specified by the parameters.
	//This is the reason why we're not calling return_coords for each shuttle, we save time by not reconstructing the matrices lost after they're popped off the call stack
	var/matrix/to_shuttle_space = matrix(_x-x, _y-y, MATRIX_TRANSLATE) * matrix(dir2angle(_dir)-dir2angle(dir), MATRIX_ROTATE)
	for(var/obj/docking_port/other in others)
		var/matrix/mat0 = matrix(-other.dwidth, -other.dheight, MATRIX_TRANSLATE) * matrix(dir2angle(other.dir), MATRIX_ROTATE) * matrix(other.x, other.y, MATRIX_TRANSLATE) * to_shuttle_space
		var/matrix/mat1 = matrix(other.width-1, other.height-1, MATRIX_TRANSLATE) * mat0
		. = list(
			min(.[1], mat0.c, mat1.c),
			min(.[2], mat0.f, mat1.f),
			max(.[3], mat0.c, mat1.c),
			max(.[4], mat0.f, mat1.f)
		)

//Returns the bounding box containing only the intersection of all provided docking ports
/obj/docking_port/proc/return_intersect_coords(list/obj/docking_port/others, _x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y
	if(!islist(others))
		others = list(others)
	others |= src
	. = list(_x,_y,_x,_y)
	//See return_union_coords() and return_coords() for explaination of the matrices.
	var/matrix/to_shuttle_space = matrix(_x-x, _y-y, MATRIX_TRANSLATE) * matrix(dir2angle(_dir)-dir2angle(dir), MATRIX_ROTATE)
	for(var/obj/docking_port/other in others)
		var/matrix/mat0 = matrix(-other.dwidth, -other.dheight, MATRIX_TRANSLATE) * matrix(dir2angle(other.dir), MATRIX_ROTATE) * matrix(other.x, other.y, MATRIX_TRANSLATE) * to_shuttle_space
		var/matrix/mat1 = matrix(other.width-1, other.height-1, MATRIX_TRANSLATE) * mat0
		. = list(
			max(.[1], min(mat0.c, mat1.c)),
			max(.[2], min(mat0.f, mat1.f)),
			min(.[3], max(mat0.c, mat1.c)),
			min(.[4], max(mat0.f, mat1.f)),
		)

//returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	return block(T0,T1)

//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir)
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	for(var/dx in 0 to width-1)
		var/compX = dx-dwidth
		for(var/dy in 0 to height-1)
			var/compY = dy-dheight
			// realX = _x + compX*cos - compY*sin
			// realY = _y + compY*cos - compX*sin
			// locate(realX, realY, _z)
			var/turf/T = locate(_x + compX*cos - compY*sin, _y + compY*cos + compX*sin, _z)
			.[T] = NONE

#ifdef DOCKING_PORT_HIGHLIGHT
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		LAZYINITLIST(T.atom_colours)
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

/obj/docking_port/proc/getDockedId()
	if(docked)
		return docked.id

/obj/docking_port/proc/is_in_shuttle_bounds(atom/A)
	var/turf/T = get_turf(A)
	if(T.z != z)
		return FALSE
	var/list/bounds = return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	if(!ISINRANGE(T.x, min(x0, x1), max(x0, x1)))
		return FALSE
	if(!ISINRANGE(T.y, min(y0, y1), max(y0, y1)))
		return FALSE
	return TRUE

/obj/docking_port/stationary
	name = "dock"

	var/last_dock_time

	var/datum/map_template/shuttle/roundstart_template
	var/json_key

/obj/docking_port/stationary/Initialize(mapload)
	..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	if(mapload)
		for(var/turf/T in return_turfs())
			T.flags_1 |= NO_RUINS_1

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif

	return INITIALIZE_HINT_LATELOAD


/obj/docking_port/stationary/LateInitialize()
	. = ..()
	if(SSshuttle.shuttles_loaded)
		load_roundstart()


/obj/docking_port/stationary/Destroy(force)
	if(force)
		SSshuttle.stationary -= src
	. = ..()

/obj/docking_port/stationary/proc/load_roundstart()
	if(json_key)
		var/sid = SSmapping.current_map.shuttles[json_key]
		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("json_key:[json_key] value \[[sid]\] resulted in a null shuttle template for [src]")
	else if(roundstart_template) // passed a PATH
		var/sid = "[initial(roundstart_template.port_id)]_[initial(roundstart_template.suffix)]"

		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("Invalid path ([roundstart_template]) passed to docking port.")

	if(roundstart_template)
		SSshuttle.action_load(roundstart_template, src)

/obj/docking_port/stationary/transit
	name = "In Transit"
	var/datum/turf_reservation/reserved_area
	var/area/shuttle/transit/assigned_area
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/Initialize(mapload)
	. = ..()
	SSshuttle.transit += src

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(docked)
			log_world("A transit dock was destroyed while something was docked to it.")
		SSshuttle.transit -= src
		if(owner)
			if(owner.assigned_transit == src)
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()

/obj/docking_port/mobile
	name = "shuttle"
	icon_state = "pinonclose"

	var/area_type = SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE

	var/list/shuttle_areas

	///Speed multiplier based on station alert level
	var/alert_coeff = ALERT_COEFF_BLUE
	///used as a timer (if you want time left to complete move, use timeLeft proc)
	var/timer
	var/last_timer_length
	///current shuttle mode
	var/mode = SHUTTLE_IDLE
	///time spent in transit (deciseconds). Should not be lower then 10 seconds without editing the animation of the hyperspace ripples.
	var/callTime = 100
	/// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	var/ignitionTime = 55
	/// time spent after arrival before being able to begin ignition
	var/rechargeTime = 0
	/// time spent after transit 'landing' before actually arriving
	var/prearrivalTime = 0

	/// The direction the shuttle prefers to travel in, ie what direction
	/// the animation will cause it to appear to be traveling in
	var/preferred_direction = NORTH
	/// relative direction of the docking port from the front of the shuttle
	/// NORTH is towards front, EAST would be starboard side, WEST port, etc.
	var/port_direction = NORTH

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit

	var/launch_status = NOLAUNCH

	///Whether or not you want your ship to knock people down, and also whether it will throw them several tiles upon launching.
	var/list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	var/list/ripples = list()
	var/engine_coeff = 1
	var/current_engines = 0
	var/initial_engines = 0
	var/list/engine_list = list()
	//If this shuttle can move docking ports other than the one it is docked at
	var/can_move_docking_ports = FALSE
	var/list/hidden_turfs = list()
	var/list/towed_shuttles = list()
	var/list/underlying_turf_area = list()
	//If the shuttle is unable to be moved by non-untowable shuttles.
	//Stops interference with the arrival and escape shuttle. Use this sparingly.
	var/untowable = FALSE
	//If docking on this shuttle is not allowed.
	//For important shuttles such as the arrivals shuttle where access to its shuttle area type is needed at any moment
	var/undockable = FALSE

	//The designated virtual Z-Value of this shuttle
	var/virtual_z
	//The virtual Z-value this shuttle is at
	var/current_z

	var/sound_played = 0 //If the launch sound has been sent to all players on the shuttle itself

	var/shuttle_object_type = /datum/orbital_object/shuttle

	var/dynamic_id = FALSE

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile |= src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		QDEL_NULL(assigned_transit)		//don't need it where we're goin'!
		shuttle_areas = null
		towed_shuttles = null
		underlying_turf_area = null
		remove_ripples()
	. = ..()

/obj/docking_port/mobile/is_in_shuttle_bounds(atom/A)
	return shuttle_areas[get_area(A)]

/obj/docking_port/mobile/proc/add_turf(turf/T, area/shuttle/A)
	if(!shuttle_areas[A]) //Invalid area
		return TRUE

	var/bypass_skipover_insertion = FALSE
	if(GLOB.shuttle_turf_blacklist[T.type]) //Check if the turf is valid
		for(var/obj/structure/lattice/lattice in T.contents)
			bypass_skipover_insertion = TRUE
		if(!bypass_skipover_insertion)
			return TRUE

	if(!bypass_skipover_insertion)
		T.baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs) //We need this as a list for now
		var/base_length = length(T.baseturfs)
		var/skipover_index = 2 //We should always leave atleast something else below our skipover

		var/BT
		for(var/i in 0 to base_length-1) //Place the skipover after the first blacklisted baseturf from the top
			BT = T.baseturfs[base_length - i]
			if(BT == /turf/baseturf_skipover/shuttle) //This is a shuttle and we can't build on it
				if(length(T.baseturfs) == 1)
					T.baseturfs = T.baseturfs[1] //Back to a single value. I wish this wasn't a thing but I fear everything would break if I left it as a list
				return TRUE
			if(GLOB.shuttle_turf_blacklist[BT])
				skipover_index = base_length - i + 1
				break
		var/list/sanity = T.baseturfs.Copy()
		sanity.Insert(skipover_index, /turf/baseturf_skipover/shuttle)
		T.baseturfs = baseturfs_string_list(sanity, T)

	var/area/shuttle/current_area = T.loc
	//Account for building on shuttles
	if(istype(current_area) && current_area.mobile_port)
		current_area.mobile_port.towed_shuttles |= src
	//add to underlying_turf_area
	if(!shuttle_areas[current_area]) //We already have this turf
		underlying_turf_area[T] = current_area
	//Change areas
	current_area.contents -= T
	T.change_area(current_area, A)

/obj/docking_port/mobile/proc/remove_turf(turf/T)

	var/area/shuttle/A = get_area(T)
	var/area/shuttle/new_area = underlying_turf_area[T]

	if(!new_area) //Our shuttle isn't here
		return TRUE

	var/shuttle_layers = -1*A.get_missing_shuttles(T)
	var/obj/docking_port/mobile/top_shuttle = A?.mobile_port
	var/list/all_towed_shuttles = get_all_towed_shuttles()
	var/obj/docking_port/mobile/bottom_shuttle = null

	//Find how many skipover deep out shuttle is and find the shuttle above ours on this turf
	for(var/index in 0 to all_towed_shuttles.len - 1)
		var/obj/docking_port/mobile/M = all_towed_shuttles[all_towed_shuttles.len - index]
		if(!M.underlying_turf_area[T])
			continue
		if(M != src)
			bottom_shuttle = M
		shuttle_layers++

	if(shuttle_layers > 0)
		var/BT_index = length(T.baseturfs)
		var/BT
		for(var/i in 1 to shuttle_layers)
			while(BT_index)
				BT = T.baseturfs[BT_index--]
				if(BT == /turf/baseturf_skipover/shuttle)
					break
		if(!BT_index)
			CRASH("A turf being removed from a shuttle has too few skipover in its baseturfs. [T]([T.type]):[T.loc]")
		T.baseturfs.Cut(BT_index+1,BT_index+2)
		if(T.baseturfs.len == 1) //Make the list not a list if length is 1
			T.baseturfs = T.baseturfs[1]

	//Get the new area under this turf
	var/list/intersect_bounds
	var/turf/T0
	var/turf/T1
	var/towed
	underlying_turf_area -= T
	if(top_shuttle == src) //Only change the area if we aren't covered by another shuttle
		A.contents -= T
		T.change_area(A, new_area)
	else if(bottom_shuttle) //update the underlying turfs of the shuttle on top of us
		bottom_shuttle.underlying_turf_area[T] = new_area
		intersect_bounds = return_intersect_coords(bottom_shuttle)
		T0 = locate(intersect_bounds[1], intersect_bounds[2], z)
		T1 = locate(intersect_bounds[3], intersect_bounds[4], z)
		towed = TRUE
		for(var/turf/intersect_turf in block(T0,T1))
			if(shuttle_areas[bottom_shuttle.underlying_turf_area[intersect_turf]])
				towed = FALSE
				break
		if(towed)
			towed_shuttles -= bottom_shuttle

	//update towed_shuttles of the shuttle under us
	if(istype(new_area) && new_area.mobile_port)
		var/obj/docking_port/mobile/other = new_area.mobile_port
		intersect_bounds = return_intersect_coords(new_area.mobile_port)
		T0 = locate(intersect_bounds[1], intersect_bounds[2], z)
		T1 = locate(intersect_bounds[3], intersect_bounds[4], z)
		towed = TRUE
		for(var/turf/intersect_turf in block(T0,T1))
			if(other.shuttle_areas[underlying_turf_area[intersect_turf]])
				towed = FALSE
				break
		if(towed)
			other.towed_shuttles -= src


//A common proc used to find the amount of turfs in the shuttle
/obj/docking_port/mobile/proc/calculate_mass()
	. = 0
	for(var/obj/docking_port/mobile/M in get_all_towed_shuttles())
		. += M.underlying_turf_area.len

/obj/docking_port/mobile/return_ordered_turfs(_x, _y, _z, _dir, include_towed = TRUE)
	if(!include_towed) //I hate this, but I need to access the superfunction somehow.
		return ..()
	. = list()
	for(var/obj/docking_port/mobile/M in get_all_towed_shuttles())
		var/matrix/translate_vec = matrix(M.x - src.x, M.y - src.y, MATRIX_TRANSLATE) * matrix(dir2angle(_dir)-dir2angle(dir), MATRIX_ROTATE)
		. |= M.return_ordered_turfs(_x + translate_vec.c, _y + translate_vec.f, _z + (M.z - src.z), angle2dir_cardinal(dir2angle(_dir) + (dir2angle(M.dir) - dir2angle(src.dir))), include_towed = FALSE)

//Returns all shuttles on top of this shuttle.
//This list is topologically sorted; for any shuttle that is above another shuttle, the higher shuttle will come after the lower shuttle in the list.
/obj/docking_port/mobile/proc/get_all_towed_shuttles()
	//Generate a list of all edges in the towed shuttle heirarchy with src as the root.
	var/list/edges = list(src)
	var/obj/docking_port/mobile/M
	var/dequeue_pointer = 0
	while(dequeue_pointer++ < length(edges))
		M = edges[dequeue_pointer]
		for(var/obj/docking_port/mobile/child in M.towed_shuttles)
			edges[child] = edges[child] ? edges[child] | M : list(M)
	edges -= src

	//Kahn's Algorithm for topological sorting a directed acyclic graph.
	. = list()
	var/list/obj/docking_port/mobile/roots = list(src)
	var/obj/docking_port/mobile/root
	while(roots.len)
		root = pop(roots)
		.[root] = TRUE
		for(M in root.towed_shuttles)
			edges[M] -= root
			if(!length(edges[M]))
				edges -= M
				roots += M
	if(edges.len) //If the graph is cyclic, that means that a shuttle is directly or indirectly landed ontop of itself. Cyclic shuttles have not moved from edges to .
		CRASH("The towed shuttles of [src] is cyclic, a shuttle is ontop of itself!")

/obj/docking_port/newtonian_move(direction, instant = FALSE) // Please don't spacedrift thanks
	return TRUE

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()

	if(!id)
		id = "[SSshuttle.mobile.len]"
	else if(dynamic_id)
		name = "[name] [SSshuttle.mobile.len]"
		id = "[id][SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/shuttle/cur_area = curT.loc
		if(istype(cur_area, area_type) && !istype(cur_area, /area/shuttle/transit))
			shuttle_areas[cur_area] = TRUE
			if(!cur_area.mobile_port)
				cur_area.link_to_shuttle(src)
		//Link up shuttle consoles
		if(dynamic_id)
			var/obj/machinery/computer/shuttle_flight/flight_computer = locate() in curT
			if(!flight_computer)
				continue
			flight_computer.shuttleId = "[id]"
			flight_computer.shuttlePortId = "[id]_custom"

	//Find open dock here and set it as ours
	for(var/obj/docking_port/stationary/S in loc.contents)
		if(!S.docked)
			S.docked = src
			docked = S
			break

	initial_engines = count_engines()
	current_engines = initial_engines

	virtual_z = get_new_virtual_z()
	current_z = virtual_z

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

// Called after the shuttle is loaded from template
/obj/docking_port/mobile/proc/linkup(datum/map_template/shuttle/template, obj/docking_port/stationary/dock)
	var/list/static/shuttle_id = list()
	var/idnum = ++shuttle_id[template]
	if(idnum > 1)
		if(id == initial(id))
			id = "[id][idnum]"
		if(name == initial(name))
			name = "[name] [idnum]"
	for(var/place in shuttle_areas)
		var/area/area = place
		area.connect_to_shuttle(src, dock, idnum, FALSE)
		for(var/each in place)
			var/atom/atom = each
			atom.connect_to_shuttle(src, dock, idnum, FALSE)


//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	if(untowable)
		return TRUE
	for(var/obj/docking_port/mobile/M in get_all_towed_shuttles())
		if(M.untowable)
			return FALSE
	return TRUE

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	//coordinate of combined shuttle bounds in our dock's vector space (positive Y towards shuttle direction, positive determinant, our dock at (0,0))
	var/list/bounds = return_union_bounds(get_all_towed_shuttles())
	var/tow_dwidth = bounds[1]
	var/tow_dheight = bounds[2]
	var/tow_rwidth = bounds[3] - tow_dwidth
	var/tow_rheight = bounds[4] - tow_dheight
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK

	if(tow_dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE

	if(tow_rwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE

	if(tow_dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE

	if(tow_rheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE

	//check the dock isn't occupied
	var/currently_docked = S.docked
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED

	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S, silent=FALSE)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else
		if(status != SHUTTLE_ALREADY_DOCKED && !silent) // SHUTTLE_ALREADY_DOCKED is no cause for error
			var/msg = "Shuttle [src] cannot dock at [S], error: [status]"
			message_admins(msg)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE

/obj/docking_port/mobile/proc/transit_failure()
	message_admins("Shuttle [src] repeatedly failed to create transit zone.")

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(!check_dock(S))
		testing("check_dock failed on request for [src]")
		return TRUE

	if(mode == SHUTTLE_IGNITING && destination == S)
		return TRUE

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime * engine_coeff)
					setTimer(callTime * engine_coeff)
			else
				destination = S
				setTimer(callTime * engine_coeff)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime * engine_coeff - timeLeft(1))
			else
				destination = S
				setTimer(callTime * engine_coeff)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	remove_ripples()

	invertTimer()
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	if((SSshuttle.lockdown && is_station_level(z)) || !canMove())	//emp went off, no escape
		mode = SHUTTLE_IDLE
		return
	previous = null
	if(!destination)
		// sent to transit with no destination -> unlimited timer
		timer = INFINITY
	var/obj/docking_port/stationary/S0 = docked
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(initiate_docking(S1) != DOCKING_SUCCESS)
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			if(S0.delete_after)
				qdel(S0, TRUE)
			else
				previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")


/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)

	// If the shuttle is docked to a stationary port, restore its normal
	// "empty" area and turf

	var/list/all_towed_shuttles = get_all_towed_shuttles()
	var/list/all_shuttle_areas = list()
	for(var/obj/docking_port/mobile/M in all_towed_shuttles)
		all_shuttle_areas += M.shuttle_areas

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		if(!all_shuttle_areas[oldT?.loc])
			continue
		var/area/old_area = oldT.loc
		for(var/obj/docking_port/mobile/bottom_shuttle as() in all_towed_shuttles)
			if(bottom_shuttle.underlying_turf_area[oldT])
				var/area/underlying_area = bottom_shuttle.underlying_turf_area[oldT]
				oldT.change_area(old_area, underlying_area)
				oldT.empty(FALSE)
				break

		// Here we locate the bottommost shuttle boundary and remove all turfs above it
		var/list/baseturf_cache = oldT.baseturfs
		for(var/k in 1 to length(baseturf_cache))
			if(ispath(baseturf_cache[k], /turf/baseturf_skipover/shuttle))
				oldT.ScrapeAway(baseturf_cache.len - k + 1)
				break

	for(var/obj/docking_port/mobile/shuttle in all_towed_shuttles)
		qdel(shuttle, force=TRUE)

/obj/docking_port/mobile/proc/intoTheSunset()
	// Loop over mobs
	for(var/t in return_turfs())
		var/turf/T = t
		for(var/mob/living/M in T.GetAllContents())
			// If they have a mind and they're not in the brig, they escaped
			if(M.mind && !istype(t, /turf/open/floor/mineral/plastitanium/red/brig))
				M.mind.force_escaped = TRUE
			// Ghostize them and put them in nullspace stasis (for stat & possession checks)
			M.notransform = TRUE
			M.ghostize(FALSE)
			M.moveToNullspace()

	// Now that mobs are stowed, delete the shuttle
	jumpToNullSpace()

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1, animate_time)
	var/list/turfs = ripple_area(S1)
	for(var/t in turfs)
		ripples += new /obj/effect/abstract/ripple(t, animate_time)

/obj/docking_port/mobile/proc/remove_ripples()
	QDEL_LIST(ripples)

/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/S1)
	var/list/L0 = return_ordered_turfs(x, y, z, dir)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/list/ripple_turfs = list()
	var/list/all_shuttle_areas = list()
	for(var/obj/docking_port/mobile/M in get_all_towed_shuttles())
		all_shuttle_areas |= M.shuttle_areas

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue  // out of bounds
		if(T0.type == T0.baseturfs)
			continue  // indestructible
		if(!all_shuttle_areas[T0.loc] || istype(T0.loc, /area/shuttle/transit))
			continue  // not part of the shuttle
		ripple_turfs += T1

	return ripple_turfs

/obj/docking_port/mobile/proc/check_poddoors()
	for(var/obj/machinery/door/poddoor/shuttledock/pod in GLOB.airlocks)
		pod.check()

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = initiate_docking(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

// Never move the shuttle import landmark, otherwise things get WEIRD
/obj/effect/landmark/shuttle_import/onShuttleMove()
	return FALSE

//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	check_effects()
	check_sound()

	if(mode == SHUTTLE_IGNITING)
		check_transit_zone()

	var/time_left = timeLeft(1)
	if(time_left > 0)
		return
	// If we can't dock or we don't have a transit slot, wait for 20 ds,
	// then try again
	switch(mode)
		if(SHUTTLE_CALL, SHUTTLE_PREARRIVAL)
			if(prearrivalTime && mode != SHUTTLE_PREARRIVAL)
				mode = SHUTTLE_PREARRIVAL
				setTimer(prearrivalTime)
				return
			var/error = initiate_docking(destination, preferred_direction)
			if(error && error & (DOCKING_NULL_DESTINATION | DOCKING_NULL_SOURCE))
				var/msg = "A mobile dock in transit exited initiate_docking() with an error. This is most likely a mapping problem: Error: [error],  ([src]) ([previous][ADMIN_JMP(previous)] -> [destination][ADMIN_JMP(destination)])"
				WARNING(msg)
				message_admins(msg)
				mode = SHUTTLE_IDLE
				return
			else if(error)
				setTimer(20)
				return
			if(rechargeTime)
				mode = SHUTTLE_RECHARGING
				setTimer(rechargeTime)
				return
		if(SHUTTLE_RECALL)
			if(initiate_docking(previous) != DOCKING_SUCCESS)
				setTimer(20)
				return
		if(SHUTTLE_IGNITING)
			if(check_transit_zone() != TRANSIT_READY)
				setTimer(20)
				return
			else
				mode = SHUTTLE_CALL
				setTimer(callTime * engine_coeff)
				enterTransit()
				return

	mode = SHUTTLE_IDLE
	timer = 0
	destination = null

/obj/docking_port/mobile/proc/check_sound()
	var/time_left = timeLeft(1)
	switch(mode)
		if(SHUTTLE_IGNITING)
			if(time_left <= 50 && sound_played != mode)
				hyperspace_sound(HYPERSPACE_WARMUP, shuttle_areas)
			if(time_left <= 0)
				hyperspace_sound(HYPERSPACE_LAUNCH, shuttle_areas)
		if(SHUTTLE_CALL)
			if(sound_played != mode && time_left <= HYPERSPACE_END_TIME)
				hyperspace_sound(HYPERSPACE_END, shuttle_areas)

/obj/docking_port/mobile/proc/check_effects()
	if(!ripples.len)
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination, tl)

	var/obj/docking_port/stationary/S0 = docked
	if(istype(S0, /obj/docking_port/stationary/transit) && timeLeft(1) <= PARALLAX_LOOP_TIME)
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			if(shuttle_area.parallax_movedir)
				parallax_slowdown()

/obj/docking_port/mobile/proc/parallax_slowdown()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		shuttle_area.parallax_movedir = FALSE
	if(assigned_transit && assigned_transit.assigned_area)
		assigned_transit.assigned_area.parallax_movedir = FALSE
	for (var/mob/M as() in SSmobs.clients_by_zlevel[z])
		var/area/A = get_area(M)
		if(!A)
			continue
		if(shuttle_areas[A])
			SSparallax.update_client_parallax(M.client, TRUE)

/obj/docking_port/mobile/proc/check_transit_zone()
	if(assigned_transit)
		return TRANSIT_READY
	else
		SSshuttle.request_transit_dock(src)

/obj/docking_port/mobile/proc/setTimer(wait)
	timer = world.time + wait
	last_timer_length = wait

/obj/docking_port/mobile/proc/modTimer(multiple)
	var/time_remaining = timer - world.time
	if(time_remaining < 0 || !last_timer_length)
		return
	time_remaining *= multiple
	last_timer_length *= multiple
	setTimer(time_remaining)

/obj/docking_port/mobile/proc/alert_coeff_change(new_coeff)
	if(isnull(new_coeff))
		return

	var/time_multiplier = new_coeff / alert_coeff
	var/time_remaining = timer - world.time
	if(time_remaining < 0 || !last_timer_length)
		return

	time_remaining *= time_multiplier
	last_timer_length *= time_multiplier
	alert_coeff = new_coeff
	setTimer(time_remaining)

/obj/docking_port/mobile/proc/invertTimer()
	if(!last_timer_length)
		return
	var/time_remaining = timer - world.time
	if(time_remaining > 0)
		var/time_passed = last_timer_length - time_remaining
		setTimer(time_passed)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10

	var/ds_remaining
	if(!timer)
		ds_remaining = callTime * engine_coeff
	else
		ds_remaining = max(0, timer - world.time)

	. = round(ds_remaining / divisor, 1)

// returns 3-letter mode string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_IGNITING)
			return "IGN"
		if(SHUTTLE_RECALL)
			return "RCL"
		if(SHUTTLE_CALL)
			return "ETA"
		if(SHUTTLE_DOCKED)
			return "ETD"
		if(SHUTTLE_ESCAPE)
			return "ESC"
		if(SHUTTLE_STRANDED)
			return "ERR"
		if(SHUTTLE_RECHARGING)
			return "RCH"
		if(SHUTTLE_PREARRIVAL)
			return "LDN"
	return ""

// returns 5-letter timer string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getTimerStr()
	if(mode == SHUTTLE_STRANDED)
		return "--:--"

	var/timeleft = timeLeft()
	if(timeleft > 1 HOURS)
		return "--:--"
	else if(timeleft > 0)
		return "[add_leading(num2text((timeleft / 60) % 60), 2, "0")]:[add_leading(num2text(timeleft % 60), 2, "0")]"
	else
		return "00:00"


/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = docked
	var/docked_at = dockedAt?.name || "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		if (timeLeft() > 1 HOURS)
			return "hyperspace"
		else
			var/obj/docking_port/stationary/dst
			if(mode == SHUTTLE_RECALL)
				dst = previous
			else
				dst = destination
			. = "transit towards [dst?.name || "unknown location"] ([getTimerStr()])"
	else if(mode == SHUTTLE_RECHARGING)
		return "[docked_at], recharging [getTimerStr()]"
	else
		return docked_at


/obj/docking_port/mobile/proc/getDbgStatusText()
	var/obj/docking_port/stationary/dockedAt = docked
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		if(dst)
			. = "(transit to) [dst.name || dst.id]"
		else
			. = "(transit to) nowhere"
	else if(dockedAt)
		. = dockedAt.name || dockedAt.id
	else
		. = "unknown"


// attempts to locate /obj/machinery/computer/shuttle with matching ID inside the shuttle
/obj/docking_port/mobile/proc/getControlConsole()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/obj/machinery/computer/shuttle_flight/S in shuttle_area)
			if(S.shuttleId == id)
				return S
	return null

/obj/docking_port/mobile/proc/hyperspace_sound(phase, list/areas)
	sound_played = mode
	var/selected_sound
	switch(phase)
		if(HYPERSPACE_WARMUP)
			selected_sound = "hyperspace_begin"
		if(HYPERSPACE_LAUNCH)
			selected_sound = "hyperspace_progress"
		if(HYPERSPACE_END)
			selected_sound = "hyperspace_end"
		else
			CRASH("Invalid hyperspace sound phase: [phase]")
	// This previously was played from each door at max volume, and was one of the worst things I had ever seen.
	// Now it's instead played from the nearest engine if close, or the first engine in the list if far since it doesn't really matter.
	// Or a door if for some reason the shuttle has no engine, fuck oh hi daniel fuck it
	var/range = (engine_coeff * max(width, height))
	var/long_range = range * 2.5
	var/atom/distant_source
	var/list/engines = list()
	for(var/datum/weakref/engine in engine_list)
		var/obj/structure/shuttle/engine/real_engine = engine.resolve()
		if(!real_engine)
			engine_list -= engine
			continue
		engines += real_engine

	if(LAZYLEN(engines))
		distant_source = engines[1]
	else
		for(var/A in areas)
			distant_source = locate(/obj/machinery/door) in A
			if(distant_source)
				break

	if(distant_source)
		for(var/mob/M as() in SSmobs.clients_by_zlevel[z])
			var/dist_far = get_dist(M, distant_source)
			//Cannot hear shuttles from other shuttles
			if(M.get_virtual_z_level() != get_virtual_z_level())
				continue
			if(dist_far <= long_range && dist_far > range)
				M.playsound_local(distant_source, "sound/effects/[selected_sound]_distance.ogg", 60, falloff_exponent = 20)
			else if(dist_far <= range)
				var/source
				if(engines.len == 0)
					source = distant_source
				else
					var/closest_dist = 10000
					for(var/obj/O in engines)
						var/dist_near = get_dist(M, O)
						if(dist_near < closest_dist)
							source = O
							closest_dist = dist_near
				M.playsound_local(source, "sound/effects/[selected_sound].ogg", 70, falloff_exponent = range / 2)

// Losing all initial engines should get you 2
// Adding another set of engines at 0.5 time
/obj/docking_port/mobile/proc/alter_engines(mod)
	if(mod == 0)
		return
	var/old_coeff = engine_coeff
	engine_coeff = get_engine_coeff(current_engines,mod)
	current_engines = max(0,current_engines + mod)
	if(in_flight())
		var/delta_coeff = engine_coeff / old_coeff
		modTimer(delta_coeff)

/obj/docking_port/mobile/proc/count_engines()
	. = 0
	engine_list.Cut()
	for(var/thing in shuttle_areas)
		var/area/shuttle/areaInstance = thing
		for(var/obj/structure/shuttle/engine/E in areaInstance.contents)
			if(!QDELETED(E))
				engine_list += WEAKREF(E)
				. += E.engine_power
		for(var/obj/machinery/shuttle/engine/E in areaInstance.contents)
			if(!QDELETED(E))
				engine_list += E
				. += E.thruster_active ? 1 : 0

// Double initial engines to get to 0.5 minimum
// Lose all initial engines to get to 2
//For 0 engine shuttles like BYOS 5 engines to get to doublespeed
/obj/docking_port/mobile/proc/get_engine_coeff(current,engine_mod)
	var/new_value = max(0,current + engine_mod)
	if(new_value == initial_engines)
		return 1
	if(new_value > initial_engines)
		var/delta = new_value - initial_engines
		var/change_per_engine = (1 - ENGINE_COEFF_MIN) / ENGINE_DEFAULT_MAXSPEED_ENGINES // 5 by default
		if(initial_engines > 0)
			change_per_engine = (1 - ENGINE_COEFF_MIN) / initial_engines // or however many it had
		return clamp(1 - delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)
	if(new_value < initial_engines)
		var/delta = initial_engines - new_value
		var/change_per_engine = 1 //doesn't really matter should not be happening for 0 engine shuttles
		if(initial_engines > 0)
			change_per_engine = (ENGINE_COEFF_MAX -  1) / initial_engines //just linear drop to max delay
		return clamp(1 + delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)


/obj/docking_port/mobile/proc/in_flight()
	switch(mode)
		if(SHUTTLE_CALL,SHUTTLE_RECALL,SHUTTLE_PREARRIVAL)
			return TRUE
		if(SHUTTLE_IDLE,SHUTTLE_IGNITING)
			return FALSE
		else
			return FALSE // hmm

/obj/docking_port/mobile/emergency/in_flight()
	switch(mode)
		if(SHUTTLE_ESCAPE)
			return TRUE
		if(SHUTTLE_STRANDED,SHUTTLE_ENDGAME)
			return FALSE
		else
			return ..()


//Called when emergency shuttle leaves the station
/obj/docking_port/mobile/proc/on_emergency_launch()
	if(launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
		launch_status = ENDGAME_LAUNCHED
		enterTransit()

/obj/docking_port/mobile/emergency/on_emergency_launch()
	return

//Called when emergency shuttle docks at centcom
/obj/docking_port/mobile/proc/on_emergency_dock()
	//Mapping a new docking point for each ship mappers could potentially want docking with centcom would take up lots of space, just let them keep flying off into the sunset for their greentext
	if(launch_status == ENDGAME_LAUNCHED)
		launch_status = ENDGAME_TRANSIT

/obj/docking_port/mobile/pod/on_emergency_dock()
	if(launch_status == ENDGAME_LAUNCHED)
		initiate_docking(SSshuttle.getDock("[id]_away")) //Escape pods dock at centcom
		mode = SHUTTLE_ENDGAME

/obj/docking_port/mobile/emergency/on_emergency_dock()
	return

#ifdef TESTING
#undef DOCKING_PORT_HIGHLIGHT
#endif
