/obj/effect/brandish_image_probe
	brandish_image = /datum/brandish_image/probe
	var/policy_setups = 0

/datum/brandish_image/probe
	var/setup_calls = 0

/datum/brandish_image/probe/setup(atom/target)
	var/obj/effect/brandish_image_probe/probe = target
	probe.policy_setups++
	probe.pixel_w += 7
	setup_calls++

/datum/unit_test/brandish_image_setup/Run()
	var/obj/effect/brandish_image_probe/first = allocate(/obj/effect/brandish_image_probe)
	var/datum/brandish_image/probe/shared = GLOB.brandish_images[/datum/brandish_image/probe]
	var/previous_calls = shared.setup_calls
	var/obj/effect/brandish_image_probe/second = allocate(/obj/effect/brandish_image_probe)
	TEST_ASSERT_EQUAL(GLOB.brandish_images[/datum/brandish_image/probe], shared, "A policy type shares one datum")
	TEST_ASSERT_EQUAL(shared.setup_calls, previous_calls + 1, "Each new instance is configured")
	TEST_ASSERT_EQUAL(first.brandish_image, /datum/brandish_image/probe, "Setup leaves the policy at its type default")
	for(var/facing in GLOB.cardinals)
		first.setDir(facing)
		first.update_appearance()
	TEST_ASSERT_EQUAL(first.policy_setups, 1, "Turns and appearance updates never rerun setup")
	TEST_ASSERT_EQUAL(first.pixel_w, 7, "The configured instance retains its own offset")
	TEST_ASSERT_EQUAL(second.policy_setups, 1, "A second instance is configured exactly once")

/obj/structure/sign/directions/science/brandish_origin_probe
	pixel_x = 37
	pixel_y = 64

/datum/unit_test/brandish_image_origins/Run()
	var/obj/structure/necropolis_arch/arch = allocate(/obj/structure/necropolis_arch)
	TEST_ASSERT_EQUAL(arch.pixel_x, 0, "The arch's canvas origin leaves world X")
	TEST_ASSERT_EQUAL(arch.pixel_y, 24, "The arch retains its extra world elevation")
	TEST_ASSERT_EQUAL(arch.pixel_w, -64, "The arch has a centred screen origin")
	TEST_ASSERT_EQUAL(arch.pixel_z, -64, "The arch has a centred screen origin")
	var/obj/machinery/duct/multilayered/duct = allocate(/obj/machinery/duct/multilayered)
	TEST_ASSERT_EQUAL(duct.pixel_x, 1, "The manifold retains its one-pixel world placement")
	TEST_ASSERT_EQUAL(duct.pixel_y, 1, "The manifold retains its one-pixel world placement")
	TEST_ASSERT_EQUAL(duct.pixel_w, -16, "The manifold's canvas origin stays on screen")
	var/obj/structure/sign/directions/science/brandish_origin_probe/sign = allocate(/obj/structure/sign/directions/science/brandish_origin_probe)
	TEST_ASSERT_EQUAL(sign.pixel_x, 32, "Whole tiles still locate a wall label")
	TEST_ASSERT_EQUAL(sign.pixel_y, 64, "Whole tiles still locate a wall label")
	TEST_ASSERT_EQUAL(sign.pixel_w, 5, "Only the sub-tile stack offset moves to screen space")
	var/obj/structure/flora/tree/palm/palm = allocate(/obj/structure/flora/tree/palm)
	TEST_ASSERT_EQUAL(palm.pixel_x, 0, "Palm initialization keeps its deliberate reset")
	TEST_ASSERT_EQUAL(palm.pixel_w, 0, "Palm initialization keeps its deliberate reset")
	TEST_ASSERT_EQUAL(palm.brandish_origin_screen_x, initial(palm.pixel_x), "Palm origin bookkeeping still precedes its reset")

/datum/unit_test/brandish_image_world/Run()
	var/obj/structure/shipping_container/container = allocate(/obj/structure/shipping_container)
	TEST_ASSERT_EQUAL(container.brandish_icon_mode, BRANDISH_MODE_GROUP_ROTATE, "World geometry is selected at initialization")
	TEST_ASSERT(istype(container.brandish_image_projector, /datum/brandish_image_projector/group), "The instance owns its geometry projector")
	TEST_ASSERT_EQUAL(container.brandish_image, /datum/brandish_image/group_rotate, "Setup leaves the type policy intact")
	var/obj/item/sticker/sticker = allocate(/obj/item/sticker)
	sticker.stick_to(container, 27, 20)
	TEST_ASSERT(sticker in container.vis_contents, "The sticker stays attached to the container")
	TEST_ASSERT_EQUAL(sticker.pixel_x, 11, "The attachment stores horizontal displacement in world pixels")
	TEST_ASSERT_EQUAL(sticker.pixel_y, 4, "The attachment stores vertical displacement in world pixels")
	TEST_ASSERT_EQUAL(sticker.pixel_w, 0, "The sticker has no fixed horizontal screen offset")
	TEST_ASSERT_EQUAL(sticker.pixel_z, 0, "The sticker has no fixed vertical screen offset")

