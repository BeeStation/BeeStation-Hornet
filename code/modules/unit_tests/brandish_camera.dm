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

/datum/unit_test/brandish_view_dimensions/Run()
	var/datum/client_camera_state/state = allocate(/datum/client_camera_state)
	state.requested_view = "17x15"
	var/datum/zoom = allocate(/datum)
	for(var/facing in GLOB.cardinals)
		var/expected = (facing == EAST || facing == WEST) ? "15x17" : "17x15"
		var/list/resolved = state.resolve(TRUE, FALSE)
		TEST_ASSERT_EQUAL(resolved[1], "17x15", "Composition retains the logical view at [facing]")
		TEST_ASSERT_EQUAL(camera_view_for_direction(resolved[1], facing), expected, "Only quarter turns exchange the applied axes")
		TEST_ASSERT_EQUAL(camera_view_for_direction(expected, facing), "17x15", "HUD dimensions recover the screen axes")
		TEST_ASSERT_EQUAL(camera_view_for_direction("15x15", facing), "15x15", "Square string views are unchanged")
		TEST_ASSERT_EQUAL(camera_view_for_direction(7, facing), 7, "Numeric square views are unchanged")
		var/list/brandish = state.resolve(TRUE, TRUE)
		TEST_ASSERT_EQUAL(camera_view_for_direction(brandish[1], facing), "15x15", "Brandish remains square")
		state.set_effect(zoom, "23x19", 0, 0, TRUE, 0, 0)
		var/list/zoomed = state.resolve(TRUE, FALSE)
		TEST_ASSERT_EQUAL(zoomed[1], "23x19", "Zoom requests retain their logical axes")
		TEST_ASSERT_EQUAL(camera_view_for_direction(zoomed[1], facing), (facing == EAST || facing == WEST) ? "19x23" : "23x19", "Zoom projects once at application")
		var/list/square_zoom = state.resolve(TRUE, TRUE)
		TEST_ASSERT_EQUAL(square_zoom[1], "19x19", "Even a rectangular zoom remains square under Brandish")
		state.remove_effect(zoom)

/// A socket-free viewer. Dispatch policy through the real client proc while
/// recording native direction/UI calls, which require a connected BYOND client.
/datum/brandish_test_viewer
	var/mob/mob
	var/atom/eye
	var/view = "17x15"
	var/pixel_x = 0
	var/pixel_y = 0
	var/pixel_w = 0
	var/pixel_z = 0
	var/ckey = "brandish_unit_test"
	var/dir = NORTH
	var/datum/brandish_camera/brandish_camera
	var/datum/brandish_observe_mirror/brandish_mirror
	var/brandish_disconnecting = FALSE
	var/brandish_camera_suppressed = FALSE
	var/local_eye = TRUE
	var/list/keys_held = list()
	var/list/key_combos_held = list()
	var/next_move_dir_add = NONE
	var/next_move_dir_sub = NONE

/datum/brandish_test_viewer/proc/setDir(newdir)
	dir = newdir

/datum/brandish_test_viewer/proc/screen_view()
	return call(src, /client/proc/screen_view)()

/datum/brandish_test_viewer/proc/camera_click_vector(list/modifiers, atom/origin)
	return call(src, /client/proc/camera_click_vector)(modifiers, origin)

