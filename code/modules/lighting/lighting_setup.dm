/proc/create_all_lighting_objects()
	for(var/area/A in GLOB.sortedAreas)
		if(!IS_DYNAMIC_LIGHTING(A))
			continue
		for(var/turf/T in A)
			new/atom/movable/lighting_darkness(T)
			CHECK_TICK
		CHECK_TICK