/datum/unit_test/brandish_optional_assets/Run()
	var/datum/brandish_asset_registry/registry = allocate(/datum/brandish_asset_registry)
	var/source = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	TEST_ASSERT_NULL(registry.asset_for('icons/blanks/32x32.dmi', BRANDISH_ASSET_VIEW_GATES), "Unlisted artwork keeps its native presentation")
	TEST_ASSERT_EQUAL(registry.is_enabled(), registry.has_catalog(), "An initialized catalog exposes its availability")
	var/list/masks = registry.asset_for(source, BRANDISH_ASSET_FOOTPRINT)
	if(masks)
		for(var/facing in GLOB.cardinals)
			TEST_ASSERT_EQUAL(registry.optional_icon(source, BRANDISH_ASSET_FOOTPRINT, facing), masks["[facing]"], "Optional artwork selects the requested native bank")
		TEST_ASSERT_EQUAL(registry.optional_icon(source, BRANDISH_ASSET_FOOTPRINT, NONE), source, "Undefined directions preserve the original artwork")
	else
		TEST_ASSERT_NULL(registry.optional_icon(source, BRANDISH_ASSET_FOOTPRINT, NORTH), "A missing family uses the native fallback")

/datum/brandish_image_projector/brandish_cache_probe
	var/reattach_calls = 0

/datum/brandish_image_projector/brandish_cache_probe/show_layers()
	reattach_calls++
	return ..()

/datum/unit_test/brandish_projection_cache/Run()
	if(!GLOB.brandish_assets.asset_for('icons/obj/machines/gateway.dmi', BRANDISH_ASSET_VIEW_GATES))
		return
	var/obj/effect/anchor = allocate(/obj/effect)
	anchor.icon = 'icons/obj/machines/gateway.dmi'
	anchor.icon_state = "off"
	var/datum/brandish_image_projector/brandish_cache_probe/projector = allocate(/datum/brandish_image_projector/brandish_cache_probe, anchor)
	anchor.brandish_image_projector = projector
	TEST_ASSERT(projector.refresh(), "The first draw attaches the view gates")
	TEST_ASSERT(!projector.refresh(), "Unchanged inputs hit the projection cache")
	TEST_ASSERT_EQUAL(projector.reattach_calls, 1, "A cache hit never reattaches the four images")
	anchor.update_appearance(UPDATE_NAME | UPDATE_DESC)
	TEST_ASSERT_EQUAL(projector.reattach_calls, 1, "Text-only updates leave the projection attached")
	var/image/unrelated = image('icons/blanks/32x32.dmi')
	anchor.add_overlay(unrelated)
	anchor.cut_overlay(unrelated)
	TEST_ASSERT(!projector.layers_dirty, "Removing an unrelated overlay keeps the cached projection valid")
	anchor.cut_overlay(projector.layers[1])
	TEST_ASSERT(projector.layers_dirty, "Removing an owned layer invalidates the projection")
	anchor.icon_state = "on"
	anchor.update_appearance()
	TEST_ASSERT_EQUAL(projector.reattach_calls, 2, "State and overlay changes attach once per update")
	TEST_ASSERT_EQUAL(length(anchor.overlays), 4, "The update restores all four layers")
	var/matrix/transform = matrix()
	transform.Turn(17)
	anchor.transform = transform
	anchor.update_appearance(UPDATE_ICON)
	TEST_ASSERT_EQUAL(projector.reattach_calls, 3, "Transform-only updates invalidate the projection")
	anchor.update_appearance()
	TEST_ASSERT_EQUAL(projector.reattach_calls, 3, "An unchanged appearance keeps its projection attached")

/datum/brandish_image_projector/group/brandish_cache_probe
	var/reattach_calls = 0

/datum/brandish_image_projector/group/brandish_cache_probe/show_layers()
	reattach_calls++
	return ..()

/obj/machinery/atmospherics/components/unary/rbmk/core/brandish_overlay_probe/update_pipenets()
	// This fixture draws the reactor independently of its three pipe ports.
	return

