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

	var/atom/attached_atom

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
	// ^ Future me here, its because it works as translate then scale since its backwards.
	M.Translate(-128 + (16 * proportion))
	return M

#undef LIGHTING_MASK_SPRITE_SIZE
