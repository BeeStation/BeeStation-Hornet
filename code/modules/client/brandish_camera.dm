// Camera/input only. Terrain uses shared, build-generated native DMI resources.
GLOBAL_DATUM_INIT(brandish_assets, /datum/brandish_asset_registry/runtime, new)

/client
	var/datum/brandish_camera/brandish_camera
	/// Debug opt-out for the current body; reset on Login/body transfer.
	var/brandish_camera_suppressed = FALSE
	/// Teardown must not send skin/view updates to a disconnecting client.
	var/brandish_disconnecting = FALSE

/client/proc/queue_brandish_camera_sync()
	addtimer(CALLBACK(src, PROC_REF(sync_brandish_camera)), 0, TIMER_UNIQUE)

/// forceMove into a locker, cryo cell, carrier or vehicle makes that container
/// the native eye. It is still local control, unlike a remote camera or console.
/client/proc/brandish_has_local_eye()
	return mob && eye && (eye == mob || (ismovable(eye) && eye == mob.loc))

/client/proc/sync_brandish_camera()
	var/available = CONFIG_GET(flag/brandish_camera) && !brandish_camera_suppressed && !brandish_disconnecting && logged_in && mob?.brandish_perspective_allowed() && mob.stat != DEAD && mob.hud_used && brandish_has_local_eye() && !mob.remote_control && !mob.control_object
	if(brandish_camera && (!available || brandish_camera.body != mob))
		QDEL_NULL(brandish_camera)
	if(available && !brandish_camera && GLOB.brandish_assets.has_catalog())
		brandish_camera = new(src)

/// Bodies that never use the perspective, even while it is enabled globally.
/// Ghosts, lobby players and other non-living mobs are excluded here.
/mob/proc/brandish_perspective_allowed()
	return FALSE

/mob/living/brandish_perspective_allowed()
	// A mind housed inside a carried object (soulstone shade, possessed blade,
	// sentient artifact, pAI card, MMI) has no body to steer or face forward.
	return !isitem(loc)

/// Cyborgs, AIs and pAIs keep their own cameras and controls.
/mob/living/silicon/brandish_perspective_allowed()
	return FALSE

/mob/living/brain/brandish_perspective_allowed()
	return FALSE

/// Shades exist only inside a container: soulstones and sentient artifacts.
/mob/living/simple_animal/shade/brandish_perspective_allowed()
	return FALSE

/// Server-wide switch. The round starts in the normal perspective; an admin or
/// coder turns the experimental perspective on for every eligible living body.
/client/proc/toggle_brandish_perspective()
	set name = "Toggle Brandish Perspective"
	set category = "Debug"
	set desc = "Switch every living player between the normal view and the experimental Brandish perspective."
	if(!holder || !(holder.rank.rights & (R_ADMIN | R_DEBUG)))
		return
	var/enable = !CONFIG_GET(flag/brandish_camera)
	if(enable && !GLOB.brandish_assets.has_catalog())
		to_chat(src, span_warning("This build uses original artwork. Build with tools/build/build to enable the Brandish perspective."))
		return
	CONFIG_SET(flag/brandish_camera, enable)
	log_admin("[key_name(src)] [enable ? "enabled" : "disabled"] the Brandish perspective for all players.")
	message_admins("[key_name_admin(src)] [enable ? "enabled" : "disabled"] the Brandish perspective for all players.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Brandish Perspective")

/client/proc/toggle_brandish_camera()
	set name = "Brandish Camera"
	set category = "Debug"
	set desc = "Toggle W forward, A/D turn, S backpedal, Shift+A/D strafe and a forward-offset camera."
	var/allowed = holder && (holder.rank.rights & R_DEBUG)
	if(!allowed)
		return
	if(!CONFIG_GET(flag/brandish_camera))
		to_chat(src, span_notice("The Brandish perspective is off. Use Toggle Brandish Perspective to enable it for everyone."))
		return
	if(!GLOB.brandish_assets.has_catalog())
		to_chat(src, span_warning("This build uses original artwork. Build with tools/build/build to enable the Brandish camera."))
		return
	if(brandish_camera)
		brandish_camera_suppressed = TRUE
		QDEL_NULL(brandish_camera)
		to_chat(src, span_notice("Brandish camera disabled. Normal view and controls restored."))
		return
	if(!mob?.brandish_perspective_allowed() || !brandish_has_local_eye() || mob.remote_control || mob.control_object)
		to_chat(src, span_warning("Use this camera while directly controlling a living character that supports it."))
		return
	brandish_camera_suppressed = FALSE
	sync_brandish_camera()
	to_chat(src, span_notice("Brandish camera enabled: W forward, A/D turn, S backpedal, Shift+A/D strafe. Your character stays below center facing away. Use this verb again to restore the view."))

