/// An effect which tracks the cursor's location on the screen
/atom/movable/screen/fullscreen/cursor_catcher
	icon_state = "fullscreen_blocker" // Fullscreen semi transparent icon
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	default_click = TRUE
	/// The mob whose cursor we are tracking.
	var/mob/owner
	/// Pixel x we send to the scope component.
	var/given_x
	/// Pixel y we send to the scope component.
	var/given_y
	/// The turf we send to the scope component.
	var/turf/given_turf
	/// Mouse parameters, for calculation.
	var/mouse_params

/// Links this up with a mob
/atom/movable/screen/fullscreen/cursor_catcher/proc/assign_to_mob(mob/owner)
	src.owner = owner
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	calculate_params()

/// Update when the mob we're assigned to has moved
/atom/movable/screen/fullscreen/cursor_catcher/proc/on_move(atom/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!given_turf)
		return
	var/x_offset = source.loc.x - oldloc.x
	var/y_offset = source.loc.y - oldloc.y
	given_turf = locate(given_turf.x+x_offset, given_turf.y+y_offset, given_turf.z)

/atom/movable/screen/fullscreen/cursor_catcher/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)
	if(usr == owner)
		calculate_params()

/atom/movable/screen/fullscreen/cursor_catcher/MouseMove(location, control, params)
	if(usr != owner)
		return
	mouse_params = params

/atom/movable/screen/fullscreen/cursor_catcher/proc/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/list/vector = owner.client?.camera_click_vector(modifiers, owner)
	if(!vector)
		return
	var/pixel_x = vector[1] + ICON_SIZE_X / 2
	var/pixel_y = vector[2] + ICON_SIZE_Y / 2
	var/our_x = FLOOR(pixel_x / ICON_SIZE_X, 1)
	var/our_y = FLOOR(pixel_y / ICON_SIZE_Y, 1)
	given_turf = locate(owner.x + our_x, owner.y + our_y, owner.z)
	given_x = round(pixel_x - ICON_SIZE_X * our_x, 1)
	given_y = round(pixel_y - ICON_SIZE_Y * our_y, 1)
