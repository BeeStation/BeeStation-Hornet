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
	var/available = !brandish_camera_suppressed && !brandish_disconnecting && logged_in && isliving(mob) && mob.stat != DEAD && mob.hud_used && brandish_has_local_eye() && !mob.remote_control && !mob.control_object
	if(brandish_camera && (!available || brandish_camera.body != mob))
		QDEL_NULL(brandish_camera)
	if(available && !brandish_camera && GLOB.brandish_assets.has_catalog())
		brandish_camera = new(src)

/client/proc/toggle_brandish_camera()
	set name = "Brandish Camera"
	set category = "Debug"
	set desc = "Toggle W forward, A/D turn, S backpedal, Shift+A/D strafe and a forward-offset camera."
	var/allowed = holder && (holder.rank.rights & R_DEBUG)
	if(!allowed)
		return
	if(!GLOB.brandish_assets.has_catalog())
		to_chat(src, span_warning("This build uses original artwork. Build with tools/build/build to enable the Brandish camera."))
		return
	if(brandish_camera)
		brandish_camera_suppressed = TRUE
		QDEL_NULL(brandish_camera)
		to_chat(src, span_notice("Brandish camera disabled. Normal view and controls restored."))
		return
	if(!isliving(mob) || !brandish_has_local_eye() || mob.remote_control || mob.control_object)
		to_chat(src, span_warning("Use this camera while controlling a living character directly."))
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
	var/list/shifted_actions = list()
	var/pending = NONE
	/// Suppress movement-facing only inside this camera's own movement dispatch.
	var/movement_input_depth = 0
	var/atom/movable/followed_seat
	/// Keep a held seat movement command stable when the chair turns mid-step.
	var/seat_input_basis = NONE
	/// Stay within BYOND 516's two-tile screen-offset rendering margin. A larger
	/// pixel_z exposes an unrendered top row after moving (including buckling).
	var/lead_tiles = 2

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
	viewer.update_macro_mode()
	return ..()

/datum/brandish_camera/Destroy()
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
			owner.update_macro_mode()
			if(!QDELETED(body) && owner.mob == body)
				body.setDir(followed_seat && body.buckled == followed_seat ? followed_seat.dir : previous_body_dir)
	owner = null
	body = null
	followed_seat = null
	return ..()

/datum/brandish_camera/proc/clear_movement()
	owner.keys_held -= list("W", "A", "S", "D", "North", "South", "East", "West")
	for(var/key in list("W", "A", "S", "D", "North", "South", "East", "West"))
		owner.key_combos_held -= key
	owner.next_move_dir_add = NONE
	owner.next_move_dir_sub = NONE
	held.Cut()
	shifted_actions.Cut()
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
	return owner && !owner.brandish_disconnecting && !QDELETED(body) && body.stat != DEAD && owner.mob == body && owner.brandish_has_local_eye() && !body.remote_control && !body.control_object

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

/datum/brandish_camera/proc/handle_key_down(key)
	if(!is_available())
		return FALSE
	if(key == "Shift")
		return FALSE
	var/shifted = owner.keys_held["Shift"]
	if(copytext(key, 1, 6) == "Shift")
		shifted = TRUE
		key = copytext(key, 6)
	// Physical keys go through the normal rebindable keybinding dispatch.
	if(!(key in list("North", "South", "East", "West")))
		return FALSE
	if(key in held)
		return TRUE
	owner.keys_held[key] = world.time
	if(shifted)
		shifted_actions[key] = TRUE
	var/direction = NONE
	switch(key)
		if("North")
			direction = NORTH
		if("South")
			direction = SOUTH
		if("West")
			if(shifted)
				direction = WEST
			else
				rotate(90)
		if("East")
			if(shifted)
				direction = EAST
			else
				rotate(-90)
	held[key] = direction
	// A short tap survives key-up until Move accepts the next input tick.
	// A new opposite tap replaces an older buffered tap rather than cancelling it.
	if(direction && can_accept_input())
		if(followed_seat && !seat_input_basis)
			seat_input_basis = owner.dir
		pending = (pending & ~REVERSE_DIR(direction)) | direction
	return TRUE

/datum/brandish_camera/proc/handle_key_up(key)
	if(key == "Shift")
		shifted_actions.Cut()
		pending &= ~(EAST|WEST)
		return FALSE
	if(copytext(key, 1, 6) == "Shift")
		key = copytext(key, 6)
	if(!(key in list("North", "South", "East", "West")))
		return FALSE
	held -= key
	shifted_actions -= key
	owner.keys_held -= key
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
		if(key == "West" || key == "East")
			if(owner.keys_held["Shift"] || shifted_actions[key])
				relative_dir |= (key == "West" ? WEST : EAST)
		else
			relative_dir |= held[key]
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
	// The look-ahead is constant in screen space. Rotating world-space pixel
	// offsets as well as client.dir makes the client interpolate an old view.
	owner.set_camera_effect(src, offset_z = lead_tiles * world.icon_size)


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
	var/replacement = GLOB.brandish_assets.icon_for(icon, kind, dir, base_icon_state)
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
