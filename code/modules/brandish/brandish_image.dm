GLOBAL_LIST_EMPTY(brandish_images)

/atom
	/// Policy type applied once after successful initialization.
	var/brandish_image

/datum/brandish_image/proc/setup(atom/target)
	return

/// Upright canvases keep mapper placement in world axes and their origin on screen.
/datum/brandish_image/upright
	var/origin_x
	var/origin_y

/datum/brandish_image/upright/setup(atom/target)
	var/x = isnull(origin_x) ? initial(target.pixel_x) : origin_x
	var/y = isnull(origin_y) ? initial(target.pixel_y) : origin_y
	target.brandish_screen_origin(x, y)

/datum/brandish_image/upright/vertical_only
	origin_x = 0

/datum/brandish_image/upright/centered_64
	origin_x = -16
	origin_y = -16

/datum/brandish_image/upright/centered_160
	origin_x = -64
	origin_y = -64

/// Whole tiles locate the wall; sub-tile offsets stack upright labels on it.
/datum/brandish_image/wall_mounted/setup(atom/target)
	var/wall_x = FLOOR((target.pixel_x + ICON_SIZE_X / 2) / ICON_SIZE_X, 1) * ICON_SIZE_X
	var/wall_y = FLOOR((target.pixel_y + ICON_SIZE_Y / 2) / ICON_SIZE_Y, 1) * ICON_SIZE_Y
	target.brandish_screen_origin(target.pixel_x - wall_x, target.pixel_y - wall_y)

/// Flat multi-tile artwork rotates its canvas and native collision anchor together.
/datum/brandish_image/group_rotate/setup(atom/target)
	target.brandish_icon_mode = BRANDISH_MODE_GROUP_ROTATE
	if(target.icon && !target.brandish_image_projector)
		target.icon = GLOB.brandish_assets.source_for(target.icon)
		target.brandish_image_projector = new /datum/brandish_image_projector/group(target)
