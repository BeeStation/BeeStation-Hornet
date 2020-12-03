/atom/movable/lighting_mask/colour
	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_transparent"

	plane            = LIGHTING_COLOUR_PLANE
	layer            = LIGHTING_COLOUR_LAYER
	blend_mode		 = BLEND_OVERLAY

	alpha			 = 100

//The hard to destroy mask
/atom/movable/lighting_mask/colour/Destroy(force)
	if(force)
		. = ..()
