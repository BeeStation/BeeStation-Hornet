/datum/unit_test/map_test/glass_on_space/check_turf(turf/check_turf, is_map_border)
	if(!isgroundlessturf(check_turf)) //Check for openspace, lava, space, etc.
		//Pass if Not Groundless
		return
	if(check_turf.contains(/obj/structure/window))
		return "Window is on a Groundless Tile (Space/Openspace/Lava most likely)"
