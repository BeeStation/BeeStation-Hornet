/proc/create_all_lighting_objects()
	for(var/area/A in world)
		for(var/turf/T in A)
			new/atom/movable/lighting_darkness(T)
			CHECK_TICK
		CHECK_TICK
