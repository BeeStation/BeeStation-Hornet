/proc/create_all_lighting_objects()
	for(var/area/A in GLOB.sortedAreas)
		if(!A.static_lighting)
			continue

		for(var/turf/T in A)
			if(T.always_lit)
				continue
			new/atom/movable/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