/datum/unit_test/brandish_group_managed_overlays/Run()
	if(!GLOB.brandish_assets.has_catalog())
		return
	var/obj/machinery/atmospherics/components/unary/rbmk/core/reactor = allocate(/obj/machinery/atmospherics/components/unary/rbmk/core/brandish_overlay_probe)
	QDEL_NULL(reactor.brandish_image_projector)
	reactor.icon = initial(reactor.icon)
	var/datum/brandish_image_projector/group/brandish_cache_probe/projector = allocate(/datum/brandish_image_projector/group/brandish_cache_probe, reactor)
	reactor.brandish_image_projector = projector
	reactor.update_appearance()
	reactor.update_appearance()
	TEST_ASSERT_EQUAL(projector.reattach_calls, 1, "An unchanged RBMK appearance must keep its body layers attached")
	check_order(reactor, projector)
	reactor.cut_overlays()
	reactor.update_appearance()
	TEST_ASSERT_EQUAL(projector.reattach_calls, 2, "Clearing all overlays rebuilds the body once")
	check_order(reactor, projector)
	reactor.bound_width += ICON_SIZE_X
	reactor.setDir(EAST)
	TEST_ASSERT_EQUAL(projector.reattach_calls, 3, "Turning with a new footprint refreshes the group")
	check_order(reactor, projector)

/datum/unit_test/brandish_group_managed_overlays/proc/check_order(atom/target, datum/brandish_image_projector/projector)
	var/mutable_appearance/top = target.managed_overlays
	var/top_index = target.overlays.Find(top.appearance)
	TEST_ASSERT(top_index, "The reactor top is present")
	for(var/image/body_layer as anything in projector.layers)
		var/body_index = target.overlays.Find(body_layer.appearance)
		TEST_ASSERT(body_index && body_index < top_index, "Each view gate for the body precedes the reactor top")

/// Collision geometry and ordinary overlays must survive an appearance copy.
/datum/unit_test/brandish_gateway_art/Run()
	var/obj/machinery/gateway/gate = allocate(/obj/machinery/gateway)
	TEST_ASSERT(gate.has_rotated_brandish_surface(), "The gateway remains a world-axis attachment surface")
	TEST_ASSERT_EQUAL(gate.get_cached_width(), 96, "HUD sizing uses the 96px source")
	TEST_ASSERT_EQUAL(gate.get_cached_height(), 96, "HUD sizing uses the 96px source")
	if(!GLOB.brandish_assets.supports('icons/obj/machines/gateway.dmi', BRANDISH_ASSET_VIEW_GATES))
		return
	TEST_ASSERT_EQUAL(gate.bound_width, 96, "Gateway collision width remains three tiles")
	TEST_ASSERT_EQUAL(gate.bound_height, 64, "Gateway entry row remains outside its two-tile collision box")
	TEST_ASSERT_EQUAL(gate.bound_x, -32, "Gateway collision still extends west")
	TEST_ASSERT_EQUAL(length(gate.vis_contents), 0, "Gateway art must survive z-mimic without visual contents")
	TEST_ASSERT_EQUAL(gate.bound_y, 0, "Gateway collision still starts at the anchor row")
	TEST_ASSERT_EQUAL(gate.pixel_x, -32, "The group projector retains the native canvas origin")
	TEST_ASSERT_EQUAL(gate.pixel_y, -32, "The group projector retains the native canvas origin")
	// Final screen positions from the former portal projection, including its
	// screen origin and corrections for the native collision bounds.
	var/list/screen_origins = list(TEXT_NORTH = list(-32, -32), TEXT_EAST = list(-32, 0), TEXT_SOUTH = list(-32, 0), TEXT_WEST = list(-64, 0))
	for(var/state in list(FALSE, TRUE))
		gate.active = state
		gate.update_appearance()
		TEST_ASSERT_EQUAL(length(gate.overlays), 4, "Each viewer selects one native view gate")
		var/index = 0
		for(var/facing in GLOB.cardinals)
			var/image/drawing = gate.overlays[++index]
			var/list/expected = screen_origins["[facing]"]
			var/list/world_origin = camera_world_to_screen(gate.pixel_x, gate.pixel_y, facing)
			var/matrix/rotation = matrix()
			rotation.Turn(-dir2angle(facing))
			TEST_ASSERT_EQUAL(drawing.icon_state, state ? "on@2" : "off@2", "The attached drawing follows activation")
			TEST_ASSERT_EQUAL(drawing.transform.a, rotation.a, "Same gateway rotation at [facing]")
			TEST_ASSERT_EQUAL(drawing.transform.b, rotation.b, "Same gateway rotation at [facing]")
			TEST_ASSERT_EQUAL(drawing.transform.d, rotation.d, "Same gateway rotation at [facing]")
			TEST_ASSERT_EQUAL(drawing.transform.e, rotation.e, "Same gateway rotation at [facing]")
			TEST_ASSERT_EQUAL(world_origin[1] + drawing.transform.c, expected[1], "Same horizontal screen origin at [facing]")
			TEST_ASSERT_EQUAL(world_origin[2] + drawing.transform.f, expected[2], "Same vertical screen origin at [facing]")
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
	var/datum/brandish_image_projector/beam/projection = segment.brandish_image_projector
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
	TEST_ASSERT_EQUAL(initial(wall_path:brandish_icon_mode), BRANDISH_MODE_ROTATE, "Fixed walls use the same world geometry policy")
	TEST_ASSERT_EQUAL(initial(generator_path:brandish_icon_mode), BRANDISH_MODE_ROTATE, "Every gravity-generator part uses world geometry")
	if(!GLOB.brandish_assets.supports('icons/obj/plumbing/fluid_ducts.dmi', BRANDISH_MODE_ROTATE))
		return
	var/obj/machinery/duct/duct = allocate(/obj/machinery/duct, run_loc_floor_bottom_left)
	duct.connects = NORTH | EAST
	duct.update_icon()
	var/connections = duct.connects
	var/physical_dir = duct.dir
	APPLY_BRANDISH_ICON(duct)
	TEST_ASSERT_EQUAL(duct.connects, connections, "Rendering must not mutate duct connection bits")
	TEST_ASSERT_EQUAL(duct.dir, physical_dir, "The fixed-state overlay must not mutate physical direction")
	TEST_ASSERT_EQUAL(duct.brandish_connection_image?.dir, NORTH, "State topology uses an explicit world direction")
	TEST_ASSERT_NULL(duct.icon, "The topology overlay replaces the native base")
	var/mob/dead/observer/recipient = allocate(/mob/dead/observer)
	var/image/native_preview = image(duct.brandish_connection_icon, icon_state = duct.icon_state)
	var/expected = icon2html(native_preview, recipient, sourceonly = TRUE)
	TEST_ASSERT(expected, "The native sheet produces a preview URL")
	TEST_ASSERT_EQUAL(icon2html(duct, recipient, sourceonly = TRUE), expected, "A duct without a base icon previews its connected state")
	GLOB.brandish_assets.enabled = FALSE
	duct.update_icon()
	var/native_icon = duct.icon
	var/retained_overlay = duct.brandish_connection_image
	GLOB.brandish_assets.enabled = TRUE
	duct.update_icon()
	TEST_ASSERT_EQUAL(native_icon, duct.brandish_connection_icon, "Losing the generated bank restores the native duct sheet")
	TEST_ASSERT_NULL(retained_overlay, "The old generated bank is removed in fallback mode")
	TEST_ASSERT_NOTNULL(duct.brandish_connection_image, "Returning to the catalog restores the generated duct overlay")

