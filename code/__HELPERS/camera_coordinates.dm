/// Cardinal camera transforms. World positions and sprite-local offsets are
/// separate: pixel_x/y rotate, pixel_w/z remain screen-relative.
/proc/camera_world_to_screen(x, y, facing = NORTH)
	switch(facing)
		if(EAST)
			return list(-y, x)
		if(SOUTH)
			return list(-x, -y)
		if(WEST)
			return list(y, -x)
	return list(x, y)

/proc/camera_screen_to_world(x, y, facing = NORTH)
	switch(facing)
		if(EAST)
			return list(y, -x)
		if(SOUTH)
			return list(-x, -y)
		if(WEST)
			return list(-y, x)
	return list(x, y)

/// screen-loc pixel coordinates measured from the map's bottom-left corner.
/proc/camera_screen_pixels(list/modifiers)
	var/location = LAZYACCESS(modifiers, SCREEN_LOC)
	if(!location)
		return
	var/list/axes = splittext(location, ",")
	if(length(axes) != 2)
		return
	var/list/x = splittext(axes[1], ":")
	var/list/y = splittext(axes[2], ":")
	if(length(x) != 2 || length(y) != 2)
		return
	return list((text2num(x[1]) - 1) * ICON_SIZE_X + text2num(x[2]), (text2num(y[1]) - 1) * ICON_SIZE_Y + text2num(y[2]))

/// World-space pixel vector from a turf centre to a map click.
/client/proc/camera_click_vector(list/modifiers, atom/origin = mob)
	var/list/point = camera_screen_pixels(modifiers)
	var/turf/eye_turf = get_turf(eye)
	var/turf/origin_turf = get_turf(origin)
	if(!point || !eye_turf || !origin_turf)
		return
	var/list/size = view_to_pixels(view)
	var/list/vector = camera_screen_to_world(point[1] - size[1] / 2 + pixel_w, point[2] - size[2] / 2 + pixel_z, dir)
	vector[1] += (eye_turf.x - origin_turf.x) * ICON_SIZE_X + pixel_x
	vector[2] += (eye_turf.y - origin_turf.y) * ICON_SIZE_Y + pixel_y
	return vector

/// Combined sprite offset for world-aligned exporters (photos, flattened icons).
/proc/appearance_pixel_offset(image/appearance, facing = NORTH)
	var/list/offset = camera_world_to_screen(appearance.pixel_x, appearance.pixel_y, facing)
	offset[1] += appearance.pixel_w
	offset[2] += appearance.pixel_z
	return offset
