/proc/create_all_lighting_objects()
	for(var/area/A in world)

		if(!A.legacy_lighting)
			continue

		for(var/turf/T in A)
			new/atom/movable/legacy_lighting_object(T)
			CHECK_TICK
		CHECK_TICK