/datum/brandish_camera
	var/client/owner
	var/mob/living/body
	var/previous_dir
	var/previous_body_dir
	var/list/held = list()
	var/pending = NONE
	/// Suppress movement-facing only inside this camera's own movement dispatch.
	var/movement_input_depth = 0
	var/atom/movable/followed_seat
	/// Keep a held seat movement command stable when the chair turns mid-step.
	var/seat_input_basis = NONE
	/// Keep the player three tiles below the viewport center.
	var/lead_tiles = 3

/datum/brandish_camera/New(client/viewer)
	owner = viewer
	body = viewer.mob
	previous_dir = viewer.dir
	previous_body_dir = body.dir
	viewer.ensure_camera_state()
	viewer.brandish_camera = src
	clear_movement()
	RegisterSignal(body, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_buckle_changed))
	RegisterSignals(body, list(COMSIG_MOB_SET_MOB_EYE, COMSIG_MOB_STATCHANGE), PROC_REF(on_control_changed))
	RegisterSignal(body, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	follow_seat(body.buckled)
	var/facing = followed_seat ? followed_seat.dir : body.dir
	if(!(facing in GLOB.cardinals))
		facing = NORTH
	viewer.setDir(facing)
	body.setDir(facing)
	update_offset()
	// WASD must reach keyDown in classic input mode too. Only switch the live
	// macro/focus; saved preferences are untouched and restored on disable.
	viewer.update_special_keybinds()
	viewer.update_macro_mode()
	addtimer(CALLBACK(src, PROC_REF(show_intro)), 1 SECONDS)
	return ..()

/datum/brandish_camera/Destroy()
	SStgui.close_uis(src)
	if(body)
		UnregisterSignal(body, list(COMSIG_LIVING_SET_BUCKLED, COMSIG_MOB_SET_MOB_EYE, COMSIG_MOB_STATCHANGE, COMSIG_MOB_LOGOUT))
	if(followed_seat)
		UnregisterSignal(followed_seat, COMSIG_ATOM_POST_DIR_CHANGE)
	if(owner)
		clear_movement()
		owner.brandish_camera = null
		owner.clear_camera_effect(src)
		if(!owner.brandish_disconnecting)
			owner.setDir(previous_dir)
			owner.update_special_keybinds()
			owner.update_macro_mode()
			if(!QDELETED(body) && owner.mob == body)
				body.setDir(followed_seat && body.buckled == followed_seat ? followed_seat.dir : previous_body_dir)
	owner = null
	body = null
	followed_seat = null
	return ..()

/datum/brandish_camera/proc/clear_movement()
	for(var/key in held)
		owner.keys_held -= key
		owner.key_combos_held -= key
	// Normal movement may already be held when control ownership changes.
	for(var/key in owner.keys_held.Copy())
		if(SSinput.movement_keys[key])
			owner.keys_held -= key
			owner.key_combos_held -= key
	owner.next_move_dir_add = NONE
	owner.next_move_dir_sub = NONE
	held.Cut()
	pending = NONE
	seat_input_basis = NONE

/// Use the existing buckle contract, covering chairs and ridden wheelchairs
/// without duplicating their rotation/movement implementations.
/datum/brandish_camera/proc/follow_seat(atom/movable/seat)
	if(followed_seat)
		UnregisterSignal(followed_seat, COMSIG_ATOM_POST_DIR_CHANGE)
	followed_seat = null
	if(seat && seat.buckle_lying == 0 && seat.buckle_dir == BUCKLE_MATCH_DIR)
		followed_seat = seat
		RegisterSignal(seat, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_seat_turned))

/datum/brandish_camera/proc/on_buckle_changed(mob/living/source, atom/movable/new_seat)
	SIGNAL_HANDLER
	clear_movement()
	follow_seat(new_seat)

/datum/brandish_camera/proc/on_control_changed()
	SIGNAL_HANDLER
	if(!is_available())
		qdel(src)
	else if(!can_accept_input())
		pending = NONE

/datum/brandish_camera/proc/on_logout()
	SIGNAL_HANDLER
	qdel(src)

