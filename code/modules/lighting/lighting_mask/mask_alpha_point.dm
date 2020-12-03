/atom/movable/lighting_mask/alpha
	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

	//Our colour mask on the layer above
	var/atom/movable/lighting_mask/colour/colour_mask

/atom/movable/lighting_mask/alpha/Initialize(mapload)
	. = ..()
	//Create our colour mask
	colour_mask = new()
	vis_contents += colour_mask

/atom/movable/lighting_mask/alpha/Destroy()
	. = ..()
	//Order the colour mask to cease its existance
	qdel(colour_mask, force = TRUE)

/atom/movable/lighting_mask/alpha/proc/set_colour(colour = "#ffffff")
	colour_mask.color = colour

/atom/movable/lighting_mask/alpha/proc/set_intensity(intensity = 1)
	colour_mask.alpha = ALPHA_TO_INTENSITY(intensity)