/datum/unit_test/brandish_pipe_connection_cache/Run()
	if(!GLOB.brandish_assets.has_catalog())
		return
	var/obj/machinery/atmospherics/pipe/pipe = allocate(/obj/machinery/atmospherics/pipe)
	var/obj/machinery/atmospherics/pipe/neighbor = allocate(/obj/machinery/atmospherics/pipe, get_step(pipe, EAST))
	pipe.device_type = BINARY
	pipe.initialize_directions = EAST | WEST
	pipe.nodes = list(neighbor, null)
	neighbor.device_type = BINARY
	neighbor.initialize_directions = EAST | WEST
	neighbor.nodes = list(pipe, null)
	pipe.update_icon()
	var/image/connected = pipe.brandish_connection_image
	TEST_ASSERT_NOTNULL(connected, "A connected bitmask pipe draws a shared overlay")
	var/image/marker = image('icons/blanks/32x32.dmi', dir = NORTH)
	pipe.add_overlay(marker)
	pipe.update_icon()
	var/geometry_index = pipe.overlays.Find(connected.appearance)
	TEST_ASSERT(geometry_index && geometry_index < pipe.overlays.Find(marker.appearance), "An unchanged pipe does not reattach its connection overlay")
	pipe.nullify_node(1)
	pipe.update_icon()
	TEST_ASSERT(pipe.brandish_connection_image && pipe.brandish_connection_image != connected, "Disconnecting replaces the topology overlay")
	TEST_ASSERT(!(connected.appearance in pipe.overlays), "Disconnecting removes the old connected state")
	pipe.nodes[1] = neighbor
	neighbor.nodes[1] = pipe
	pipe.update_icon()
	TEST_ASSERT_EQUAL(pipe.brandish_connection_image, connected, "Reconnecting reuses the cached connected state")
	pipe.initialize_directions = EAST
	pipe.update_icon()
	TEST_ASSERT_NULL(pipe.brandish_connection_image, "A single connection retains its native rendering path")
	TEST_ASSERT(!(connected.appearance in pipe.overlays), "Leaving the connection sheet removes its overlay")
	qdel(pipe)
	TEST_ASSERT_NULL(neighbor.nodes[1], "Deleting the pipe clears the neighbor's connection")