/datum/brandish_camera/proc/is_available()
	return GLOB.brandish_assets.enabled && owner && !owner.brandish_disconnecting && !QDELETED(body) && body.stat != DEAD && body.brandish_perspective_allowed() && owner.mob == body && owner.brandish_has_local_eye() && !body.remote_control && !body.control_object

/// Incapacitation pauses input, not the camera's orientation or composition.
/// SOFT_CRIT can still crawl through the ordinary client.Move path.
/datum/brandish_camera/proc/can_accept_input()
	return is_available() && body.stat <= SOFT_CRIT

/datum/brandish_camera/proc/on_seat_turned(atom/movable/source)
	SIGNAL_HANDLER
	if(body?.buckled == source)
		body.setDir(source.dir)

/datum/brandish_camera/proc/sync_view_direction(direction)
	var/camera_direction = (direction in GLOB.cardinals) ? direction : angle2dir_cardinal(dir2angle(direction))
	if(owner.dir != camera_direction)
		owner.setDir(camera_direction)

/datum/brandish_camera/proc/action_for_key(key)
	var/base_key = keybinding_base_key(key)
	if(base_key != key)
		return brandish_action_for_key(owner.prefs.key_bindings_by_key, base_key, key)
	var/alt = owner.keys_held["Alt"] ? "Alt" : ""
	var/ctrl = owner.keys_held["Ctrl"] ? "Ctrl" : ""
	var/shift = owner.keys_held["Shift"] ? "Shift" : ""
	var/full_key = (key in list("Alt", "Ctrl", "Shift")) ? key : "[alt][ctrl][shift][key]"
	return brandish_action_for_key(owner.prefs.key_bindings_by_key, key, full_key)

/datum/brandish_camera/proc/direction_for_action(action)
	switch(action)
		if("brandish_forward")
			return NORTH
		if("brandish_backward")
			return SOUTH
		if("brandish_strafe_left")
			return WEST
		if("brandish_strafe_right")
			return EAST
	return NONE

/datum/brandish_camera/proc/handle_key_down(key)
	if(!is_available())
		return FALSE
	var/action = action_for_key(key)
	if(!action && (key in list("Alt", "Ctrl", "Shift")))
		owner.keys_held[key] = world.time
		for(var/physical_key in held)
			pending &= ~direction_for_action(held[physical_key])
			held[physical_key] = action_for_key(physical_key)
		return FALSE
	if(!action)
		return FALSE
	key = keybinding_base_key(key)
	if(held[key] == action)
		return TRUE
	pending &= ~direction_for_action(held[key])
	owner.keys_held[key] = world.time
	held[key] = action
	var/direction = direction_for_action(action)
	if(action == "brandish_turn_left")
		rotate(90)
	else if(action == "brandish_turn_right")
		rotate(-90)
	// Preserve taps until the native Move timing gate accepts them.
	if(direction && can_accept_input())
		if(followed_seat && !seat_input_basis)
			seat_input_basis = owner.dir
		pending = (pending & ~REVERSE_DIR(direction)) | direction
	return TRUE

/datum/brandish_camera/proc/handle_key_up(key)
	key = keybinding_base_key(key)
	if(key in list("Alt", "Ctrl", "Shift"))
		owner.keys_held -= key
		for(var/physical_key in held)
			if(physical_key == key)
				continue
			pending &= ~direction_for_action(held[physical_key])
			held[physical_key] = action_for_key(physical_key)
	if(!(key in held))
		return FALSE
	held -= key
	owner.keys_held -= key
	owner.key_combos_held -= key
	if(!length(held) && !pending)
		seat_input_basis = NONE
	return TRUE

