/atom/movable/lighting_mask/alpha
	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

/atom/movable/lighting_mask/alpha/proc/set_colour(colour = "#ffffff")
	color = colour

/atom/movable/lighting_mask/alpha/proc/set_intensity(intensity = 1)
	alpha = ALPHA_TO_INTENSITY(intensity)

/atom/movable/lighting_mask/alpha/Moved(atom/OldLoc, Dir)
	. = ..()
	calculate_lighting_shadows(OldLoc)

//The holder atom turned
/atom/movable/lighting_mask/alpha/proc/holder_turned(new_direction)
	return

//Normal lighting

/atom/movable/lighting_mask/alpha/primary_lighting
	icon_state = "light_normalized_2"
	layer = BACKGROUND_LAYER + LIGHTING_PRIMARY_LAYER

/atom/movable/lighting_mask/alpha/primary_lighting/set_intensity(intensity)
	alpha = 180

//Flicker

/atom/movable/lighting_mask/alpha/flicker
	icon_state = "light_flicker"

//Conical Light

/atom/movable/lighting_mask/alpha/conical
	icon_state = "light_conical"
	var/current_angle = 0

/atom/movable/lighting_mask/alpha/conical/get_matrix(radius = 1)
	var/matrix/M = matrix()
	M.Turn(current_angle)
	. = M * ..()

/atom/movable/lighting_mask/alpha/conical/holder_turned(new_direction)
	var/wanted_angle = dir2angle(new_direction) - 180
	rotate(wanted_angle - current_angle, 10)
	current_angle = wanted_angle
