/datum/unit_test/brandish_riding_fit/Run()
	var/obj/vehicle/ridden/space/speedbike/seat = allocate(/obj/vehicle/ridden/space/speedbike)
	var/mob/living/carbon/human/consistent/rider = allocate(/mob/living/carbon/human/consistent)
	var/datum/component/riding/component = seat.AddComponent(/datum/component/riding, rider)
	var/list/exact = list(
		TEXT_NORTH = list(3, 14),
		TEXT_EAST = list(7, 10),
		TEXT_SOUTH = list(3, 6),
		TEXT_WEST = list(-1, 10),
	)
	var/list/uniform = list(TEXT_NORTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_WEST = list(0, 4))
	var/list/asymmetric = list(
		TEXT_NORTH = list(0, -8),
		TEXT_EAST = list(-10, 5),
		TEXT_SOUTH = list(0, 4),
		TEXT_WEST = list(10, 5),
	)
	for(var/physical_dir in GLOB.cardinals)
		var/list/fit = component.get_riding_placement(exact, physical_dir, TRUE, 2, 5)
		var/list/legacy = component.get_riding_placement(uniform, physical_dir)
		var/list/symmetric_fit = component.get_riding_placement(uniform, physical_dir, TRUE)
		TEST_ASSERT_EQUAL(jointext(symmetric_fit, ","), jointext(legacy, ","), "Symmetric offsets retain their legacy axes at [physical_dir]")
		for(var/camera_dir in GLOB.cardinals)
			var/list/projected = camera_world_to_screen(fit[1], fit[2], camera_dir)
			var/relative_dir = turn(physical_dir, dir2angle(camera_dir))
			var/list/target = exact["[relative_dir]"]
			TEST_ASSERT_EQUAL(projected[1] + fit[3] + 2, target[1], "World and screen X fit exactly at [physical_dir]/[camera_dir]")
			TEST_ASSERT_EQUAL(projected[2] + fit[4] + 5, target[2], "World and screen Y fit exactly at [physical_dir]/[camera_dir]")
		var/list/legacy_bike = component.get_riding_placement(asymmetric, physical_dir)
		var/list/target_bike = asymmetric["[physical_dir]"]
		TEST_ASSERT_EQUAL(jointext(legacy_bike, ","), "[target_bike[1]],[target_bike[2]],0,0", "OFF placement retains both legacy world offsets")
	var/list/fit_bike = component.get_riding_placement(asymmetric, NORTH, TRUE)
	TEST_ASSERT_EQUAL(jointext(fit_bike, ","), "0,-8,0,2", "Asymmetric samples use all four camera observations and round to pixels")

	for(var/component_type in list(/datum/component/riding/vehicle/scooter, /datum/component/riding/vehicle/scooter/skateboard))
		var/obj/vehicle/ridden/scooter/rounding_seat = allocate(/obj/vehicle/ridden/scooter)
		var/datum/component/riding/rounding_component = rounding_seat.AddComponent(component_type, rider)
		var/list/poses = rounding_component.get_rider_offsets_and_layers(1, rider)
		for(var/physical_dir in GLOB.cardinals)
			var/list/fit = rounding_component.get_riding_placement(poses, physical_dir, TRUE)
			for(var/camera_dir in GLOB.cardinals)
				var/list/rotated = camera_world_to_screen(fit[1], fit[2], camera_dir)
				var/list/target = poses["[turn(physical_dir, dir2angle(camera_dir))]"]
				var/dx = rotated[1] + fit[3] - target[1]
				var/dy = rotated[2] + fit[4] - target[2]
				TEST_ASSERT(dx ** 2 + dy ** 2 <= 4, "[component_type] must fit within two pixels at [physical_dir]/[camera_dir]")

/datum/unit_test/brandish_riding_toggle/Run()
	var/obj/vehicle/ridden/space/speedbike/seat = allocate(/obj/vehicle/ridden/space/speedbike)
	var/mob/living/carbon/human/consistent/rider = allocate(/mob/living/carbon/human/consistent)
	var/saved = GLOB.brandish_perspective_enabled
	set_brandish_perspective(FALSE)
	seat.setDir(EAST)
	var/buckled = seat.buckle_mob(rider, TRUE)
	var/legacy = "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z],[seat.pixel_x],[seat.pixel_y],[seat.pixel_w],[seat.pixel_z],[seat.layer]"
	var/enabled = set_brandish_perspective(TRUE)
	var/changed = legacy != "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z],[seat.pixel_x],[seat.pixel_y],[seat.pixel_w],[seat.pixel_z],[seat.layer]"
	seat.setDir(NORTH)
	var/updated_pose = rider.pixel_x == 0 && rider.pixel_y == -8
	seat.setDir(EAST)
	set_brandish_perspective(FALSE)
	var/restored = "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z],[seat.pixel_x],[seat.pixel_y],[seat.pixel_w],[seat.pixel_z],[seat.layer]"
	seat.unbuckle_mob(rider, TRUE)
	set_brandish_perspective(saved)
	TEST_ASSERT(buckled && enabled && changed, "Toggling Brandish updates an already occupied speedbike")
	TEST_ASSERT(updated_pose, "Turning the occupied vehicle selects its new physical pose")
	TEST_ASSERT_EQUAL(restored, legacy, "Turning Brandish off restores the legacy rider and seat offsets and layer")

