
//Returns a list of matrices corresponding to the matrices that should be applied to triangles of
//coordinates (0,0),(1,0),(0,1) to create a triangle that respresents the shadows
/atom/movable/lighting_mask/proc/calculate_shadows_matrices(range)
	//Optimise grouping by storing as
	// Key : x (AS A STRING BECAUSE BYOND DOESNT ALLOW FOR INT KEY DICTIONARIES)
	// Value: List(y values)
	var/list/opaque_atoms_in_view = list()
	var/red = 0
	//Find atoms that are opaque
	for(var/atom/thing as() in view(range, get_turf(src)))
		if(thing.opacity)
			//At this point we no longer care about
			//the atom itself, only the position values
			if(islist(opaque_atoms_in_view["[thing.x]"]))
				opaque_atoms_in_view["[thing.x]"] += thing.y
			else
				opaque_atoms_in_view["[thing.x]"] = list(thing.y)
			red += 5
	//Group atoms together for optimisation
	//opaque_atoms_in_view = group_atoms(opaque_atoms_in_view)

//Groups things into vertical and horizontal lines.
//Input: All atoms ungrouped list(atom1, atom2, atom3)
//Output: List(List(Group), list(group2), ... , list(groupN))
//Output: List(List(atom1, atom2), list(atom3, atom4...), ... , list(atomN))
/atom/movable/lighting_mask/proc/group_atoms(list/ungrouped_things)
	var/list/grouped_atoms = list()
	//Group horizontally first because its quick and easy
	for(var/x_key in ungrouped_things)
		//Populate the grouped atom keys while we are here
		grouped_atoms[x_key] = list()
		//Collect all y elements on that x plane
		var/list/y_elements = ungrouped_things[x_key]
		//Too few elements to group
		if(y_elements.len <= 1)
			continue
		//Loop through elements and check if they are new to each other
		var/previous_y_element = y_elements[1]
		for(var/i in 2 to length(y_elements))
			var/actual_y_value = y_elements[i]

