/*
 *
 * RTX: ON Shadow calculator by PowerfulBacon.
 *
 * Calcuates sharp shadows on objects and makes shadow objects look sexy.
 * This took more than just hours to make, it was painful but a lot of fun.
 *
 * Credits:
 *  - PowerfulBacon
 *  - TiviPlus (Dud shadow holder object for faster render time)
 *
 */

//Lighting texture scales in world units (divide by 32)
//256 = 8,4,2
//1024 = 32,16,8
#define LIGHTING_SHADOW_TEX_SIZE 8

#define COORD_LIST_ADD(listtoadd, x, y) \
	if(islist(listtoadd["[x]"])) { \
		var/list/_L = listtoadd["[x]"]; \
		BINARY_INSERT_NUM(y, _L); \
	} else { \
		listtoadd["[x]"] = list(y);\
	}

#ifdef SHADOW_DEBUG
#define DEBUG_HIGHLIGHT(x, y, colour) \
	do { \
		var/turf/T = locate(x, y, 2); \
		if(T) { \
			T.color = colour; \
		}\
	} while (0)
//For debugging use when we want to know if a turf is being affected multiple
//#define DEBUG_HIGHLIGHT(x, y, colour) do{var/turf/T=locate(x,y,2);if(T){switch(T.color){if("#ff0000"){T.color = "#00ff00"}if("#00ff00"){T.color="#0000ff"}else{T.color="#ff0000"}}}}while(0)
#define DO_SOMETHING_IF_DEBUGGING_SHADOWS(something) something
#else
#define DEBUG_HIGHLIGHT(x, y, colour)
#define DO_SOMETHING_IF_DEBUGGING_SHADOWS(something)
#endif

/atom/movable/lighting_mask
	var/list/turf/affecting_turfs
	var/list/mutable_appearance/shadows
	//Amount of times lighting was calculated on this object
	var/times_calculated = 0

	//The last world time shadows were calculated on this object.
	//Prevents more than 1 shadow being made per 1/10s of a second which stops fast moving objects such as ghosts creating lag.
	var/last_calculation_time = 0

	//Please dont change these
	var/calculated_position_x
	var/calculated_position_y

/atom/movable/lighting_mask/Destroy()
	//Make sure we werent destroyed in init
	if(!SSlighting.started)
		SSlighting.sources_that_need_updating -= src
	//Remove from affecting turfs
	if(affecting_turfs)
		for(var/turf/thing as() in affecting_turfs)
			var/area/A = thing.loc
			LAZYREMOVE(thing.lights_affecting, src)
			if(!LAZYLEN(thing.lights_affecting) && !LAZYLEN(thing.legacy_affecting_lights) && !A.base_lighting_alpha)
				thing.luminosity = FALSE
		affecting_turfs = null
	//Cut the shadows. Since they are overlays they will be deleted when cut from overlays probably.
	LAZYCLEARLIST(shadows)
	. = ..()

/atom/movable/lighting_mask/proc/link_turf_to_light(turf/T)
	LAZYOR(affecting_turfs, T)
	LAZYOR(T.lights_affecting, src)

/atom/movable/lighting_mask/proc/unlink_turf_from_light(turf/T)
	LAZYREMOVE(affecting_turfs, T)
	LAZYREMOVE(T.lights_affecting, src)

