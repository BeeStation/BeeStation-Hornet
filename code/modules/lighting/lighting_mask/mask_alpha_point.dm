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

/atom/movable/lighting_mask/alpha/primary_lighting
	icon_state = "light_normalized_2"
