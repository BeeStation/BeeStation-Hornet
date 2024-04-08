/**
 * Checks if every wall in game has sheet_type set up.
 */
/datum/unit_test/walls_have_sheets/Run()
	for(var/turf/closed/wall/W in subtypesof(/turf/closed/wall))
		TEST_ASSERT_NOTNULL(W.sheet_type, "([W.type]) does not have a sheet_type set up.")
