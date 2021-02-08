#define SHADOW_DEBUG

#ifdef SHADOW_DEBUG
#define COORD_LIST_ADD(listtoadd, x, y) \
	if(islist(listtoadd["[x]"])) { \
		BINARY_INSERT_NUM(y, listtoadd["[x]"]); \
	} else { \
		listtoadd["[x]"] = list(y);\
	}
#else
#define COORD_LIST_ADD(listtoadd, x, y)
#endif

#define DEBUG_HIGHLIGHT(x, y, colour) \
	do { \
		var/turf/T = locate(x, y, 2); \
		if(T) { \
			T.color = colour; \
		}\
	} while (0)

/atom/movable/lighting_mask
	var/list/list_output

//Returns a list of matrices corresponding to the matrices that should be applied to triangles of
//coordinates (0,0),(1,0),(0,1) to create a triangcalculate_shadows_matricesle that respresents the shadows
/atom/movable/lighting_mask/proc/calculate_lighting_shadows(range)
	//Optimise grouping by storing as
	// Key : x (AS A STRING BECAUSE BYOND DOESNT ALLOW FOR INT KEY DICTIONARIES)
	// Value: List(y values)
	var/list/opaque_atoms_in_view = list()
	//Find atoms that are opaque
	for(var/atom/thing as() in view(range, get_turf(src)))
		if(thing.opacity)
			//At this point we no longer care about
			//the atom itself, only the position values
			COORD_LIST_ADD(opaque_atoms_in_view, thing.x, thing.y)
			DEBUG_HIGHLIGHT(thing.x, thing.y, "#0000FF")
	//Group atoms together for optimisation
	for(var/group in group_atoms(opaque_atoms_in_view))
		message_admins("===group===")
		message_admins(json_encode(group))
		message_admins(json_encode(calculate_corners_in_group(group)))

//Calculates the coordinates of the corner
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
	if(first[1] == second[1])
		group_direction = EAST
#ifdef SHADOW_DEBUG
	else if(first[2] != second[2])
		message_admins("Major error, group is not 1xN or Nx1")
#endif
	var/lowest = 0
	var/highest = INFINITY
	for(var/vector in group)
		var/value_to_comp = vector[1]
		if(group_direction == NORTH)
			value_to_comp = vector[2]
		lowest = max(lowest, value_to_comp)
		highest = min(highest, value_to_comp)
	//done ez
	if(group_direction == NORTH)
		return list(
			list(first[1] - 0.5, lowest - 0.5),
			list(first[1] + 0.5, highest + 0.5)
		)
	else
		return list(
			list(lowest - 0.5, first[1] - 0.5),
			list(highest + 0.5, first[1] + 0.5)
		)

//Calculates the matrices needed to apply to triangles in order to
//properly generate the shadows
//Input: Group
//list(list(list(x, y), list(x,y)), list(list(x, y))) etc.
//output: list(matrix(), matrix(), matrix(), ...)
/atom/movable/lighting_mask/proc/calculate_group_matrix(list/group)


//Groups things into vertical and horizontal lines.
//Input: All atoms ungrouped list(atom1, atom2, atom3)
//Output: List(List(Group), list(group2), ... , list(groupN))
//Output: List(List(atom1, atom2), list(atom3, atom4...), ... , list(atomN))
/atom/movable/lighting_mask/proc/group_atoms(list/ungrouped_things)
	var/list/grouped_atoms = list()
	//Ungrouped things comes in as
	// Key: X
	// Value = list(y values)
	//This makes sorting vertically easy, however sorting horizontally is harder
	//While grouping elements vertically, we can put them into a new list with
	// Key: Y
	// Value = list(x values)
	//to make it much easier.
	//=================================================
	var/list/horizontal_atoms = list()
	//Group vertically first because its quick and easy
	for(var/x_key in ungrouped_things)
		//Collect all y elements on that x plane
		var/list/y_elements = ungrouped_things[x_key]
		//Too few elements to group
		if(y_elements.len <= 1)
			if(y_elements.len == 1)
				DEBUG_HIGHLIGHT(text2num(x_key), y_elements[1], "#FFFF00")
				COORD_LIST_ADD(horizontal_atoms, y_elements[1], text2num(x_key))
			continue
		//Loop through elements and check if they are new to each other
		var/previous_y_element = y_elements[1]
		//Grouping check
		var/list/group = list()
		for(var/i in 2 to length(y_elements))
			var/actual_y_value = y_elements[i]
			if(actual_y_value == previous_y_element + 1)
				//Start creating a group, remove grouped elements
				if(group.len)
					group += list(list(text2num(x_key), actual_y_value))
					DEBUG_HIGHLIGHT(text2num(x_key), actual_y_value, "#FF0000")
				else
					group += list(list(text2num(x_key), actual_y_value))
					DEBUG_HIGHLIGHT(text2num(x_key), actual_y_value, "#FF0000")
					group += list(list(text2num(x_key), previous_y_element))
					DEBUG_HIGHLIGHT(text2num(x_key), previous_y_element, "#FF0000")
			else
				if(group.len)
					//Add the group to the output groups
					grouped_atoms += list(group)
					group = list()
				if(i == 2)
					DEBUG_HIGHLIGHT(text2num(x_key), previous_y_element, "#FF00FF")
					COORD_LIST_ADD(horizontal_atoms, previous_y_element, text2num(x_key))
				DEBUG_HIGHLIGHT(text2num(x_key), actual_y_value, "#FF00FF")
				COORD_LIST_ADD(horizontal_atoms, actual_y_value, text2num(x_key))
			previous_y_element = actual_y_value
		if(group.len)
			grouped_atoms += list(group)
	//=================================================
	for(var/y_key in horizontal_atoms)
		//Collect all y elements on that x plane
		var/list/x_elements = horizontal_atoms[y_key]
		//Too few elements to group
		if(x_elements.len <= 1)
			if(x_elements.len == 1)
				DEBUG_HIGHLIGHT(x_elements[1], text2num(y_key), "#00FFFF")
				grouped_atoms += list(list(list(x_elements[1], text2num(y_key))))
			continue
		//Loop through elements and check if they are new to each other
		var/previous_x_element = x_elements[1]
		//Grouping check
		var/list/group = list()
		for(var/i in 2 to length(x_elements))
			var/actual_x_value = x_elements[i]
			if(actual_x_value == previous_x_element + 1)
				//Start creating a group, remove grouped elements
				if(group.len)
					group += list(list(actual_x_value, text2num(y_key)))
					DEBUG_HIGHLIGHT(actual_x_value, text2num(y_key), "#00FF00")
				else
					group += list(list(actual_x_value, text2num(y_key)))
					DEBUG_HIGHLIGHT(actual_x_value, text2num(y_key), "#00FF00")
					group += list(list(previous_x_element, text2num(y_key)))
					DEBUG_HIGHLIGHT(previous_x_element, text2num(y_key), "#00FF00")
			else
				if(group.len)
					//Add the group to the output groups
					grouped_atoms += list(group)
					group = list()
				if(i == 2)
					DEBUG_HIGHLIGHT(previous_x_element, text2num(y_key), "#00FFFF")
					grouped_atoms += list(list(list(previous_x_element, text2num(y_key))))
				DEBUG_HIGHLIGHT(actual_x_value, text2num(y_key), "#00FFFF")
				grouped_atoms += list(list(list(actual_x_value, text2num(y_key))))
			previous_x_element = actual_x_value
		if(group.len)
			grouped_atoms += list(group)
	//=================================================
	return grouped_atoms
