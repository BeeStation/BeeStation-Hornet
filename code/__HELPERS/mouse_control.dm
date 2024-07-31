/proc/mouse_angle_from_client(client/client, mouseParams)
	var/list/modifiers = params2list(mouseParams)
	if(LAZYACCESS(modifiers, SCREEN_LOC) && client)
		var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = (text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32)
		var/y = (text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32)
		var/list/screenview = getviewsize(client.view)
		var/screenviewX = screenview[1] * world.icon_size
		var/screenviewY = screenview[2] * world.icon_size
		var/ox = round(screenviewX/2) - client.pixel_x //"origin" x
		var/oy = round(screenviewY/2) - client.pixel_y //"origin" y
		var/angle = SIMPLIFY_DEGREES(ATAN2(y - oy, x - ox))
		return angle

//Wow, specific name!
/proc/mouse_absolute_datum_map_position_from_client(client/client, params)
	if(!isloc(client.mob.loc))
		return
	var/list/modifiers = params2list(params)
	var/atom/A = client.eye
	var/turf/T = get_turf(A)
	var/cx = T.x
	var/cy = T.y
	var/cz = T.z
	if(LAZYACCESS(modifiers, SCREEN_LOC))
		var/x = 0
		var/y = 0
		var/z = 0
		var/p_x = 0
		var/p_y = 0
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")
		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/sx = text2num(screen_loc_X[1])
		var/sy = text2num(screen_loc_Y[1])
		//Get the resolution of the client's current screen size.
		var/list/screenview = getviewsize(client.view)
		var/svx = screenview[1]
		var/svy = screenview[2]
		var/cox = round((svx - 1) / 2)
		var/coy = round((svy - 1) / 2)
		x = cx + (sx - 1 - cox)
		y = cy + (sy - 1 - coy)
		z = cz
		p_x = text2num(screen_loc_X[2])
		p_y = text2num(screen_loc_Y[2])
		return new /datum/position(x, y, z, p_x, p_y)

GLOBAL_LIST_INIT(mouse_cooldowns, list(
	'icons/effects/cooldown_cursors/cooldown_1.dmi',
	'icons/effects/cooldown_cursors/cooldown_2.dmi',
	'icons/effects/cooldown_cursors/cooldown_3.dmi',
	'icons/effects/cooldown_cursors/cooldown_4.dmi',
	'icons/effects/cooldown_cursors/cooldown_5.dmi',
	'icons/effects/cooldown_cursors/cooldown_6.dmi',
	'icons/effects/cooldown_cursors/cooldown_7.dmi',
	'icons/effects/cooldown_cursors/cooldown_8.dmi',
	'icons/effects/cooldown_cursors/cooldown_9.dmi',
))

/client/var/cooldown_cursor_time

/client/proc/give_cooldown_cursor(time, override = FALSE)
	set waitfor = FALSE
	// Ignore the cooldown cursor if we have a longer one already applied
	if (world.time + time < cooldown_cursor_time && !override)
		return
	cooldown_cursor_time = world.time + time
	var/end_time = cooldown_cursor_time
	var/previous_cursor = mouse_pointer_icon
	var/start_time = world.time
	var/current_cursor = 1
	for (var/cursor_icon in GLOB.mouse_cooldowns)
		// Set the cursor and wait
		mouse_pointer_icon = cursor_icon
		// Sleep until we are where we should be
		var/next_cursor_time = start_time + current_cursor * time / length(GLOB.mouse_cooldowns)
		sleep(next_cursor_time - world.time)
		// Someone else is managing the cursor
		// Someone else is managing a cooldown timer, allow them since they overrode us
		if (mouse_pointer_icon != cursor_icon || cooldown_cursor_time != end_time)
			return
		current_cursor ++
	// Somehow we finished a bit early
	if (world.time < end_time)
		sleep(end_time - world.time)
		if (mouse_pointer_icon != GLOB.mouse_cooldowns[length(GLOB.mouse_cooldowns)] || cooldown_cursor_time != end_time)
			return
	if (previous_cursor in GLOB.mouse_cooldowns)
		mouse_pointer_icon = initial(mouse_pointer_icon)
	else
		mouse_pointer_icon = previous_cursor

/client/proc/clear_cooldown_cursor(time)
	if (!(mouse_pointer_icon in GLOB.mouse_cooldowns))
		return
	mouse_pointer_icon = initial(mouse_pointer_icon)
	cooldown_cursor_time = 0