//Returns a list of matrices corresponding to the matrices that should be applied to triangles of
//coordinates (0,0),(1,0),(0,1) to create a triangcalculate_shadows_matricesle that respresents the shadows
//takes in the old turf to smoothly animate shadow movement
/atom/movable/lighting_mask/proc/calculate_lighting_shadows(force = FALSE)

	//Check to make sure lighting is actually started
	//If not count the amount of duplicate requests created.
	if(!SSlighting.started)
		if(awaiting_update)
			SSlighting.duplicate_shadow_updates_in_init ++
			return
		SSlighting.sources_that_need_updating += src
		awaiting_update = TRUE
		return

	//BIIIIG lag stopper.
	if(!force)
		if(world.time <= last_calculation_time)
			SSlighting.queue_shadow_render(src)
			return

	last_calculation_time = world.time

	//Dont bother calculating at all for small shadows
	var/range = radius

	//Dont calculate when the source atom is in nullspace
	if(!attached_atom.loc)
		return

	//Incremement the global counter for shadow calculations
	SSlighting.total_shadow_calculations ++

	//Ceiling the range since we need it in integer form
	var/unrounded_range = range
	range = CEILING(unrounded_range, 1)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/timer = TICK_USAGE)

	//Work out our position
	//Calculate shadow origin offset
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)

	//Get the origin poin's
	var/turf/our_turf = get_turf(attached_atom)	//The mask is in nullspace, so we need the source turf of the container
	var/ourx = our_turf.x
	var/oury = our_turf.y

	//Account for pixel shifting and light offset
	calculated_position_x = ourx + ((offset_x) / world.icon_size)
	calculated_position_y = oury + ((offset_y) / world.icon_size)

	//Remove the old shadows
	overlays.Cut()

	//Optimise grouping by storing as
	// Key : x (AS A STRING BECAUSE BYOND DOESNT ALLOW FOR INT KEY DICTIONARIES)
	// Value: List(y values)
	var/list/opaque_atoms_in_view = list()

	//Reset the list
	if(islist(affecting_turfs))
		for(var/turf/T as() in affecting_turfs)
			LAZYREMOVE(T?.lights_affecting, src)
			//The turf is no longer affected by any lights, make it non-luminous.
			var/area/A = T.loc
			if(T?.luminosity && !LAZYLEN(T.lights_affecting) && !LAZYLEN(T.legacy_affecting_lights) && !A.base_lighting_alpha)
				T.luminosity = FALSE

	//Clear the list
	LAZYCLEARLIST(affecting_turfs)
	LAZYCLEARLIST(shadows)

	//Rebuild the list
	var/isClosedTurf = istype(our_turf, /turf/closed)
	for(var/turf/thing in dview(range, get_turf(attached_atom)))
		link_turf_to_light(thing)
		//The turf is now affected by our light, make it luminous
		if(!thing.luminosity)
			thing.luminosity = TRUE
		//Dont consider shadows about our turf.
		if(!isClosedTurf)
			if(thing == our_turf)
				continue
		if(thing.has_opaque_atom || thing.opacity)
			//At this point we no longer care about
			//the atom itself, only the position values
			COORD_LIST_ADD(opaque_atoms_in_view, thing.x, thing.y)
			DEBUG_HIGHLIGHT(thing.x, thing.y, "#0000FF")

	//We are too small to consider shadows on, luminsoty has been considered at least.
	if(radius <= MINIMUM_LIGHT_SHADOW_RADIUS)
		return

	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("[TICK_USAGE_TO_MS(timer)]ms to process view([range], src)."))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/temp_timer = TICK_USAGE)

	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("[TICK_USAGE_TO_MS(timer)]ms to remove ourselves from invalid turfs."))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

	//Group atoms together for optimisation
	var/list/grouped_atoms = group_atoms(opaque_atoms_in_view)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("[TICK_USAGE_TO_MS(temp_timer)]ms to process group_atoms"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/total_coordgroup_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/total_cornergroup_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/triangle_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/culling_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/triangle_to_matrix_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/matrix_division_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/MA_new_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/MA_vars_time = 0)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/overlays_add_time = 0)

	var/list/overlays_to_add = list()
	for(var/group in grouped_atoms)
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

		var/list/coordgroup = calculate_corners_in_group(group)
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(total_coordgroup_time += TICK_USAGE_TO_MS(temp_timer))
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

		//This is where the lines are made
		var/list/cornergroup = get_corners_from_coords(coordgroup)
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(total_cornergroup_time += TICK_USAGE_TO_MS(temp_timer))
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

		var/list/culledlinegroup = cull_blocked_in_group(cornergroup, opaque_atoms_in_view)
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(culling_time += TICK_USAGE_TO_MS(temp_timer))
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

		if(!LAZYLEN(culledlinegroup))
			continue

		var/list/triangles = calculate_triangle_vertices(culledlinegroup)
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(triangle_time += TICK_USAGE_TO_MS(temp_timer))
		DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

		for(var/triangle in triangles)
			var/matrix/M = triangle_to_matrix(triangle)

			DO_SOMETHING_IF_DEBUGGING_SHADOWS(triangle_to_matrix_time += TICK_USAGE_TO_MS(temp_timer))
			DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

			M /= transform

			DO_SOMETHING_IF_DEBUGGING_SHADOWS(matrix_division_time += TICK_USAGE_TO_MS(temp_timer))
			DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

			var/mutable_appearance/shadow = new()

			DO_SOMETHING_IF_DEBUGGING_SHADOWS(MA_new_time += TICK_USAGE_TO_MS(temp_timer))
			DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

			shadow.icon = LIGHTING_ICON_BIG
			shadow.icon_state = "triangle"
			shadow.layer = layer + 1
			shadow.color = "#000"
			shadow.alpha = 255
			shadow.transform = M

			DO_SOMETHING_IF_DEBUGGING_SHADOWS(MA_vars_time += TICK_USAGE_TO_MS(temp_timer))
			DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

			LAZYADD(shadows, shadow)
			overlays_to_add += shadow

			DO_SOMETHING_IF_DEBUGGING_SHADOWS(overlays_add_time += TICK_USAGE_TO_MS(temp_timer))
			DO_SOMETHING_IF_DEBUGGING_SHADOWS(temp_timer = TICK_USAGE)

	//TGMC Backport
	//Put the overlays onto a dud object and copy the appearance to merge them
	//Doesnt impact maptick, AND means much faster render times
	var/static/atom/movable/lighting_mask/template/dud = new
	dud.overlays += overlays_to_add
	var/static/mutable_appearance/overlay_merger = new()
	overlay_merger.appearance = dud.appearance
	overlays += overlay_merger
	dud.overlays.Cut()

	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("total_coordgroup_time: [total_coordgroup_time]ms"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("total_cornergroup_time: [total_cornergroup_time]ms"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("triangle_time calculation: [triangle_time]ms"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("triangle_to_matrix_time: [triangle_to_matrix_time]"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("Culling Time: [culling_time]ms"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("matrix_division_time: [matrix_division_time]"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("MA_new_time: [MA_new_time]"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("MA_vars_time: [MA_vars_time]"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("overlays_add_time: [overlays_add_time]"))
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(log_game("[TICK_USAGE_TO_MS(timer)]ms to process total."))

//Converts a triangle into a matrix that can be applied to a standardized triangle
//to make it represent the points.
//Note: Ignores translation because
/atom/movable/lighting_mask/proc/triangle_to_matrix(list/triangle)
	//We need the world position raw, if we use the calculated position then the pixel values will cancel.
	var/turf/our_turf = get_turf(attached_atom)
	var/ourx = our_turf.x
	var/oury = our_turf.y

	var/originx = triangle[1][1] - ourx						//~Simultaneous Variable: U
	var/originy = triangle[1][2] - oury						//~Simultaneous Variable: V
	//Get points translating the first point to (0, 0)
	var/translatedPoint2x = triangle[2][1] - ourx	//Simultaneous Variable: W
	var/translatedPoint2y = triangle[2][2] - oury	//Simultaneous Variable: X
	var/translatedPoint3x = triangle[3][1] - ourx	//Simultaneous Variable: Y
	var/translatedPoint3y = triangle[3][2] - oury	//Simultaneous Variable: Z
	//message_admins("Point 1: ([originx], [originy])")
	//message_admins("Point 2: ([translatedPoint2x], [translatedPoint2y])")
	//message_admins("Point 3: ([translatedPoint3x], [translatedPoint3y])")
	//Assumption that is incorrect
	//Triangle points are
	// (-4, -4)
	// (-4,  4)
	// ( 4, -4)
	//Would be much easier if it was (0, 0) instead of (-4, -4) but since we have 6 inputs and 6 unknowns
	//we can solve the values of the matrix pretty easilly simultaneously.
	//In fact since variables U,W,Y,A,B,C are separate to V,X,Z,D,E,F its easy since its 2 identical tri-variable simultaneous equations.
	//By solving the equations simultaneously we get these results:
	//a = (y-u)/8
	var/a = (translatedPoint3x - originx) / LIGHTING_SHADOW_TEX_SIZE
	//b = (w-u)/ 8
	var/b = (translatedPoint2x - originx) / LIGHTING_SHADOW_TEX_SIZE
	//c = (y+w)/2
	var/c = (translatedPoint3x + translatedPoint2x) / 2
	//d = (z-v)/8
	var/d = (translatedPoint3y - originy) / LIGHTING_SHADOW_TEX_SIZE
	//e = (x-v)/8
	var/e = (translatedPoint2y - originy) / LIGHTING_SHADOW_TEX_SIZE
	//f = (z+x)/2
	var/f = (translatedPoint3y + translatedPoint2y) / 2
	//Matrix time g
	//a,b,d and e can be used to define the shape, C and F can be used for translation god matrices are so beautiful
	//Completely random offset that I didnt derive, I just trialled and errored for about 4 hours until it randomly worked
	//var/radius_based_offset = radius * 3 + 3.5 <-- for 1024x1024 lights DO NOT USE 1024x1024 SHADOWS UNLESS YOU ARE PLAYING WITH RTX200000 OR SOMETHING
	var/radius_based_offset = (radius * 0) + 3.5
	var/matrix/M = matrix(a, b, (c * 32) - ((radius_based_offset) * 32), d, e, (f * 32) - ((radius_based_offset) * 32))
	//log_game("[M.a], [M.d], 0")
	//log_game("[M.b], [M.e], 0")
	//log_game("[M.c], [M.f], 1")
	return M

//Basically takes the 2-4 corners, extends them and then generates triangle coordinates representing shadows
//Input: list(list(list(x, y), list(x, y)))
// Layer 1: Lines
// Layer 2: Vertex
// Layer 3: X/Y value
//OUTPUT: The same thing but with 3 lists embedded rather than 2 because they are triangles not lines now.
/atom/movable/lighting_mask/proc/calculate_triangle_vertices(list/cornergroup)
	var/shadow_radius = max(radius + 1, 3)
	//Get the origin poin's
	var/ourx = calculated_position_x
	var/oury = calculated_position_y
	//The output
	. = list()
	//Every line has 2 triangles innit
	for(var/list/line in cornergroup)
		//Get the corner vertices
		var/vertex1 = line[1]
		var/vertex2 = line[2]
		//Extend them and get end vertices
		//Calculate vertex 3 position
		var/delta_x = vertex1[1] - ourx
		var/delta_y = vertex1[2] - oury
		var/vertex3 = extend_line_to_radius(delta_x, delta_y, shadow_radius, ourx, oury)
		var/vertex3side = (vertex3[1] - ourx) == -shadow_radius ? WEST : (vertex3[1] - ourx) == shadow_radius ? EAST : (vertex3[2] - oury) == shadow_radius ? NORTH : SOUTH

		//For vertex 4
		delta_x = vertex2[1] - ourx
		delta_y = vertex2[2] - oury
		var/vertex4 = extend_line_to_radius(delta_x, delta_y, shadow_radius, ourx, oury)
		var/vertex4side = (vertex4[1] - ourx) == -shadow_radius ? WEST : (vertex4[1] - ourx) == shadow_radius ? EAST : (vertex4[2] - oury) == shadow_radius ? NORTH : SOUTH

		//If vertex3 is not on the same border as vertex 4 then we need more triangles to fill in the space.
		if(vertex3side != vertex4side)
			var/eitherNorth = (vertex3side == NORTH || vertex4side == NORTH)
			var/eitherEast = (vertex3side == EAST || vertex4side == EAST)
			var/eitherSouth = (vertex3side == SOUTH || vertex4side == SOUTH)
			var/eitherWest = (vertex3side == WEST || vertex4side == WEST)
			if(eitherNorth && eitherEast)
				//Add a vertex top right
				var/vertex5 = list(shadow_radius + ourx, shadow_radius + oury)
				var/triangle3 = list(vertex3, vertex4, vertex5)
				. += list(triangle3)
			else if(eitherNorth && eitherWest)
				//Add a vertex top left
				var/vertex5 = list(-shadow_radius + ourx, shadow_radius + oury)
				var/triangle3 = list(vertex3, vertex4, vertex5)
				. += list(triangle3)
			else if(eitherNorth && eitherSouth) //BLOCKER IS A | SHAPE
				//If vertex3 is to the right of the center, both vertices are to the right.
				if(vertex3[1] > ourx)
					//New vertexes are on the right
					var/vertex5 = list(ourx + shadow_radius, oury + shadow_radius)
					var/vertex6 = list(ourx + shadow_radius, oury - shadow_radius)
					//If vertex 4 is greater than 3 then triangles link as 4,5,6 and 3,4,6
					if(vertex4[2] > vertex3[2])
						var/triangle3 = list(vertex3, vertex5, vertex6)
						. += list(triangle3)
						var/triangle4 = list(vertex3, vertex4, vertex5)
						. += list(triangle4)
					else
						//Vertex 3 is greater than 4, so triangles link as 3,5,6 and 3,4,6
						var/triangle3 = list(vertex3, vertex4, vertex5)
						. += list(triangle3)
						var/triangle4 = list(vertex4, vertex5, vertex6)
						. += list(triangle4)
				else
					//New vertexes are on the left
					var/vertex5 = list(ourx - shadow_radius, oury + shadow_radius)
					var/vertex6 = list(ourx - shadow_radius, oury - shadow_radius)
					//If vertex 4 is higher than 3 then triangles link as 4,5,6 and 3,4,6
					if(vertex4[2] > vertex3[2])
						var/triangle3 = list(vertex3, vertex5, vertex6)
						. += list(triangle3)
						var/triangle4 = list(vertex3, vertex4, vertex5)
						. += list(triangle4)
					else
						//Vertex 3 is greater than 4, so triangles link as 3,5,6 and 3,4,6
						var/triangle3 = list(vertex3, vertex4, vertex5)
						. += list(triangle3)
						var/triangle4 = list(vertex4, vertex5, vertex6)
						. += list(triangle4)
			else if(eitherEast && eitherSouth)
				//Add a vertex bottom right
				var/vertex5 = list(shadow_radius + ourx, -shadow_radius + oury)
				var/triangle3 = list(vertex3, vertex4, vertex5)
				. += list(triangle3)
			else if(eitherEast && eitherWest)	//BLOCKER IS A --- SHAPE
				//If vertex3 is above the center, then pointers are along the top
				if(vertex3[2] > oury)
					//New vertexes are on the right
					var/vertex5 = list(ourx + shadow_radius, oury + shadow_radius)
					var/vertex6 = list(ourx - shadow_radius, oury + shadow_radius)
					//If vertex 4 is greater than 3 then triangles link as 4,5,6 and 3,4,6
					if(vertex4[1] > vertex3[1])
						var/triangle3 = list(vertex3, vertex5, vertex6)
						. += list(triangle3)
						var/triangle4 = list(vertex3, vertex4, vertex5)
						. += list(triangle4)
					else
						//Vertex 3 is greater than 4, so triangles link as 3,5,6 and 3,4,6
						var/triangle3 = list(vertex3, vertex4, vertex5)
						. += list(triangle3)
						var/triangle4 = list(vertex4, vertex5, vertex6)
						. += list(triangle4)
				else
					//New vertexes are on the bottom
					var/vertex5 = list(ourx + shadow_radius, oury - shadow_radius)
					var/vertex6 = list(ourx - shadow_radius, oury - shadow_radius)
					//If vertex 4 is higher than 3 then triangles link as 4,5,6 and 3,4,6
					if(vertex4[1] > vertex3[1])
						var/triangle3 = list(vertex3, vertex4, vertex5)
						. += list(triangle3)
						var/triangle4 = list(vertex3, vertex5, vertex6)
						. += list(triangle4)
					else
						//Vertex 3 is greater than 4, so triangles link as 3,5,6 and 3,4,6
						var/triangle3 = list(vertex3, vertex4, vertex5)
						. += list(triangle3)
						var/triangle4 = list(vertex4, vertex5, vertex6)
						. += list(triangle4)
			else if(eitherSouth && eitherWest)
				//Bottom left
				var/vertex5 = list(-shadow_radius + ourx, -shadow_radius + oury)
				var/triangle3 = list(vertex3, vertex4, vertex5)
				. += list(triangle3)
			else
				//bug
				stack_trace("Major error: vertex in a bad position (North: [eitherNorth], East: [eitherEast], South: [eitherSouth], West: [eitherWest])")

		//Generate triangles
		var/triangle1 = list(vertex1, vertex2, vertex3)
		var/triangle2 = list(vertex2, vertex3, vertex4)
		. += list(triangle1)
		. += list(triangle2)

//Takes in the list of lines and sight blockers and returns only the lines that are not blocked
/atom/movable/lighting_mask/proc/cull_blocked_in_group(list/lines, list/sight_blockers)
	. = list()
	for(var/list/line in lines)
		var/vertex1 = line[1]
		var/vertex2 = line[2]
		var/list/lines_to_add = list()
		if(vertex1[1] == vertex2[1])
			//Vertical line.
			//Requires a block to the left and right all the way from the bottom to the top
			var/left = vertex1[1] - 0.5
			var/right = vertex1[1] + 0.5
			var/bottom = min(vertex1[2], vertex2[2]) + 0.5
			var/top = max(vertex1[2], vertex2[2]) - 0.5
			var/list/current_bottom_vertex = list(vertex1[1], bottom - 0.5)
			var/list/current_top_vertex = list(vertex1[1], bottom - 0.5)
			for(var/i in bottom to top)
				var/list/left_list = sight_blockers["[left]"]
				var/isLeftBlocked = left_list?.Find(i) ? TRUE : FALSE
				var/list/right_list = sight_blockers["[right]"]
				var/isRightBlocked = right_list?.Find(i) ? TRUE : FALSE
				if(isLeftBlocked == isRightBlocked)
					if(current_bottom_vertex[2] != current_top_vertex[2])
						lines_to_add += list(list(current_bottom_vertex, current_top_vertex))
					current_bottom_vertex = list(vertex1[1], i + 0.5)
				current_top_vertex = list(vertex1[1], i + 0.5)
			if(current_bottom_vertex[2] != current_top_vertex[2])
				lines_to_add += list(list(current_bottom_vertex, current_top_vertex))
		else
			//Horizontal line
			//Requires a block above and below for every position from left to right
			var/left = min(vertex1[1], vertex2[1]) + 0.5
			var/right = max(vertex1[1], vertex2[1]) - 0.5
			var/top = vertex1[2] + 0.5
			var/bottom = vertex1[2] - 0.5
			var/list/current_left_vertex = list(left - 0.5, vertex1[2])
			var/list/current_right_vertex = list(left - 0.5, vertex1[2])
			for(var/i in left to right)
				var/list/check_list = sight_blockers["[i]"]
				var/isAboveBlocked = check_list?.Find(top) ? TRUE : FALSE
				var/isBelowBlocked = check_list?.Find(bottom) ? TRUE : FALSE
				if(isAboveBlocked == isBelowBlocked)
					if(current_left_vertex[1] != current_right_vertex[1])
						lines_to_add += list(list(current_left_vertex, current_right_vertex))
					current_left_vertex = list(i + 0.5, vertex1[2])
				current_right_vertex = list(i + 0.5, vertex1[2])
			if(current_left_vertex[1] != current_right_vertex[1])
				lines_to_add += list(list(current_left_vertex, current_right_vertex))
		. += lines_to_add

//Converts the corners into the 3 (or 2) valid points
//For example if a wall is top right of the source, the bottom left wall corner
//can be removed otherwise the wall itself will be in the shadow.
//Input: list(list(x1, y1), list(x2, y2))
//Output: list(list(list(x, y), list(x, y))) <-- 2 coordinates that form a line
/atom/movable/lighting_mask/proc/get_corners_from_coords(list/coordgroup)
	//Get the raw numbers
	var/xlow = coordgroup[1][1]
	var/ylow = coordgroup[1][2]
	var/xhigh = coordgroup[2][1]
	var/yhigh = coordgroup[2][2]

	var/ourx = calculated_position_x
	var/oury = calculated_position_y

	//The source is above the point (Bottom Quad)
	if(oury > yhigh)
		//Bottom Right
		if(ourx < xlow)
			return list(
				list(list(xlow, ylow), list(xhigh, ylow)),
				list(list(xhigh, ylow), list(xhigh, yhigh)),
			)
		//Bottom Left
		else if(ourx > xhigh)
			return list(
				list(list(xlow, yhigh), list(xlow, ylow)),
				list(list(xlow, ylow), list(xhigh, ylow)),
			)
		//Bottom Middle
		else
			return list(
				list(list(xlow, yhigh), list(xlow, ylow)),
				list(list(xlow, ylow), list(xhigh, ylow)),
				list(list(xhigh, ylow), list(xhigh, yhigh))
			)
	//The source is below the point (Top quad)
	else if(oury < ylow)
		//Top Right
		if(ourx < xlow)
			return list(
				list(list(xlow, yhigh), list(xhigh, yhigh)),
				list(list(xhigh, yhigh), list(xhigh, ylow)),
			)
		//Top Left
		else if(ourx > xhigh)
			return list(
				list(list(xlow, ylow), list(xlow, yhigh)),
				list(list(xlow, yhigh), list(xhigh, yhigh)),
			)
		//Top Middle
		else
			return list(
				list(list(xlow, ylow), list(xlow, yhigh)),
				list(list(xlow, yhigh), list(xhigh, yhigh)),
				list(list(xhigh, yhigh), list(xhigh, ylow))
			)
	//the source is between the group Middle something
	else
		//Middle Right
		if(ourx < xlow)
			return list(
				list(list(xlow, yhigh), list(xhigh, yhigh)),
				list(list(xhigh, yhigh), list(xhigh, ylow)),
				list(list(xhigh, ylow), list(xlow, ylow))
			)
		//Middle Left
		else if(ourx > xhigh)
			return list(
				list(list(xhigh, ylow), list(xlow, ylow)),
				list(list(xlow, ylow), list(xlow, yhigh)),
				list(list(xlow, yhigh), list(xhigh, yhigh))
			)
		//Middle Middle (Why?????????)
		else
			return list(
				list(list(xhigh, ylow), list(xlow, ylow)),
				list(list(xlow, ylow), list(xlow, yhigh)),
				list(list(xlow, yhigh), list(xhigh, yhigh)),
				list(list(xlow, yhigh), list(xhigh, ylow))
			)

//Calculates the coordinates of the corner
//Takes a list of blocks and calculates the bottom left corner and the top right corner.
//Input: Group list(list(list(x,y), list(x,y)), list(list(x, y)))
//Output: Coordinates list(list(left, bottom), list(right, top))
/atom/movable/lighting_mask/proc/calculate_corners_in_group(list/group)
	if(length(group) == 0)
		CRASH("Calculate_corners_in_group called on a group of length 0. Critical error.")
	if(length(group) == 1)
		var/x = group[1][1]
		var/y = group[1][2]
		return list(
			list(x - 0.5, y - 0.5),
			list(x + 0.5, y + 0.5)
		)
	//Group is multiple length, find top left and bottom right
	var/first = group[1]
	var/second = group[2]
	var/group_direction = NORTH
	if(first[1] != second[1])
		group_direction = EAST
#ifdef SHADOW_DEBUG6
	else if(first[2] != second[2])
		message_admins("Major error, group is not 1xN or Nx1")
#endif
	var/lowest = INFINITY
	var/highest = 0
	for(var/vector in group)
		var/value_to_comp = vector[1]
		if(group_direction == NORTH)
			value_to_comp = vector[2]
		lowest = min(lowest, value_to_comp)
		highest = max(highest, value_to_comp)
	//done ez
	if(group_direction == NORTH)
		return list(
			list(first[1] - 0.5, lowest - 0.5),
			list(first[1] + 0.5, highest + 0.5)
		)
	else
		return list(
			list(lowest - 0.5, first[2] - 0.5),
			list(highest + 0.5, first[2] + 0.5)
		)

//Groups things into vertical and horizontal lines.
//Input: All atoms ungrouped list(atom1, atom2, atom3)
//Output: List(List(Group), list(group2), ... , list(groupN))
//Output: List(List(atom1, atom2), list(atom3, atom4...), ... , list(atomN))
/atom/movable/lighting_mask/proc/group_atoms(list/ungrouped_things)
	. = list()
	//Ungrouped things comes in as
	// Key: X
	// Value = list(y values)
	//This makes sorting vertically easy, however sorting horizontally is harder
	//While grouping elements vertically, we can put them into a new list with
	// Key: Y
	// Value = list(x values)
	//to make it much easier.
	var/list/horizontal_atoms = list()
	//=================================================
	//Vertical sorting (X locked)
	for(var/x_key in ungrouped_things)
		var/list/y_components = ungrouped_things[x_key]
		var/pointer = y_components[1]
		var/list/group = list(list(text2num(x_key), y_components[1]))
		for(var/i in 2 to length(y_components))
			var/next = y_components[i]
			if(next != pointer + 1)
				if(length(group) == 1)
					//Add the element in group to horizontal
					COORD_LIST_ADD(horizontal_atoms, pointer, text2num(x_key))
					DEBUG_HIGHLIGHT(text2num(x_key), pointer, "#FFFF00")
				else
					//Add the group to the output
					. += list(group)
				group = list()
			group += list(list(text2num(x_key), next))
			DEBUG_HIGHLIGHT(text2num(x_key), next, "#FF0000")
			pointer = next
		if(length(group) == 1)
			//Add the element in group to horizontal
			COORD_LIST_ADD(horizontal_atoms, pointer, text2num(x_key))
			DEBUG_HIGHLIGHT(text2num(x_key), pointer, "#FFFF00")
		else
			//Add the group to the output
			. += list(group)
	//=================================================
	//Horizontal sorting (Y locked)
	for(var/y_key in horizontal_atoms)
		var/list/x_components = horizontal_atoms[y_key]
		var/pointer = x_components[1]
		var/list/group = list(list(x_components[1], text2num(y_key)))
		for(var/i in 2 to length(x_components))
			var/next = x_components[i]
			if(next != pointer + 1)
				. += list(group)
				group = list()
			group += list(list(next, text2num(y_key)))
			DEBUG_HIGHLIGHT(next, text2num(y_key), "#00FF00")
			pointer = next
		. += list(group)

/proc/extend_line_to_radius(delta_x, delta_y, radius, offset_x, offset_y)
	if(abs(delta_x) < abs(delta_y))
		//top or bottom
		var/proportion = radius / abs(delta_y)
		return list(delta_x * proportion + offset_x, delta_y * proportion + offset_y)
	else
		var/proportion = radius / abs(delta_x)
		return list(delta_x * proportion + offset_x, delta_y * proportion + offset_y)

#undef LIGHTING_SHADOW_TEX_SIZE
#undef COORD_LIST_ADD
#undef DEBUG_HIGHLIGHT
#undef DO_SOMETHING_IF_DEBUGGING_SHADOWS
