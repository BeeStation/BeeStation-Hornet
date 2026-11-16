// Permanent artwork origins share movable bookkeeping, including public base deltas.
// Living offsets independently compose temporary world movement and screen height.
// screen_placement temporarily converts contained items and restores all four values.
/// Move an artwork-origin delta from world to screen pixels. Calls accumulate;
/// from_base excludes the migrated portion from later world-base resets.
/atom/proc/brandish_screen_origin(offset_x, offset_y, from_base = FALSE)
	pixel_x -= offset_x
	pixel_y -= offset_y
	pixel_w += offset_x
	pixel_z += offset_y
	if(ismovable(src))
		var/atom/movable/movable = src
		movable.brandish_origin_screen_x += offset_x
		movable.brandish_origin_screen_y += offset_y
		if(from_base)
			movable.brandish_base_screen_x += offset_x
			movable.brandish_base_screen_y += offset_y

/atom/movable
	/// Persistent screen origin, separate from temporary animation and offsets.
	var/tmp/brandish_origin_screen_x = 0
	var/tmp/brandish_origin_screen_y = 0
	/// Portion of public base offsets already migrated to the screen origin.
	var/tmp/brandish_base_screen_x = 0
	var/tmp/brandish_base_screen_y = 0

/atom/proc/get_screen_base_pixel_w()
	return initial(pixel_w)

/atom/proc/get_screen_base_pixel_z()
	return initial(pixel_z)

/atom/movable/get_screen_base_pixel_w()
	return initial(pixel_w) + brandish_origin_screen_x

/atom/movable/get_screen_base_pixel_z()
	return initial(pixel_z) + brandish_origin_screen_y

/// Base sprite offsets keep their public/serialized meaning. Non-mob atoms
/// still use them directly in world space; mobs separate the migrated origin.
/atom/proc/get_world_base_pixel_x()
	return base_pixel_x

/atom/proc/get_world_base_pixel_y()
	return base_pixel_y

/atom/movable/get_world_base_pixel_x()
	return base_pixel_x - brandish_base_screen_x

/atom/movable/get_world_base_pixel_y()
	return base_pixel_y - brandish_base_screen_y

/// Appearance copies must not retain another creature's screen origin.
/// Match the existing base-position reset while restoring both offset pairs.
/mob/proc/reset_pixel_origin()
	pixel_x = get_world_base_pixel_x()
	pixel_y = get_world_base_pixel_y()
	pixel_w = get_screen_base_pixel_w()
	pixel_z = get_screen_base_pixel_z()