/datum/unit_test/brandish_rectangular_clicks/Run()
	var/datum/brandish_test_viewer/viewer = allocate(/datum/brandish_test_viewer)
	var/mob/body = allocate(/mob/living/carbon/human/consistent)
	viewer.mob = body
	viewer.eye = body
	for(var/facing in GLOB.cardinals)
		viewer.dir = facing
		viewer.view = camera_view_for_direction("17x15", facing)
		var/list/center = viewer.camera_click_vector(list(SCREEN_LOC = "9:16,8:16"), body)
		TEST_ASSERT_EQUAL(center[1], 0, "Screen center stays on the eye's world X at [facing]")
		TEST_ASSERT_EQUAL(center[2], 0, "Screen center stays on the eye's world Y at [facing]")
		var/list/click = list(SCREEN_LOC = "10:16,8:16")
		var/list/vector = viewer.camera_click_vector(click, body)
		var/list/expected = camera_screen_to_world(ICON_SIZE_X, 0, facing)
		TEST_ASSERT_EQUAL(vector[1], expected[1], "Rightward click projects to world X at [facing]")
		TEST_ASSERT_EQUAL(vector[2], expected[2], "Rightward click projects to world Y at [facing]")
		var/turf/origin = get_turf(body)
		var/turf/caught = parse_caught_click_modifiers(click, origin, viewer)
		TEST_ASSERT_EQUAL(caught.x, origin.x + expected[1] / ICON_SIZE_X, "Forwarded click finds the projected turf X")
		TEST_ASSERT_EQUAL(caught.y, origin.y + expected[2] / ICON_SIZE_Y, "Forwarded click finds the projected turf Y")
		TEST_ASSERT_EQUAL(click[ICON_X], "16", "Forwarded sprite-local X remains screen-relative")
		TEST_ASSERT_EQUAL(click[ICON_Y], "16", "Forwarded sprite-local Y remains screen-relative")

/datum/brandish_test_viewer/proc/apply_default_client_dir()
	call(src, /client/proc/apply_default_client_dir)()

/datum/brandish_test_viewer/proc/brandish_has_local_eye()
	return local_eye

/datum/brandish_test_viewer/proc/clear_camera_effect(datum/source)
	return

/datum/brandish_test_viewer/proc/update_special_keybinds()
	return

/datum/brandish_test_viewer/proc/update_macro_mode()
	return

/// Skip native view initialization; use the real availability/intro/teardown.
/datum/brandish_camera/policy_test
	var/openings = 0

/datum/brandish_camera/policy_test/New(datum/brandish_test_viewer/viewer)
	owner = viewer
	body = viewer.mob
	previous_body_dir = body.dir
	viewer.brandish_camera = src

/datum/brandish_camera/policy_test/ui_interact(mob/user, datum/tgui/ui)
	openings++

/datum/unit_test/brandish_camera_policy
	abstract_type = /datum/unit_test/brandish_camera_policy
	var/saved_default
	var/saved_enabled
	var/saved_assets_enabled
	var/list/saved_intro

/datum/unit_test/brandish_camera_policy/New()
	. = ..()
	saved_default = GLOB.default_client_dir
	saved_enabled = CONFIG_GET(flag/brandish_camera)
	saved_assets_enabled = GLOB.brandish_assets.enabled
	saved_intro = GLOB.brandish_intro_shown.Copy()
	set_brandish_perspective(FALSE)
	set_brandish_perspective(TRUE)
	GLOB.brandish_assets.enabled = TRUE

/datum/unit_test/brandish_camera_policy/Destroy()
	. = ..()
	set_default_client_dir(saved_default)
	set_brandish_perspective(saved_enabled)
	GLOB.brandish_assets.enabled = saved_assets_enabled
	GLOB.brandish_intro_shown = saved_intro

