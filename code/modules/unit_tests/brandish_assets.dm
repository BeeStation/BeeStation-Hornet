/// Collision geometry and ordinary overlays must survive an appearance copy.
/datum/unit_test/brandish_gateway_art/Run()
	if(!GLOB.brandish_assets.supports('icons/obj/machines/gateway.dmi', BRANDISH_ASSET_VIEW_GATES))
		return
	var/obj/machinery/gateway/gate = allocate(/obj/machinery/gateway)
	TEST_ASSERT_EQUAL(gate.bound_width, 96, "Gateway collision width remains three tiles")
	TEST_ASSERT_EQUAL(gate.bound_height, 64, "Gateway entry row remains outside its two-tile collision box")
	TEST_ASSERT_EQUAL(gate.bound_x, -32, "Gateway collision still extends west")
	TEST_ASSERT_EQUAL(length(gate.vis_contents), 0, "Gateway art must survive z-mimic without visual contents")
	TEST_ASSERT_EQUAL(gate.pixel_x, 0, "Gateway bitmap origin is not world placement")
	TEST_ASSERT_EQUAL(gate.pixel_y, 0, "Gateway bitmap origin is not world placement")
	TEST_ASSERT_EQUAL(gate.pixel_w, -32, "Gateway art is centred horizontally")
	TEST_ASSERT_EQUAL(gate.pixel_z, -32, "Gateway art is centred vertically")
	var/list/offsets = list("1" = list(0, 0), "4" = list(0, 32), "2" = list(0, 32), "8" = list(-32, 32))
	for(var/state in list(FALSE, TRUE))
		gate.active = state
		gate.update_appearance()
		TEST_ASSERT_EQUAL(length(gate.overlays), 4, "Each viewer selects one native view gate")
		var/index = 0
		for(var/facing in GLOB.cardinals)
			var/image/drawing = gate.overlays[++index]
			var/list/offset = offsets["[facing]"]
			TEST_ASSERT_EQUAL(drawing.icon_state, state ? "on@2" : "off@2", "The attached drawing follows activation")
			TEST_ASSERT_EQUAL(drawing.pixel_w, offset[1], "Horizontal collision-anchor correction at [facing]")
			TEST_ASSERT_EQUAL(drawing.pixel_z, offset[2], "Vertical collision-anchor correction at [facing]")
	var/obj/effect/copy = allocate(/obj/effect)
	copy.appearance = gate.appearance
	TEST_ASSERT_EQUAL(length(copy.overlays), length(gate.overlays), "An appearance copy retains the gateway drawing")

/datum/unit_test/brandish_beam_terminal/Run()
	if(!GLOB.brandish_assets.supports('icons/effects/beam.dmi', BRANDISH_ASSET_VIEW_GATES))
		return
	var/obj/effect/ebeam/segment = allocate(/obj/effect/ebeam)
	segment.icon = 'icons/effects/beam.dmi'
	segment.icon_state = "lightning1"
	var/matrix/rotation = matrix()
	rotation.Turn(37)
	segment.project_beam(rotation, 13)
	var/datum/world_space_icon/beam/projection = segment.world_space_icon
	TEST_ASSERT_EQUAL(projection.clip_length, 13, "The terminal segment retains its length")
	TEST_ASSERT(segment.beam_emissive_projection?.projected, "Terminal emissive art uses the same projection")
	for(var/image/drawing as anything in projection.layers)
		TEST_ASSERT(isicon(drawing.icon), "Terminal art is cropped before transforming")
		TEST_ASSERT_EQUAL(drawing.icon_state, "", "The icon constructor renames the cropped state")
		var/icon/cropped = icon(drawing.icon)
		TEST_ASSERT_EQUAL(cropped.GetPixel(16, 25, SOUTH), null, "Pixels beyond the terminal length remain transparent")
	var/found_terminal = FALSE
	for(var/appearance as anything in segment.overlays)
		var/image/drawing = appearance
		if(isicon(drawing.icon) && drawing.icon_state == "")
			found_terminal = TRUE
	TEST_ASSERT(found_terminal, "Cropped appearances must be reattached after mutating the cached layers")
	segment.update_appearance(UPDATE_OVERLAYS)
	TEST_ASSERT(segment.beam_emissive_projection?.projected, "Appearance updates preserve emissive projection")

/datum/unit_test/brandish_fixed_wall_and_duct/Run()
	var/wall_path = /turf/closed/indestructible/abductor
	var/generator_path = /obj/machinery/gravity_generator
	TEST_ASSERT_EQUAL(initial(wall_path:smoothing_flags), NONE, "Abductor walls are mapped fixed states, not diagonal smoothing")
	TEST_ASSERT_EQUAL(initial(wall_path:brandish_icon_mode), BRANDISH_MODE_SURFACE, "Fixed walls use the same world geometry policy")
	TEST_ASSERT_EQUAL(initial(generator_path:brandish_icon_mode), BRANDISH_MODE_SURFACE, "Every gravity-generator part uses world geometry")
	if(!GLOB.brandish_assets.supports('icons/obj/plumbing/fluid_ducts.dmi', BRANDISH_MODE_SURFACE))
		return
	var/obj/machinery/duct/duct = allocate(/obj/machinery/duct, run_loc_floor_bottom_left)
	duct.connects = NORTH | EAST
	duct.update_icon()
	var/connections = duct.connects
	var/physical_dir = duct.dir
	APPLY_BRANDISH_ICON(duct)
	TEST_ASSERT_EQUAL(duct.connects, connections, "Rendering must not mutate duct connection bits")
	TEST_ASSERT_EQUAL(duct.dir, physical_dir, "The fixed-state overlay must not mutate physical direction")
	TEST_ASSERT_EQUAL(duct.brandish_duct_image?.dir, NORTH, "State topology uses an explicit world direction")
