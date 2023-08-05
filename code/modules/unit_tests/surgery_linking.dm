/datum/unit_test/surgery_linking/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/middle = get_step(left, EAST)
	var/turf/right = get_step(middle, EAST)

	// Check computer-first.

	var/obj/machinery/computer/operating/computer = new(middle)
	var/obj/machinery/stasis/stasis = new(left)
	var/obj/structure/table/optable/table = new(right)

	TEST_ASSERT_EQUAL(computer.sbed, stasis, "Stasis bed failed to link to operating computer (computer.sbed doesn't match)")
	TEST_ASSERT_EQUAL(stasis.op_computer, computer, "Stasis bed failed to link to operating computer (stasis.op_computer doesn't match)")
	TEST_ASSERT_EQUAL(table.computer, computer, "Operating table failed to link to operating computer (table.computer doesn't match)")
	TEST_ASSERT_EQUAL(computer.table, table, "Operating table failed to link to operating computer (computer.table doesn't match)")

	QDEL_NULL(computer)
	QDEL_NULL(stasis)
	QDEL_NULL(table)

	// Then, check computer-last

	stasis = new(left)
	table = new(right)
	computer = new(middle)

	TEST_ASSERT_EQUAL(computer.sbed, stasis, "Operating computer failed to link to stasis bed (computer.sbed doesn't match)")
	TEST_ASSERT_EQUAL(stasis.op_computer, computer, "Operating computer failed to link to stasis bed (stasis.op_computer doesn't match)")
	TEST_ASSERT_EQUAL(table.computer, computer, "Operating computer failed to link to operating table (table.computer doesn't match)")
	TEST_ASSERT_EQUAL(computer.table, table, "Operating computer failed to link to operating table (computer.table doesn't match)")

	QDEL_NULL(computer)
	QDEL_NULL(stasis)
	QDEL_NULL(table)
