#define LIGHTING_MASK_RADIUS 4
#define LIGHTING_MASK_SPRITE_SIZE LIGHTING_MASK_RADIUS * 64

/atom/movable/lighting_mask
	name = ""

	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

	anchored = TRUE
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_SECONDARY_LAYER
	invisibility     = INVISIBILITY_LIGHTING
	blend_mode		 = BLEND_ADD

	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER

	move_resist = INFINITY

	var/radius = 0

	var/atom/attached_atom

/atom/movable/lighting_mask/Destroy()
	attached_atom = null

	. = ..()

/atom/movable/lighting_mask/proc/set_radius(radius, transform_time = 0)
	apply_matrix(get_matrix(radius), transform_time)
	calculate_lighting_shadows()

	src.radius = radius

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
	//Translate
	// - Center the overlay image
	// - Ok so apparently translate is affected by the scale we already did huh.
	// ^ Future me here, its because it works as translate then scale since its backwards.
	M.Translate(-128 + (16 * proportion))
	//Rotate
	// - Rotate (Directional lights)
	M.Turn(currentAngle)
	return M

/atom/movable/lighting_mask/ex_act(severity, target)
	return

/atom/movable/lighting_mask/singularity_pull(obj/singularity/S, current_size)
	return

/atom/movable/lighting_mask/singularity_act()
	return

/atom/movable/lighting_mask/fire_act(exposed_temperature, exposed_volume)
	return

/atom/movable/lighting_mask/acid_act(acidpwr, acid_volume)
	return

/atom/movable/lighting_mask/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta, throw_target)
	return

#undef LIGHTING_MASK_SPRITE_SIZE