/datum/unit_test/brandish_riding_foreground/Run()
	if(!GLOB.brandish_assets.has_catalog())
		return
	var/obj/vehicle/ridden/atv/seat = allocate(/obj/vehicle/ridden/atv)
	var/mob/living/carbon/human/consistent/rider = allocate(/mob/living/carbon/human/consistent)
	// Reuse authored chair artwork to exercise the vehicle mask without
	// introducing a fixture into the generated asset policy.
	seat.icon = 'icons/obj/beds_chairs/chairs.dmi'
	seat.icon_state = "chair"
	seat.setDir(SOUTH)
	var/saved = GLOB.brandish_perspective_enabled
	set_brandish_perspective(FALSE)
	var/buckled = seat.buckle_mob(rider, TRUE)
	var/legacy_layer = seat.layer
	var/datum/component/riding/component = seat.GetComponent(/datum/component/riding)
	var/enabled = set_brandish_perspective(TRUE)
	var/has_mask = !!component?.brandish_foreground && seat.layer == OBJ_LAYER
	seat.cut_overlays()
	seat.update_appearance()
	var/restored_mask = component?.brandish_foreground && (component.brandish_foreground.appearance in seat.overlays)
	set_brandish_perspective(FALSE)
	var/restored = !component?.brandish_foreground && seat.layer == legacy_layer
	seat.unbuckle_mob(rider, TRUE)
	set_brandish_perspective(saved)
	TEST_ASSERT(buckled && enabled && has_mask, "Authored foreground replaces direction-dependent seat layering")
	TEST_ASSERT(restored_mask, "An occupied seat restores its authored mask after overlays are cleared")
	TEST_ASSERT(restored, "Disabling Brandish removes the mask and restores the legacy layer")
	TEST_ASSERT(QDELETED(component), "Unbuckling the last rider disposes of the signal subscriber")

/datum/unit_test/brandish_riding_seat_policies/Run()
	var/saved = GLOB.brandish_perspective_enabled
	var/mob/living/carbon/human/consistent/rider = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/basic/cow/cow = allocate(/mob/living/basic/cow)
	cow.tamed(rider, null)
	var/cow_buckle = cow.buckle_mob(rider, TRUE)
	var/datum/component/riding/creature/cow/cow_riding = cow.GetComponent(/datum/component/riding/creature/cow)
	set_brandish_perspective(FALSE)
	cow.setDir(EAST)
	rider.update_offsets()
	var/legacy = "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z]"
	var/enabled = set_brandish_perspective(TRUE)
	var/cow_fits = cow_riding?.uses_brandish_riding_offsets()
	rider.update_offsets()
	var/fitted = "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z]"
	set_brandish_perspective(FALSE)
	set_station_client_direction(EAST)
	rider.update_offsets()
	var/fixed_view = "[rider.pixel_x],[rider.pixel_y],[rider.pixel_w],[rider.pixel_z]"
	set_station_client_direction(NORTH)
	rider.buckled?.unbuckle_mob(rider, TRUE)
	qdel(cow)
	set_brandish_perspective(TRUE)
	var/obj/vehicle/ridden/space/speedwagon/wagon = allocate(/obj/vehicle/ridden/space/speedwagon)
	var/wagon_buckle = wagon.buckle_mob(rider, TRUE)
	var/datum/component/riding/vehicle/speedwagon/wagon_riding = wagon.GetComponent(/datum/component/riding/vehicle/speedwagon)
	var/wagon_fits = wagon_riding?.uses_brandish_riding_offsets()
	rider.buckled?.unbuckle_mob(rider, TRUE)
	qdel(wagon)
	var/obj/vehicle/ridden/lavaboat/dragon/boat = allocate(/obj/vehicle/ridden/lavaboat/dragon)
	var/boat_buckle = boat.buckle_mob(rider, TRUE)
	var/datum/component/riding/vehicle/lavaboat/dragonboat/boat_riding = boat.GetComponent(/datum/component/riding/vehicle/lavaboat/dragonboat)
	var/boat_fits = boat_riding?.uses_brandish_riding_offsets()
	rider.buckled?.unbuckle_mob(rider, TRUE)
	qdel(boat)
	var/obj/vehicle/ridden/atv/seat = allocate(/obj/vehicle/ridden/atv)
	seat.buckle_lying = 90
	var/atv_buckle = seat.buckle_mob(rider, TRUE)
	var/lying = rider.body_position
	var/lying_z = rider.has_offset("riding", PIXEL_Z_OFFSET)
	rider.buckled?.unbuckle_mob(rider, TRUE)
	set_brandish_perspective(saved)
	TEST_ASSERT(cow_buckle && enabled && cow_fits && fitted != legacy, "Tamed cows fit riding offsets through the creature component")
	TEST_ASSERT_EQUAL(fixed_view, legacy, "The fixed direction trait retains legacy offsets")
	TEST_ASSERT(wagon_buckle && wagon_riding && !wagon_fits, "A multi-seat speedwagon retains its legacy pose")
	TEST_ASSERT(boat_buckle && boat_riding && !boat_fits, "The dragonboat retains its legacy pose")
	TEST_ASSERT(atv_buckle && lying == LYING_DOWN, "A lying buckle exercises the riding adjustment")
	TEST_ASSERT_EQUAL(lying_z, 4 - PIXEL_Y_OFFSET_LYING, "The ATV seat height is added to the adjustment for the lying pose")
