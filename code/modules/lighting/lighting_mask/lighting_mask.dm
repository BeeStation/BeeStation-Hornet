#define LIGHTING_MASK_RADIUS 4
#define LIGHTING_MASK_SPRITE_SIZE LIGHTING_MASK_RADIUS * 64

/atom/movable/lighting_mask
	name = ""

	anchored = TRUE
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING
	blend_mode		 = BLEND_ADD

	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA

	bound_x = -128
	bound_y = -128
	bound_height = 256
	bound_width = 256

	//Smooth shadows make the triangles as world objects.
	//This is more expensive on memory, but when an object moves the shadows will be smooth.
	var/smooth_shadows = FALSE

	var/radius = 0

/atom/movable/lighting_mask/proc/set_radius(radius, transform_time = 0)
	apply_matrix(get_matrix(radius), transform_time)

	src.radius = radius
	var/radius_safe = FLOOR(radius + 1, 1) * 32
	var/diameter = radius_safe * 2
	bound_x = -radius_safe
	bound_y = -radius_safe
	bound_height = diameter
	bound_width = diameter

/atom/movable/lighting_mask/proc/apply_matrix(matrix/M, transform_time = 0)
	if(transform_time)
		animate(src, transform = M, time = transform_time)
	else
		transform = M

/atom/movable/lighting_mask/proc/get_matrix(radius = 1)
	var/proportion = radius / LIGHTING_MASK_RADIUS
	var/matrix/M = new()
	//Scale
	// - Scale to the appropriate radius
	M.Scale(proportion)
	//Rotate
	// - Rotate (Directional lights TODO)
	//Translate
	// - Center the overlay image
	// - Ok so apparently translate is affected by the scale we already did huh.
	M.Translate(-128 + (16 * proportion))
	return M

//kinda slow but 5head
/atom/movable/lighting_mask/proc/generate_shadows()
	if(radius < 1.5)
		return
	var/icon/base_icon = new(icon, icon_state)
	var/list/corners = get_corner_positions()
	message_admins(list2params(corners))

//Very slow and r worded
/atom/movable/lighting_mask/proc/get_corner_positions()
	//Each x and y position is the bottom left of a tile
	var/list/edges = get_edge_turfs()
	message_admins("Edge turfs: [edges.len]")
	//Key = x, value = list(y positions)
	var/list/corner_coords = list()
	for(var/turf/closed/turf_check in edges)
		var/corner_left = corner_coords[turf_check.x]
		var/ignore_corner
		if(islist(corner_left))
			corner_left += turf_check.y
			corner_left += turf_check.y + 1
		else
			corner_coords["[turf_check.x]"] = list(turf_check.y, turf_check.y + 1)
		var/corner_right = corner_coords[turf_check.x + 1]
		if(islist(corner_right))
			corner_right += turf_check.y
			corner_right += turf_check.y + 1
		else
			corner_coords["[turf_check.x + 1]"] = list(turf_check.y, turf_check.y + 1)
	return corner_coords

//wtf slow
/atom/movable/lighting_mask/proc/get_edge_turfs()
	//This is so slow too
	var/list/end_turfs = view(radius, get_turf(src))
	return end_turfs

#undef LIGHTING_MASK_SPRITE_SIZE
