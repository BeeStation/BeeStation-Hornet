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

	appearance_flags = KEEP_TOGETHER

	move_resist = INFINITY

	//The radius of the mask
	var/radius = 0

	//The atom that we are attached to
	var/atom/attached_atom = null

	//Tracker var for the holder
	var/datum/weakref/holder = null

	//Tracker var for tracking init dupe requests
	var/awaiting_update = FALSE

/atom/movable/lighting_mask/Destroy()
	//Delete the holder object
	holder = null
	//Remove reference to the atom we are attached to
	attached_atom = null
	//Remove from subsystem
	LAZYREMOVE(SSlighting.queued_shadow_updates, src)
	//Continue with deletiib
	. = ..()

/atom/movable/lighting_mask/proc/set_radius(radius, transform_time = 0)
	//Update our matrix
	var/matrix/M = get_matrix(radius)
	apply_matrix(M, transform_time)
	//Set the radius variable
	src.radius = radius
	//Calculate shadows
	calculate_lighting_shadows()

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
	// ^ ^ Future future me here, it totally shouldnt since the translation component of a matrix is independant to the scale component.
	M.Translate(-128 + 16)
	//Adjust for pixel offsets
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)
	M.Translate(offset_x, offset_y)
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
