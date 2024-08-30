/datum/unit_test/map_test/wall_attachment/check_turf(turf/check_turf, is_map_border)
	var/found = FALSE
	for (var/obj/placed_object in current)
		// Temporary hacky check to see if we contain a directional mapping helper
		// I know its a normal variable, but this is explicitly accessed through reflection
		if (!initial(placed_object._reflection_is_directional))
			continue
		// Check to see if we correctly placed ourselves on a wall
		if (!isclosedturf(get_step(placed_object, placed_object.dir)))
			return "Wall object of type [placed_object.type] is not correctly attached to a wall (Should use cardinal directions only, preferably the mapping helpers)."
