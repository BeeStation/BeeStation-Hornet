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

/datum/unit_test/brandish_multiz_direction_expression/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/use_east = TRUE
	var/turf/expected = get_step(origin, EAST)
	TEST_ASSERT(isturf(expected), "The unit test floor has an east neighbor")
	TEST_ASSERT_EQUAL(get_step_multiz(origin, use_east ? EAST : DOWN), expected, "The step macro evaluates the whole direction expression before testing its flags")

/datum/brandish_test_viewer/zlook/brandish_has_local_eye()
	return call(src, /client/proc/brandish_has_local_eye)()

/datum/brandish_test_viewer/zlook/proc/sync_camera()
	call(src, /client/proc/sync_brandish_camera)()

/mob/living/carbon/human/consistent/brandish_zlook_probe
	var/turf/test_aperture

/mob/living/carbon/human/consistent/brandish_zlook_probe/find_visible_hole_in_direction(direction)
	return test_aperture

/datum/unit_test/brandish_zlook_eye_lifecycle/Run()
	var/mob/living/carbon/human/consistent/brandish_zlook_probe/body = allocate(/mob/living/carbon/human/consistent/brandish_zlook_probe)
	body.test_aperture = run_loc_floor_top_right
	body.look_down(lock = TRUE)
	TEST_ASSERT_EQUAL(body.current_mob_eye, body.test_aperture, "Actual look-down selects the aperture")
	TEST_ASSERT_EQUAL(body.zlook_target, body.test_aperture, "Z-look owns the aperture")
	ADD_TRAIT(body, TRAIT_INCAPACITATED, REF(src))
	TEST_ASSERT(!body.update_looking_move(), "Incapacitation stops z-look during movement")
	TEST_ASSERT_EQUAL(body.current_mob_eye, body, "The eye stays on the body")
	TEST_ASSERT_NULL(body.zlook_target, "The old aperture is released")
	REMOVE_TRAIT(body, TRAIT_INCAPACITATED, REF(src))
	body.look_reset()
	body.look_down(lock = TRUE)
	var/obj/remote_eye = allocate(/obj)
	body.set_mob_eye_to(remote_eye)
	TEST_ASSERT_NULL(body.zlook_target, "Taking over the eye releases the aperture")
	TEST_ASSERT(!body.update_looking_move(), "Moving after an eye handoff does not reclaim it")
	TEST_ASSERT_EQUAL(body.current_mob_eye, remote_eye, "The remote eye survives movement")

/datum/unit_test/brandish_camera_policy/zlook_retains_camera/Run()
	var/datum/brandish_test_viewer/zlook/viewer = allocate(/datum/brandish_test_viewer/zlook)
	var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
	viewer.mob = body
	viewer.eye = body
	viewer.composed_camera_state = allocate(/datum/client_camera_state)
	var/datum/brandish_camera/camera = allocate(/datum/brandish_camera/policy_test, viewer)
	camera.register_body_signals()
	set_default_client_dir(NORTH)
	for(var/facing in GLOB.cardinals)
		viewer.setDir(facing)
		body.setDir(facing)
		for(var/look_direction in list(1, -1))
			body.looking_direction = look_direction
			body.zlook_target = get_step(body, NORTH)
			viewer.eye = body.zlook_target
			SEND_SIGNAL(body, COMSIG_MOB_SET_MOB_EYE, viewer.eye, body)
			TEST_ASSERT_EQUAL(viewer.brandish_camera, camera, "Entering z-look keeps the camera")
			TEST_ASSERT_EQUAL(viewer.dir, facing, "Entering z-look keeps the heading")
			var/list/composed = viewer.composed_camera_state.resolve(TRUE, TRUE)
			TEST_ASSERT_EQUAL(composed[BRANDISH_RESULT_SCREEN_Y], 0, "The other floor's aperture stays centered")

			var/turf/old_eye = viewer.eye
			body.zlook_target = get_step(body, EAST)
			viewer.eye = body.zlook_target
			SEND_SIGNAL(body, COMSIG_MOB_SET_MOB_EYE, viewer.eye, old_eye)
			TEST_ASSERT_EQUAL(viewer.brandish_camera, camera, "Changing apertures keeps the camera")
			TEST_ASSERT_EQUAL(viewer.dir, facing, "Changing apertures keeps the heading")

			body.look_reset()
			viewer.eye = body
			SEND_SIGNAL(body, COMSIG_MOB_SET_MOB_EYE, body, old_eye)
			TEST_ASSERT_EQUAL(viewer.brandish_camera, camera, "Leaving z-look keeps the camera")
			TEST_ASSERT_EQUAL(viewer.dir, facing, "Leaving z-look keeps the heading")
			composed = viewer.composed_camera_state.resolve(TRUE, TRUE)
			TEST_ASSERT_EQUAL(composed[BRANDISH_RESULT_SCREEN_Y], 2 * ICON_SIZE_Y, "Returning to the body restores look-ahead")

/datum/unit_test/brandish_camera_policy/zlook_invalidation/Run()
	var/datum/brandish_test_viewer/zlook/viewer = allocate(/datum/brandish_test_viewer/zlook)
	viewer.composed_camera_state = allocate(/datum/client_camera_state)
	for(var/cause in list("remote turf", "remote object", "logout", "death", "deletion", "transfer"))
		var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
		viewer.mob = body
		body.looking_direction = 1
		body.zlook_target = run_loc_floor_bottom_left
		viewer.eye = body.zlook_target
		var/datum/brandish_camera/camera = allocate(/datum/brandish_camera/policy_test, viewer)
		camera.register_body_signals()
		TEST_ASSERT(camera.is_available(), "Z-look is local while the body is eligible")
		switch(cause)
			if("remote turf", "remote object")
				viewer.eye = cause == "remote turf" ? run_loc_floor_top_right : allocate(/obj)
				SEND_SIGNAL(body, COMSIG_MOB_SET_MOB_EYE, viewer.eye, body.zlook_target)
			if("logout")
				SEND_SIGNAL(body, COMSIG_MOB_LOGOUT)
			if("death")
				body.stat = DEAD
				SEND_SIGNAL(body, COMSIG_MOB_STATCHANGE)
			if("deletion")
				qdel(body)
			if("transfer")
				viewer.mob = allocate(/mob/living/carbon/human/consistent)
				viewer.sync_camera()
		TEST_ASSERT(QDELETED(camera) && !viewer.brandish_camera, "Z-look camera is cleared on [cause]")
