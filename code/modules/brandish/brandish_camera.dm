// Camera/input only. Terrain uses shared, build-generated native DMI resources.
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
	if(!mob || !eye)
		return FALSE
	if(eye == mob || (ismovable(eye) && eye == mob.loc))
		return TRUE
	var/mob/living/body = mob
	return isliving(body) && body.looking_direction && isturf(eye) && eye == body.zlook_target

/// Body/control qualification shared by creation, active ownership and z-look.
/client/proc/brandish_body_eligible(mob/body)
	return !brandish_camera_suppressed && !brandish_disconnecting && body && mob == body \
		&& body.stat != DEAD && body.brandish_perspective_allowed() && !body.remote_control && !body.control_object

/client/proc/sync_brandish_camera()
	var/available = GLOB.brandish_perspective_enabled && logged_in && brandish_body_eligible(mob) && mob.hud_used && brandish_has_local_eye()
	if(brandish_camera && (!available || brandish_camera.body != mob))
		QDEL_NULL(brandish_camera)
	if(available && !brandish_camera && GLOB.brandish_assets.has_catalog())
		brandish_camera = new(src)

/datum/brandish_camera
	var/client/owner
	var/mob/living/body
	var/previous_body_dir
	var/list/held = list()
	var/pending = NONE
	/// Suppress movement-facing only inside this camera's own movement dispatch.
	var/movement_input_depth = 0
	var/atom/movable/followed_seat
	/// Keep a held seat movement command stable when the chair turns mid-step.
	var/seat_input_basis = NONE
	/// Keep the player two tiles below the viewport center.
	var/lead_tiles = 2
	var/static/list/modifier_keys = list("Alt", "Ctrl", "Shift")

/datum/brandish_camera/New(client/viewer)
	owner = viewer
	body = viewer.mob
	previous_body_dir = body.dir
	viewer.ensure_camera_state()
	// An OFF-mode shake/sway must not later overwrite the new composition.
	animate(viewer, tag = CLIENT_CAMERA_ANIMATION)
	viewer.brandish_camera = src
	clear_movement()
	RegisterSignal(body, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_buckle_changed))
	register_body_signals()
	follow_seat(body.buckled)
	var/facing = followed_seat ? followed_seat.dir : body.dir
	if(!(facing in GLOB.cardinals))
		facing = NORTH
	viewer.setDir(facing)
	body.setDir(facing)
	update_offset()
	// Movement bindings need keyDown in classic mode; saved preferences stay unchanged.
	viewer.update_special_keybinds()
	viewer.update_macro_mode()
	addtimer(CALLBACK(src, PROC_REF(show_intro)), 1 SECONDS)
	body.sync_brandish_observers()
	return ..()

/// Tie the camera's lifetime and composition to its controlling body.
/datum/brandish_camera/proc/register_body_signals()
	RegisterSignal(body, COMSIG_MOB_SET_MOB_EYE, PROC_REF(on_eye_changed))
	RegisterSignal(body, COMSIG_MOB_STATCHANGE, PROC_REF(on_control_changed))
	RegisterSignals(body, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING), PROC_REF(on_logout))

/datum/brandish_camera/Destroy()
	SStgui.close_uis(src)
	if(body)
		UnregisterSignal(body, list(COMSIG_LIVING_SET_BUCKLED, COMSIG_MOB_SET_MOB_EYE, COMSIG_MOB_STATCHANGE, COMSIG_MOB_LOGOUT, COMSIG_QDELETING))
	if(followed_seat)
		UnregisterSignal(followed_seat, COMSIG_ATOM_POST_DIR_CHANGE)
	if(owner)
		clear_movement()
		owner.brandish_camera = null
		owner.clear_camera_effect(src)
		if(!owner.brandish_disconnecting)
			owner.apply_default_client_dir()
			owner.update_special_keybinds()
			owner.update_macro_mode()
			if(!QDELETED(body) && owner.mob == body)
				body.setDir(followed_seat && body.buckled == followed_seat ? followed_seat.dir : previous_body_dir)
	var/mob/living/watched = body
	owner = null
	body = null
	followed_seat = null
	if(!QDELETED(watched))
		watched.sync_brandish_observers()
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

/datum/brandish_camera/proc/on_eye_changed()
	SIGNAL_HANDLER
	on_control_changed()
	if(!QDELETED(src))
		update_offset()

/datum/brandish_camera/proc/on_logout()
	SIGNAL_HANDLER
	qdel(src)

/datum/brandish_camera/proc/is_available()
	return GLOB.brandish_perspective_enabled && GLOB.brandish_assets.enabled && owner && owner.brandish_camera == src && !QDELETED(body) && owner.brandish_body_eligible(body) && owner.brandish_has_local_eye()

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
	var/full_key = (key in modifier_keys) ? key : "[alt][ctrl][shift][key]"
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
	if(!action && (key in modifier_keys))
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
	if(key in modifier_keys)
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

// More than two screen tiles clips rotated views; world offsets can lag a turn
// by one rendered frame. Keep look-ahead entirely in screen coordinates.
/datum/brandish_camera/proc/update_offset()
	// A z-look eye already centers the aperture in the other floor.
	var/lead = isturf(owner.eye) ? 0 : lead_tiles * world.icon_size
	owner.set_camera_effect(src, offset_z = lead)

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
/// Control ownership changes are event driven; direct field writes must use these setters.
/mob/proc/set_remote_control(atom/movable/target)
	remote_control = target
	client?.queue_brandish_camera_sync()

/mob/proc/set_control_object(obj/target)
	control_object = target
	client?.queue_brandish_camera_sync()

/mob/var/tmp/direction_animation_depth = 0
