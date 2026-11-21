/proc/mouse_angle_from_client(client/client, mouseParams)
	var/list/vector = client?.camera_click_vector(params2list(mouseParams))
	if(vector)
		return SIMPLIFY_DEGREES(ATAN2(vector[2], vector[1]))

/proc/mouse_absolute_datum_map_position_from_client(client/client, params)
	var/turf/eye_turf = get_turf(client?.eye)
	var/list/vector = client?.camera_click_vector(params2list(params), eye_turf)
	if(!vector || !eye_turf)
		return
	var/x = vector[1] + ICON_SIZE_X / 2
	var/y = vector[2] + ICON_SIZE_Y / 2
	var/tile_x = FLOOR(x / ICON_SIZE_X, 1)
	var/tile_y = FLOOR(y / ICON_SIZE_Y, 1)
	return new /datum/position(eye_turf.x + tile_x, eye_turf.y + tile_y, eye_turf.z, x - tile_x * ICON_SIZE_X, y - tile_y * ICON_SIZE_Y)
