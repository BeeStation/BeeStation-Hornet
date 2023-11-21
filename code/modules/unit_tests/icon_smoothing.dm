//These defines control what suffixes we're expecting to find for icons
//Not every combination is valid, corner junctions must neighbor directional junctions.

/datum/unit_test/smoothing
	///A list of types to test. Their subtypes are tested as well.
	var/list/types_to_test = list(
		/obj/structure/bed/nest,
		/obj/structure/alien/resin,
		/obj/structure/alien/weeds,
		/obj/effect/clockwork/overlay/wall,
		/obj/machinery/computer,
		/obj/effect/temp_visual/elite_tumor_wall,
		/obj/structure/falsewall,
		/obj/structure/fluff/hedge,
		/obj/effect/temp_visual/hierophant/wall,
		/obj/structure/lattice,
		/obj/machinery/modular_computer/console,
		/obj/structure/barricade/sandbags,
		/obj/machinery/power/solar_control,
		/obj/structure/table,
		/obj/structure/window,

		/turf/open/floor/bamboo,
		/turf/open/floor/carpet,
		/turf/open/chasm,
		/turf/open/floor/fakepit,
		/turf/open/floor/holofloor/carpet,
		/turf/closed/indestructible,
		/turf/open/lava/smooth,
		/turf/closed/mineral,
		/turf/open/floor/plating,
		/turf/closed/indestructible/sandstone,
		/turf/closed/wall,
		/turf/open/indestructible/hierophant,
	)

	///These need to be initialized to be tested properly
	var/list/init_types = list(/turf/closed/mineral = TRUE)

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
	for(var/P in types_to_test)
		for(var/T in typesof(P))
			var/atom/A
			var/smooth_flags
			var/icon/the_icon
			var/base_state
			if(init_types[P])
				A = T
				smooth_flags = initial(A.smoothing_flags)
				the_icon = initial(A.icon)
				base_state = initial(A.base_icon_state)
			else
				A = new T(run_loc_floor_bottom_left)
				smooth_flags = A.smoothing_flags
				the_icon = A.icon
				base_state = A.base_icon_state

			if(!smooth_flags)
				continue
			else if(!the_icon)
				Fail("Atom subtype [A] has no icon, are you sure we should be testing this?")
				continue

			else if(smooth_flags & SMOOTH_CORNERS) //If both are set for some reason, this version takes priority in the subsystem
				corner_test(T, the_icon, smooth_flags)

			else if(smooth_flags & SMOOTH_BITMASK)
				if(!base_state)
					Fail("Atom subtype [A] has bitmask smoothing set, but has no base_icon_state!")
					continue
				bitmask_test(T, the_icon, smooth_flags, base_state)

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
