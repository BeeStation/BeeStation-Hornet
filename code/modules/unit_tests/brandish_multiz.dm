/// Records the first sync point in the real zcopy overlay processing path.
/atom/movable/openspace/mimic/unit_bounds_probe
	var/sync_count = 0
	var/icon_before_first_sync

/atom/movable/openspace/mimic/unit_bounds_probe/sync_display_bounds()
	if(!sync_count)
		icon_before_first_sync = icon
	sync_count++
	return ..()

/datum/unit_test/brandish_multiz_bounds/Run()
	var/obj/source = allocate(/obj)
	source.icon = 'icons/obj/2x2.dmi'
	source.icon_state = "large_engine"
	source.density = TRUE
	source.opacity = TRUE
	source.bound_width = 96
	source.bound_height = 64
	source.bound_x = -32
	source.pixel_w = -32
	source.pixel_z = -32
	var/atom/movable/openspace/mimic/unit_bounds_probe/first = allocate(/atom/movable/openspace/mimic/unit_bounds_probe)
	var/atom/movable/openspace/mimic/unit_bounds_probe/second = allocate(/atom/movable/openspace/mimic/unit_bounds_probe)
	source.bound_overlay = first
	first.associated_atom = source
	first.bound_overlay = second
	second.associated_atom = first
	first.depth = 1
	second.depth = 2
	for(var/pass in 1 to 2)
		if(pass == 2)
			source.bound_width = 128
			source.bound_height = 224
			source.bound_x = 0
			source.bound_y = -32
		// Exercise actual queued copying, including recursive source geometry.
		first.queued++
		second.queued++
		SSzcopy.queued_overlays += list(first, second)
		SSzcopy.fire(FALSE, TRUE)
		for(var/atom/movable/openspace/mimic/copy in list(first, second))
			TEST_ASSERT_EQUAL(copy.bound_width, source.bound_width, "Width follows the source on pass [pass]")
			TEST_ASSERT_EQUAL(copy.bound_height, source.bound_height, "Height follows the source on pass [pass]")
			TEST_ASSERT_EQUAL(copy.bound_x, source.bound_x, "Negative footprint X follows the source")
			TEST_ASSERT_EQUAL(copy.bound_y, source.bound_y, "Changed footprint Y follows the source")
			TEST_ASSERT_EQUAL(copy.pixel_w, -32, "Screen origin remains part of appearance")
			TEST_ASSERT_EQUAL(copy.pixel_z, -32, "Screen elevation remains part of appearance")
			TEST_ASSERT(!copy.density && !copy.opacity, "A dense opaque source must leave a non-colliding visible proxy")
			TEST_ASSERT_EQUAL(length(copy.locs), length(source.locs), "Footprint occupies the same number of turfs")
	TEST_ASSERT(isnull(first.icon_before_first_sync), "Geometry sync precedes the first source appearance")
	TEST_ASSERT(isnull(second.icon_before_first_sync), "Recursive geometry sync precedes the first source appearance")

/datum/unit_test/brandish_multiz_movement
	var/physical_events = 0

