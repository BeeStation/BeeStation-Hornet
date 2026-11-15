/datum/unit_test/brandish_cogbar/Run()
	var/mob/living/carbon/human/consistent/worker = allocate(/mob/living/carbon/human/consistent)
	var/obj/effect/overlay/vis/unrelated = SSvis_overlays.add_vis_overlay(worker, icon = 'icons/blanks/32x32.dmi', iconstate = "nothing", unique = TRUE)
	var/datum/cogbar/first = allocate(/datum/cogbar, worker)
	var/datum/cogbar/second = allocate(/datum/cogbar, worker)
	for(var/facing in GLOB.cardinals)
		worker.setDir(facing)
		TEST_ASSERT_EQUAL(first.cog.pixel_y, 0, "The busy indicator must not move north in world space")
		TEST_ASSERT_EQUAL(first.cog.pixel_z, ICON_SIZE_Y, "The busy indicator stays above the sprite")
	qdel(first)
	TEST_ASSERT(second.cog in worker.vis_contents, "Ending one action must preserve another busy indicator")
	TEST_ASSERT(unrelated in worker.vis_contents, "Ending an action must preserve unrelated visual overlays")

/datum/unit_test/brandish_coordinates/Run()
	for(var/facing in GLOB.cardinals)
		for(var/x in list(-64, -1, 0, 7, 32))
			for(var/y in list(-32, 0, 5, 64))
				var/list/screen = camera_world_to_screen(x, y, facing)
				var/list/restored = camera_screen_to_world(screen[1], screen[2], facing)
				TEST_ASSERT_EQUAL(restored[1], x, "World X survives round trip at [facing]")
				TEST_ASSERT_EQUAL(restored[2], y, "World Y survives round trip at [facing]")
	var/list/east = camera_world_to_screen(32, 64, EAST)
	TEST_ASSERT_EQUAL(east[1], -64, "East-facing camera rotates world Y to negative screen X")
	TEST_ASSERT_EQUAL(east[2], 32, "East-facing camera rotates world X to screen Y")

/datum/unit_test/brandish_registry_fallback/Run()
	var/datum/brandish_asset_registry/registry = allocate(/datum/brandish_asset_registry)
	registry.aliases = list()
	var/source = 'icons/obj/solar.dmi'
	for(var/kind in list("surface", "smooth", "corner", "basis", "footprint"))
		TEST_ASSERT_EQUAL(registry.icon_for(source, kind, NORTH), source, "Missing [kind] preserves original resource")
		TEST_ASSERT(!registry.supports(source, kind), "Missing [kind] must not advertise support")
	registry.aliases[source] = list("source" = source, "surface" = list("1" = 'icons/obj/fluff.dmi'))
	registry.configure(FALSE)
	TEST_ASSERT_EQUAL(registry.icon_for(source, "surface", NORTH), source, "Disabled catalog preserves original resource")
	TEST_ASSERT(!registry.supports(source, "surface"), "Disabled catalog must not advertise support")

/datum/unit_test/brandish_compact_surface_fallback/Run()
	var/datum/brandish_asset_registry/runtime/registry = allocate(/datum/brandish_asset_registry/runtime)
	var/source = 'icons/obj/decals.dmi'
	var/bank = 'icons/obj/fluff.dmi'
	var/list/entry = list("source" = source, "surface" = list("1" = bank), "surfaceStates" = list("map-left" = TRUE))
	registry.aliases = list()
	registry.aliases[source] = entry
	registry.aliases[bank] = entry
	TEST_ASSERT_EQUAL(registry.icon_for(source, "surface", NORTH, state = "map-left"), bank, "Selected geometry uses its compact bank")
	TEST_ASSERT_EQUAL(registry.icon_for(source, "surface", NORTH, state = "frame-empty"), source, "Unselected upright state uses the source")
	TEST_ASSERT_EQUAL(registry.icon_for(bank, "surface", NORTH, state = "frame-empty"), source, "Changing out of a compact state restores the source")
	TEST_ASSERT_EQUAL(registry.source_for(bank), source, "Compact bank retains its original identity")
	TEST_ASSERT_EQUAL(registry.icon_for(source, "surface", NORTH), source, "Calls without a state cannot select an incomplete bank")
	var/obj/probe = allocate(/obj)
	probe.brandish_icon_mode = "surface"
	probe.icon = bank
	probe.icon_state = "frame-empty"
	probe.dir = NORTH
	var/datum/brandish_asset_registry/runtime/previous_registry = GLOB.brandish_assets
	GLOB.brandish_assets = registry
	APPLY_BRANDISH_ICON(probe)
	GLOB.brandish_assets = previous_registry
	TEST_ASSERT_EQUAL(probe.icon, source, "Atom rebinding restores an omitted state's source artwork")

