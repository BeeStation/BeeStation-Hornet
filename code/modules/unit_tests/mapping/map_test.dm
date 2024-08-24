/datum/unit_test/map_test/Run()
	var/list/failures
	var/list/areas = list()
	for (var/z in 1 to world.maxz)
		if (!is_station_level(z))
			continue
		for (var/x in 1 to world.maxx)
			for (var/y in 1 to world.maxy)
				var/turf/tile = locate(x, y, z)
				areas[tile.loc] = TRUE
				var/result = check_tile(tile, x == 1 || x == world.maxx || y == 1 || y == world.maxy)
				if (result)
					LAZYADD(failures, result)
	for (var/area/A in areas)
		var/result = check_area(A)
		if (result)
			LAZYADD(failures, result)
	if (LAZYLEN(failures))
		TEST_FAIL(jointext(failures, "\n"))
	for (var/z in 1 to world.maxz)
		if (!is_station_level(z))
			continue
		var/result = check_z_level(z)
		if (result)
			LAZYADD(failures, result)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_tile(turf/T, is_map_border)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_area(area/T)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_z_level(z_value)

/datum/unit_test/map_test/test/check_tile(turf/T, is_map_border)
	if (istype(T, /turf/closed/wall))
		return "[T.type] detected"