/datum/unit_test/brandish_multiz_movement/Run()
	var/obj/source = allocate(/obj)
	source.bound_width = 64
	source.bound_height = 64
	var/atom/movable/openspace/mimic/copy = allocate(/atom/movable/openspace/mimic)
	copy.associated_atom = source
	source.bound_overlay = copy
	copy.sync_display_bounds()
	for(var/turf/tile in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		RegisterSignals(tile, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(on_physical_event))
	RegisterSignals(get_area(copy), list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(on_physical_event))
	var/turf/destination = get_step(copy, EAST)
	TEST_ASSERT(copy.forceMove(destination), "A display proxy still follows its source")
	TEST_ASSERT_EQUAL(copy.loc, destination, "Native footprint moves to the destination")
	TEST_ASSERT_EQUAL(length(copy.locs), 4, "Moving preserves the 2x2 display footprint")
	TEST_ASSERT_EQUAL(physical_events, 0, "Display movement must not trigger physical turf/area events")
	TEST_ASSERT_EQUAL(source.loc, run_loc_floor_bottom_left, "Moving the copy does not move the original")

/datum/unit_test/brandish_multiz_movement/proc/on_physical_event()
	SIGNAL_HANDLER
	physical_events++

/datum/unit_test/brandish_camera_policy/zlook_resume/Run()
	var/datum/brandish_test_viewer/viewer = allocate(/datum/brandish_test_viewer)
	var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
	viewer.mob = body
	viewer.eye = body
	set_default_client_dir(NORTH)
	for(var/facing in GLOB.cardinals)
		body.setDir(SOUTH)
		var/datum/brandish_camera/policy_test/camera = allocate(/datum/brandish_camera/policy_test, viewer)
		viewer.setDir(facing)
		body.setDir(facing)
		body.looking_direction = -1
		viewer.remember_brandish_zlook(body, run_loc_floor_bottom_left)
		viewer.eye = run_loc_floor_bottom_left
		viewer.local_eye = FALSE
		qdel(camera)
		TEST_ASSERT_EQUAL(viewer.dir, NORTH, "While looking, existing default-heading teardown is preserved")
		TEST_ASSERT_EQUAL(body.dir, SOUTH, "Temporary teardown still restores the previous physical facing")
		TEST_ASSERT(viewer.brandish_zlook_resume?.is_valid(), "A matching z-look retains its resume state")
		body.looking_direction = 0
		viewer.eye = body
		viewer.local_eye = TRUE
		var/list/resumed = viewer.take_brandish_zlook_resume()
		TEST_ASSERT_EQUAL(resumed?[1], facing, "Last camera heading survives z-look at [facing]")
		TEST_ASSERT_EQUAL(resumed?[2], SOUTH, "A later real teardown retains the original physical facing")
		TEST_ASSERT_EQUAL(body.dir, SOUTH, "Taking a resume record does not mutate physical direction")
		var/datum/brandish_camera/restored = allocate(/datum/brandish_camera/policy_test, viewer, resumed?[BRANDISH_RESUME_HEADING], resumed?[BRANDISH_RESUME_RESTORE_DIR])
		TEST_ASSERT_EQUAL(body.dir, facing, "The constructor receives the resumed heading directly")
		TEST_ASSERT_EQUAL(restored.previous_body_dir, SOUTH, "The constructor retains the eventual teardown direction")
		qdel(restored)
		TEST_ASSERT(isnull(viewer.brandish_zlook_resume), "Resume is consumed exactly once")
		TEST_ASSERT(isnull(viewer.take_brandish_zlook_resume()), "A second consume cannot restore stale state")

/datum/unit_test/brandish_camera_policy/zlook_invalidation/Run()
	var/datum/brandish_test_viewer/viewer = allocate(/datum/brandish_test_viewer)
	var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
	viewer.mob = body
	viewer.eye = run_loc_floor_bottom_left
	viewer.local_eye = FALSE
	body.looking_direction = 1
	var/datum/brandish_zlook_resume/state = allocate(/datum/brandish_zlook_resume, viewer, body, run_loc_floor_bottom_left, EAST, SOUTH)
	viewer.brandish_zlook_resume = state
	TEST_ASSERT(state.is_valid(), "Approved turf eye is a temporary z-look")
	viewer.eye = run_loc_floor_top_right
	TEST_ASSERT(!state.is_valid(), "An unrelated remote turf eye is not a z-look resume")
	viewer.eye = run_loc_floor_bottom_left
	body.remote_control = allocate(/obj)
	TEST_ASSERT(!state.is_valid(), "Remote control invalidates z-look state")
	body.remote_control = null
	body.control_object = allocate(/obj)
	TEST_ASSERT(!state.is_valid(), "Controlled objects invalidate z-look state")
	body.control_object = null
	viewer.brandish_camera_suppressed = TRUE
	TEST_ASSERT(!state.is_valid(), "Opt-out invalidates z-look state")
	viewer.brandish_camera_suppressed = FALSE
	viewer.brandish_disconnecting = TRUE
	TEST_ASSERT(!state.is_valid(), "Disconnect invalidates z-look state")
	viewer.brandish_disconnecting = FALSE
	set_brandish_perspective(FALSE)
	TEST_ASSERT(!state.is_valid(), "Global off invalidates z-look state")
	set_brandish_perspective(TRUE)
	viewer.mob = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(!state.is_valid(), "A new body cannot resume the old body's heading")
	viewer.mob = body
	SEND_SIGNAL(body, COMSIG_MOB_LOGOUT)
	TEST_ASSERT(isnull(viewer.brandish_zlook_resume), "Logout destroys cached state before a transfer can return")
	state = allocate(/datum/brandish_zlook_resume, viewer, body, run_loc_floor_bottom_left, WEST, SOUTH)
	viewer.brandish_zlook_resume = state
	body.stat = DEAD
	SEND_SIGNAL(body, COMSIG_MOB_STATCHANGE)
	TEST_ASSERT(isnull(viewer.brandish_zlook_resume), "Death destroys cached state")
