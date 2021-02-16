/atom/movable/lighting_mask
	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

/atom/movable/lighting_mask/proc/set_colour(colour = "#ffffff")
	color = colour

/atom/movable/lighting_mask/proc/set_intensity(intensity = 1)
	alpha = ALPHA_TO_INTENSITY(intensity)

//The holder atom turned
/atom/movable/lighting_mask/proc/holder_turned(new_direction)
	return

//Normal lighting

/atom/movable/lighting_mask/primary_lighting
	icon_state = "light_bright"
	layer = BACKGROUND_LAYER + LIGHTING_PRIMARY_LAYER

/atom/movable/lighting_mask/primary_lighting/set_intensity(intensity)
	alpha = 180

//Flicker

/atom/movable/lighting_mask/flicker
	icon_state = "light_flicker"

//Conical Light

/atom/movable/lighting_mask/conical
	icon_state = "light_conical"

/atom/movable/lighting_mask/conical/holder_turned(new_direction)
	var/wanted_angle = dir2angle(new_direction) - 180
	rotate(wanted_angle)

//Rotating Light

/atom/movable/lighting_mask/rotating
	icon_state = "light_rotating-1"

/atom/movable/lighting_mask/rotating/Initialize(mapload, ...)
	. = ..()
	icon_state = "light_rotating-[rand(1, 3)]"