/datum/brandish_camera/proc/key_loop()
	if(!can_accept_input())
		pending = NONE
		owner?.Move(null, NONE)
		return
	var/relative_dir = pending
	for(var/key in held)
		// Explicit combo macros retain their action even when BYOND doesn't
		// deliver a separate modifier-down event. Either physical or combo-up
		// releases the same key. Modifier events update held actions above.
		relative_dir |= direction_for_action(held[key])
	if((relative_dir & NORTH) && (relative_dir & SOUTH))
		relative_dir &= ~(NORTH|SOUTH)
	if((relative_dir & EAST) && (relative_dir & WEST))
		relative_dir &= ~(EAST|WEST)
	if(!relative_dir)
		pending = NONE
		seat_input_basis = NONE
		// Normal keyLoop calls Move even while idle. Besides input, Move keeps
		// move_delay current; skipping it turns idle time into a huge move_delta
		// after the first step and stalls a held movement key.
		owner.Move(null, NONE)
		return
	var/input_facing = followed_seat && seat_input_basis ? seat_input_basis : owner.dir
	if(followed_seat && !seat_input_basis)
		seat_input_basis = input_facing
	var/direction = turn(relative_dir, -dir2angle(input_facing))
	if(owner.movement_locked && !(SEND_SIGNAL(body, COMSIG_MOVABLE_KEYBIND_FACE_DIR, direction) & COMSIG_IGNORE_MOVEMENT_LOCK))
		if(pending && !followed_seat && body.canface())
			owner.setDir(angle2dir_cardinal(dir2angle(direction)))
			body.try_face(owner.dir)
		pending = NONE
		owner.Move(null, NONE)
		return
	// Let the normal movement loop own fractional delays and glide. Retain a
	// buffered tap only when Move's own timing gate will reject this tick.
	if(world.time >= FLOOR(owner.move_delay, 1 / world.fps))
		pending = NONE
	movement_input_depth++
	owner.Move(get_step(body, direction), direction)
	movement_input_depth--

/datum/brandish_camera/proc/rotate(angle)
	if(!can_accept_input())
		return
	if(followed_seat)
		return
	if(!body.canface())
		return
	owner.setDir(turn(owner.dir, angle))
	body.try_face(owner.dir)

/// Scale the final native movement delay, including its equipment/status
/// slowdown. Rear diagonals use the backpedal penalty; the normal movement
/// path still applies its diagonal distance cost and computes matching glide.
/datum/brandish_camera/proc/movement_delay_multiplier(direction)
	if(direction & REVERSE_DIR(owner.dir))
		return 2
	if(direction & (turn(owner.dir, 90) | turn(owner.dir, -90)))
		return 4 / 3
	return 1

/datum/brandish_camera/proc/update_offset()
	// BYOND clips the outer row in rotated views when pixel_z alone exceeds
	// two tiles. Put the extra look-ahead in world axes so it requests those
	// tiles too, while keeping the same total screen-space displacement.
	var/screen_tiles = min(lead_tiles, 2)
	var/list/world_offset = camera_screen_to_world(0, (lead_tiles - screen_tiles) * world.icon_size, owner.dir)
	owner.set_camera_effect(src, offset_x = world_offset[1], offset_y = world_offset[2], offset_z = screen_tiles * world.icon_size)


// Keep a backpedalling character's existing NORTH/back sprite selected in the
// camera's coordinates, including their existing equipment/body overlays.
/mob/setDir(newdir)
	if(client?.brandish_camera?.body == src)
		var/datum/brandish_camera/camera = client.brandish_camera
		if(camera.followed_seat && buckled == camera.followed_seat)
			newdir = camera.followed_seat.dir
			camera.sync_view_direction(newdir)
		else if(direction_animation_depth)
			// Direction animations (e.g. *spin) turn the player's viewpoint,
			// keeping their own back-facing sprite aligned with the camera.
			camera.sync_view_direction(newdir)
		else if(camera.movement_input_depth)
			newdir = client.dir
		if(dir == newdir)
			return FALSE
	return ..()

/// Event-driven binding: initialized atoms, icon updates, smoothing and physical
/// direction changes reuse prebuilt file resources. Camera turns never call it.
/atom/proc/apply_brandish_icon()
	if(!icon)
		return
	var/kind = brandish_icon_mode
	if(!kind && !(smoothing_flags & (SMOOTH_BITMASK | SMOOTH_CORNERS)))
		return
	if(!GLOB?.brandish_assets?.enabled)
		return
	if((smoothing_flags & SMOOTH_BITMASK) && base_icon_state)
		kind = "smooth"
	else if(smoothing_flags & SMOOTH_CORNERS)
		kind = "corner"
	else if(!kind)
		return
	var/replacement = GLOB.brandish_assets.icon_for(icon, kind, dir, base_icon_state, icon_state)
	if(replacement && replacement != icon)
		if(kind == "corner")
			clear_smooth_overlays()
		icon = replacement

/// Control ownership changes are event driven; direct field writes must use these setters.
/mob/proc/set_remote_control(atom/movable/target)
	remote_control = target
	client?.queue_brandish_camera_sync()

/mob/proc/set_control_object(obj/target)
	control_object = target
	client?.queue_brandish_camera_sync()
