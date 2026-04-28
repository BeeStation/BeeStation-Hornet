/datum/unit_test/map_test/active_turfs/check_map()
	var/list/failures = list()
	for(var/turf/t in GLOB.active_turfs_startlist)
		failures += "Roundstart active turf at ([t.x], [t.y], [t.z] in [t.loc])"
	if (length(failures))
		TEST_FAIL(jointext(failures, "\n"))
