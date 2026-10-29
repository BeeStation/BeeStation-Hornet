/// Covers the rectangle decomposition behind the station schematic
/datum/unit_test/minimap_rects

/// Builds the "[y]" to list(x) shape that decompose_rows_to_rects() consumes
/datum/unit_test/minimap_rects/proc/rows_from(list/cells)
	var/list/rows = list()
	for(var/list/cell as anything in cells)
		LAZYADD(rows["[cell[2]]"], cell[1])
	return rows

/// Total area covered, to check a decomposition neither loses nor double-counts cells.
/datum/unit_test/minimap_rects/proc/covered_area(list/rects)
	var/total = 0
	for(var/list/rect as anything in rects)
		total += (rect[3] - rect[1] + 1) * (rect[4] - rect[2] + 1)
	return total

/datum/unit_test/minimap_rects/Run()
	test_solid_block()
	test_disjoint_rows()
	test_l_shape()
	test_single_cell()

/// Most rooms are a filled rectangle, and one has to collapse to exactly one rect
/datum/unit_test/minimap_rects/proc/test_solid_block()
	var/list/cells = list()
	for(var/x in 5 to 8)
		for(var/y in 10 to 12)
			cells += list(list(x, y))

	var/list/rects = decompose_rows_to_rects(rows_from(cells))
	if(length(rects) != 1)
		TEST_FAIL("A 4x3 solid block should collapse to one rect, got [length(rects)].")
		return
	var/list/rect = rects[1]
	if(rect[1] != 5 || rect[2] != 10 || rect[3] != 8 || rect[4] != 12)
		TEST_FAIL("Expected bounds (5,10)-(8,12), got ([rect[1]],[rect[2]])-([rect[3]],[rect[4]]).")

/// Rows that do not touch must not be merged into one rect spanning the gap between them
/datum/unit_test/minimap_rects/proc/test_disjoint_rows()
	// Two separate 2x1 runs on the same row, with a hole between them.
	var/list/cells = list(list(1, 1), list(2, 1), list(5, 1), list(6, 1))
	var/list/rects = decompose_rows_to_rects(rows_from(cells))

	if(length(rects) != 2)
		TEST_FAIL("Two runs separated by a gap should stay two rects, got [length(rects)].")
	if(covered_area(rects) != 4)
		TEST_FAIL("Expected 4 cells covered, got [covered_area(rects)] - the gap was swallowed.")

/// Catches a vertical merge that ignores column bounds.
/datum/unit_test/minimap_rects/proc/test_l_shape()
	var/list/cells = list(
		list(1, 1), list(2, 1), list(3, 1),
		list(1, 2),
		list(1, 3),
	)
	var/list/rects = decompose_rows_to_rects(rows_from(cells))

	// Must not be one rect. rows 2 and 3 are one cell wide, row 1 is three.
	if(length(rects) < 2)
		TEST_FAIL("An L shape cannot be a single rect, got [length(rects)].")
	if(covered_area(rects) != 5)
		TEST_FAIL("Expected exactly 5 cells covered, got [covered_area(rects)].")

/// Degenerate input, a one-tile area still has to produce a usable rect.
/datum/unit_test/minimap_rects/proc/test_single_cell()
	var/list/rects = decompose_rows_to_rects(rows_from(list(list(42, 7))))
	if(length(rects) != 1)
		TEST_FAIL("A single cell should be one rect, got [length(rects)].")
		return
	var/list/rect = rects[1]
	if(rect[1] != 42 || rect[2] != 7 || rect[3] != 42 || rect[4] != 7)
		TEST_FAIL("Expected a 1x1 rect at (42,7), got ([rect[1]],[rect[2]])-([rect[3]],[rect[4]]).")