/datum/unit_test/brandish_camera_composition/Run()
	var/datum/client_camera_state/state = allocate(/datum/client_camera_state)
	var/datum/camera_source = allocate(/datum)
	var/datum/zoom_source = allocate(/datum)
	state.requested_view = "19x15"
	state.base_x = 3
	state.base_z = -2
	state.set_effect(camera_source, null, 0, 0, TRUE, 0, 64)
	state.set_effect(zoom_source, "21x17", 32, 0, TRUE, 0, 0)
	var/list/active = state.resolve(TRUE, TRUE)
	TEST_ASSERT_EQUAL(active[1], "17x17", "Active view uses the smaller dimension")
	TEST_ASSERT_EQUAL(active[2], 35, "Independent offsets compose")
	TEST_ASSERT_EQUAL(active[5], 62, "Look-ahead preserves the base offset")
	var/list/remote = state.resolve(FALSE, TRUE)
	TEST_ASSERT_EQUAL(remote[1], "19x15", "Remote eyes exclude local view effects")
	TEST_ASSERT_EQUAL(remote[5], -2, "Remote eyes exclude local offsets")
	state.remove_effect(camera_source)
	var/list/zoomed = state.resolve(TRUE, FALSE)
	TEST_ASSERT_EQUAL(zoomed[1], "21x17", "Removing camera preserves the later zoom")
	state.remove_effect(zoom_source)
	var/list/restored = state.resolve(TRUE, FALSE)
	TEST_ASSERT_EQUAL(restored[1], "19x15", "Removing all effects restores requested view")
	TEST_ASSERT_EQUAL(restored[2], 3, "Removing all effects restores base X")
	TEST_ASSERT_EQUAL(restored[5], -2, "Removing all effects restores base Z")

/datum/unit_test/brandish_keybindings/Run()
	var/list/bindings = list("move_north" = list("Z"), "move_south" = list(), "move_west" = list("Q"), "move_east" = list("E"))
	TEST_ASSERT(migrate_brandish_keybindings(bindings), "Existing accounts acquire missing Brandish actions")
	TEST_ASSERT_EQUAL(bindings["brandish_forward"][1], "Z", "Saved forward binding is migrated")
	TEST_ASSERT_EQUAL(length(bindings["brandish_backward"]), 0, "Deliberately unbound movement stays unbound")
	TEST_ASSERT_EQUAL(bindings["brandish_turn_left"][1], "Q", "Saved left binding is migrated")
	TEST_ASSERT_EQUAL(bindings["brandish_turn_right"][1], "E", "Saved right binding is migrated")
	TEST_ASSERT_EQUAL(bindings["brandish_strafe_left"][1], "ShiftA", "Missing strafe gets its default")
	bindings["brandish_forward"] = list("T")
	TEST_ASSERT(!migrate_brandish_keybindings(bindings), "Migration never overwrites a configured Brandish action")
	TEST_ASSERT_EQUAL(bindings["brandish_forward"][1], "T", "Configured forward key survives another load")
	TEST_ASSERT(!brandish_keybind_conflicts(bindings, "brandish_forward", list("Z")), "Sharing ordinary movement keys is allowed")
	TEST_ASSERT(brandish_keybind_conflicts(bindings, "brandish_forward", list("Q")), "Two Brandish actions cannot share a key")
	var/list/by_key = list("A" = list("move_west", "brandish_turn_left"), "ShiftA" = list("brandish_strafe_left"))
	TEST_ASSERT_EQUAL(brandish_action_for_key(by_key, "A", "ShiftA"), "brandish_strafe_left", "Explicit strafe wins over ordinary/any-modifier movement")
	TEST_ASSERT_EQUAL(keybinding_base_key("ShiftA"), "A", "A combo release resolves to the held physical key")
	TEST_ASSERT_EQUAL(keybinding_base_key("AltCtrlShiftT"), "T", "Arbitrary rebound combinations retain their physical key")
	TEST_ASSERT_EQUAL(keybinding_base_key("Shift"), "Shift", "A standalone modifier remains a physical key")
	TEST_ASSERT_EQUAL(brandish_action_for_key(by_key, "A", "CtrlA"), "brandish_turn_left", "Facing-lock modifier retains the unmodified action")
	TEST_ASSERT(isnull(brandish_action_for_key(by_key, "Z", "Z")), "Unbound keys fall through")
	var/list/fresh = list()
	TEST_ASSERT(migrate_brandish_keybindings(fresh), "Empty data acquires defaults")
	TEST_ASSERT_EQUAL(fresh["brandish_forward"][1], "W", "New accounts get W forward")
	TEST_ASSERT_EQUAL(fresh["brandish_turn_right"][1], "D", "New accounts get D right")

