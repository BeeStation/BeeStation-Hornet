/datum/unit_test/smoothing
	//Don't touch these lists below unless you know what you're doing
	//They control what icon states we're checking for in each test

	var/list/bitmask_corner_suffixes = list(
		21, 23, 29, 31, 38, 39, 46, 47, 74, 75, 78, 79, 137, 139, 141, 143, //1 Corner
		55, 63, 95, 110, 111, 157, 159, 175, 203, 207, //2 Corners
		127, 191, 223, 239, 255 //3 and 4 Corners
	)

	var/list/corner_states = list(
		"1-i",
		"2-i",
		"3-i",
		"4-i",
		"1-n",
		"2-n",
		"3-s",
		"4-s",
		"1-w",
		"2-e",
		"3-w",
		"4-e",
		"1-nw",
		"2-ne",
		"3-sw",
		"4-se",
		"1-f",
		"2-f",
		"3-f",
		"4-f"
	)

	var/list/corner_diagonal_states = list(
		"d-se",
		"d-se-0",
		"d-se-1",
		"d-sw",
		"d-sw-0",
		"d-sw-1",
		"d-ne",
		"d-ne-0",
		"d-ne-1",
		"d-nw",
		"d-nw-0",
		"d-nw-1"
	)

/datum/unit_test/smoothing/Run()
	var/list/types_to_test = (subtypesof(/turf)) + (subtypesof(/obj))

	for(var/P in types_to_test)
		var/atom/A = P
		if(!(initial(A.smoothing_flags) & (SMOOTH_BITMASK | SMOOTH_CORNERS)))
			continue

		A = ispath(P, /turf) ? run_loc_floor_bottom_left.ChangeTurf(P) : allocate(P)
		var/smooth_flags = A.smoothing_flags
		var/icon/the_icon = A.icon
		var/base_state = A.base_icon_state

		if(!the_icon)
			Fail("Atom subtype [A] has no icon, are you sure we should be testing this?")

		else if(smooth_flags & SMOOTH_CORNERS)
			corner_test(P, the_icon, smooth_flags)

		else if(smooth_flags & SMOOTH_BITMASK)
			if(!base_state)
				Fail("Atom subtype [A] has bitmask smoothing set, but has no base_icon_state!")
			else
				bitmask_test(P, the_icon, smooth_flags, base_state)

		if(istype(A, /turf))
			run_loc_floor_bottom_left.ChangeTurf(/turf/open/floor/plasteel)

/datum/unit_test/smoothing/proc/bitmask_test(atom_path, icon/the_icon, smooth_flags, base_state)
	var/list/expected_suffixes = list(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
	var/list/states = icon_states(the_icon)

	if(!(smooth_flags & SMOOTH_BITMASK_SKIP_CORNERS))
		expected_suffixes += bitmask_corner_suffixes

	var/missing_states
	for(var/suffix in expected_suffixes)
		if(!("[base_state]-[suffix]" in states))
			missing_states = "[missing_states ? "[missing_states], ": "" ][base_state]-[suffix]"
	if(missing_states)
		Fail("Did not find the following states in icon_states of [the_icon], during testing of path [atom_path]: [missing_states]")

/datum/unit_test/smoothing/proc/corner_test(atom_path, icon/the_icon, smooth_flags)
	var/list/expected_states = corner_states.Copy()
	var/list/states = icon_states(the_icon)
	if(smooth_flags & SMOOTH_DIAGONAL_CORNERS)
		expected_states += corner_diagonal_states

	var/missing_states
	for(var/state in expected_states)
		if(!(state in states))
			missing_states = "[missing_states ? "[missing_states], ": "" ][state]"
	if(missing_states)
		Fail("Did not find the following states in icon_states of [the_icon], during testing of path [atom_path]: [missing_states]")
