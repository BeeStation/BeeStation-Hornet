/datum/unit_test/map_test
	priority = TEST_MAPPING

/datum/unit_test/map_test/Run()
	var/list/failures
	var/list/areas = list()
	var/list/turfs = list()
	// Check turfs
	for (var/z in 1 to world.maxz)
		if (!is_station_level(z))
			continue
		for (var/x in 1 to world.maxx)
			for (var/y in 1 to world.maxy)
				var/turf/tile = locate(x, y, z)
				turfs += tile
				areas[tile.loc] = TRUE
				var/result = check_turf(tile, x == 1 || x == world.maxx || y == 1 || y == world.maxy)
				if (islist(result))
					for (var/msg in result)
						LAZYADD(failures, "([x], [y], [z]): [msg]")
				else if (result)
					LAZYADD(failures, "([x], [y], [z]): [result]")
	// Check areas
	for (var/area/A in areas)
		var/result = check_area(A)
		if (islist(result))
			for (var/msg in result)
				LAZYADD(failures, "([A.type]): [msg]")
		else if (result)
			LAZYADD(failures,  "([A.type]): [result]")
	// Check Zs
	for (var/z in 1 to world.maxz)
		if (!is_station_level(z))
			continue
		var/result = check_z_level(z)
		if (result)
			LAZYADD(failures, result)
	// Get things we want to specifically test for
	var/list/targets = collect_targets(turfs)
	for (var/target in targets)
		var/result = check_target(target)
		if (result)
			LAZYADD(failures, result)
	// Full map general checks
	var/result = check_map()
	if (result)
		LAZYADD(failures, result)
	// Fail if necessary
	for (var/failure in failures)
		TEST_FAIL(failure)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_turf(turf/check_turf, is_map_border)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_area(area/check_area)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_z_level(z_value)

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_map()

/// Returns a list of things that you want to specifically check
/datum/unit_test/map_test/proc/collect_targets(list/turfs)
	return list()

/// Return a string if failed, return null otherwise
/datum/unit_test/map_test/proc/check_target(atom/target)
