/proc/create_all_lighting_objects()
	for(var/area/A as anything in GLOB.areas)
		if(!IS_DYNAMIC_LIGHTING(A))
			continue

		for(var/turf/T as anything in A.get_contained_turfs())
			if(T.fullbright_type)
				continue

			new/atom/movable/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