/datum/unit_test/brandish_camera_policy/default_direction/Run()
	var/datum/brandish_test_viewer/viewer = allocate(/datum/brandish_test_viewer)
	viewer.mob = allocate(/mob/living/carbon/human/consistent)
	for(var/facing in GLOB.cardinals)
		TEST_ASSERT(set_default_client_dir(facing), "Cardinal default is accepted")
		TEST_ASSERT_EQUAL(GLOB.default_client_dir, facing, "Default persists for later logins")
		viewer.apply_default_client_dir()
		TEST_ASSERT_EQUAL(viewer.dir, facing, "An unowned view takes the current default")
	for(var/invalid in list(NONE, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST, 16, -1, 1.5, "NORTH", null))
		var/before = GLOB.default_client_dir
		TEST_ASSERT(!set_default_client_dir(invalid), "Non-cardinal default is rejected: [invalid]")
		TEST_ASSERT_EQUAL(GLOB.default_client_dir, before, "Rejected input preserves the previous default")
	var/datum/brandish_camera/camera = allocate(/datum/brandish_camera/policy_test, viewer)
	viewer.dir = EAST
	set_default_client_dir(SOUTH)
	viewer.apply_default_client_dir()
	TEST_ASSERT_EQUAL(viewer.dir, EAST, "Active camera retains ownership when default changes")
	qdel(camera)
	TEST_ASSERT_EQUAL(viewer.dir, SOUTH, "Camera teardown uses the latest default rather than its original heading")
	viewer.brandish_mirror = allocate(/datum/brandish_observe_mirror)
	viewer.dir = EAST
	set_default_client_dir(WEST)
	viewer.apply_default_client_dir()
	TEST_ASSERT_EQUAL(viewer.dir, EAST, "An Observe mirror retains its watched heading")
	call(viewer, /client/proc/clear_brandish_observe)()
	TEST_ASSERT_EQUAL(viewer.dir, WEST, "Ending Observe restores the latest default")

/datum/unit_test/brandish_camera_policy/guide/Run()
	var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
	var/datum/brandish_test_viewer/viewer = allocate(/datum/brandish_test_viewer)
	viewer.mob = body
	var/datum/brandish_camera/policy_test/camera = allocate(/datum/brandish_camera/policy_test, viewer)
	camera.show_intro()
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "An eligible player sees the intro once per activation")
	qdel(camera)
	camera = allocate(/datum/brandish_camera/policy_test, viewer)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 0, "Recreating the camera does not repeat the guide")
	// A new socket with the same ckey shares the activation acknowledgement.
	var/datum/brandish_test_viewer/reconnected = allocate(/datum/brandish_test_viewer)
	reconnected.mob = body
	qdel(camera)
	camera = allocate(/datum/brandish_camera/policy_test, reconnected)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 0, "Reconnecting does not repeat the guide")
	set_brandish_perspective(FALSE)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 0, "A callback after global disable cannot open the guide")
	set_brandish_perspective(TRUE)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "Off then on allows the same player to see the guide again")
	set_brandish_perspective(TRUE)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "An unchanged enabled flag preserves acknowledgement")
	for(var/body_type in list(/mob/living/silicon/robot, /mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/brain, /mob/living/simple_animal/shade, /mob/dead/observer, /mob/dead/new_player))
		var/mob/excluded = allocate(body_type)
		TEST_ASSERT(!excluded.brandish_perspective_allowed(), "[body_type] is ineligible")
		reconnected.mob = excluded
		camera.body = excluded
		GLOB.brandish_intro_shown.Cut()
		camera.show_intro()
		TEST_ASSERT_EQUAL(camera.openings, 1, "A delayed callback cannot open for [body_type]")
		TEST_ASSERT(!length(GLOB.brandish_intro_shown), "An excluded body is not marked as having seen the guide")
	reconnected.mob = body
	camera.body = body
	body.stat = DEAD
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "Dying during the delay prevents the guide")
	body.stat = CONSCIOUS
	var/obj/item/container = allocate(/obj/item)
	body.forceMove(container)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "Moving inside an item during the delay prevents the guide")
	body.forceMove(run_loc_floor_bottom_left)
	reconnected.mob = allocate(/mob/living/carbon/human/consistent)
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "A stale camera cannot show its guide after a body transfer")
	reconnected.mob = body
	reconnected.brandish_camera_suppressed = TRUE
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 1, "Debug opt-out prevents a pending guide")
	reconnected.brandish_camera_suppressed = FALSE
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 2, "Becoming eligible later shows the intro for this activation")
	reconnected.brandish_camera_suppressed = TRUE
	reconnected.brandish_camera_suppressed = FALSE
	camera.show_intro()
	TEST_ASSERT_EQUAL(camera.openings, 2, "Debug opt-in does not repeat an acknowledged guide")

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