/datum/unit_test/brandish_painting_offsets/Run()
	var/obj/item/canvas/canvas = allocate(/obj/item/canvas)
	TEST_ASSERT_EQUAL(canvas.pixel_x, 0, "Canvas centering is not a world X offset")
	TEST_ASSERT_EQUAL(canvas.pixel_y, 0, "Canvas centering is not a world Y offset")
	TEST_ASSERT_EQUAL(canvas.pixel_w, 10, "Canvas centers in screen X")
	TEST_ASSERT_EQUAL(canvas.pixel_z, 9, "Canvas centers in screen Y")
	// A frame's one-tile map offset must survive the canvas composition.
	var/obj/structure/sign/painting/frame = allocate(/obj/structure/sign/painting)
	frame.pixel_y = -32
	canvas.generated_icon = icon('icons/obj/artstuff.dmi', "11x11")
	frame.current_canvas = canvas
	var/list/parts = frame.update_overlays()
	TEST_ASSERT_EQUAL(frame.pixel_y, -32, "Wall placement remains in world space")
	var/mutable_appearance/art = parts[length(parts) - 1]
	var/mutable_appearance/border = parts[length(parts)]
	TEST_ASSERT_EQUAL(art.pixel_x, 0, "Runtime art has no rotating map offset")
	TEST_ASSERT_EQUAL(art.pixel_w, canvas.framed_offset_x, "Art uses screen X inside the frame")
	TEST_ASSERT_EQUAL(border.pixel_z, canvas.framed_offset_y - 1, "Inner border shares the art's screen Y basis")

/datum/unit_test/brandish_overhead_offsets/Run()
	var/obj/probe = allocate(/obj)
	probe.icon = 'icons/mob/talk.dmi' // 64x64 upright artwork
	probe.pixel_x = -16
	probe.pixel_y = -16
	var/list/before = probe.get_oversized_icon_offsets()
	probe.brandish_screen_origin(-16, -16)
	var/list/after = probe.get_oversized_icon_offsets()
	TEST_ASSERT_EQUAL(after["x"], before["x"], "Overhead centering survives migration to a screen X origin")
	TEST_ASSERT_EQUAL(after["y"], before["y"], "Overhead height survives migration to a screen Y origin")

/datum/unit_test/brandish_ground_decal_transfer/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/destination = get_step(start, EAST)
	var/resource = 'icons/turf/decals.dmi'
	start.add_ground_decal(resource, "warningline", SOUTH)
	SEND_SIGNAL(start, COMSIG_TURF_AFTER_SHUTTLE_MOVE, destination)
	destination.setDir(EAST)
	var/found = FALSE
	for(var/image/part as anything in destination.overlays)
		if(GLOB.brandish_assets.source_for(part.icon) != resource)
			continue
		found = TRUE
		TEST_ASSERT_EQUAL(part.dir, EAST, "Transferred floor marking follows physical shuttle rotation")
		TEST_ASSERT_EQUAL(part.icon, GLOB.brandish_assets.icon_for(resource, "surface", EAST, state = "warningline"), "Transferred marking retains the directional bank")
	TEST_ASSERT(found, "Ground decal survives the shuttle transfer signal")
	destination.RemoveElement(/datum/element/decal/ground, resource, "warningline", EAST, FALSE, null, TURF_LAYER, null, 255, TRUE, 0, 0)
