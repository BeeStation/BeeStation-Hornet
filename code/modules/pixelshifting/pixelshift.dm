/mob/proc/unpixel_shift()
	return

/mob/proc/pixel_shift(direction)
	return

/mob/living/unpixel_shift()
	if(is_shifted)
		is_shifted = FALSE
		pixel_x = body_pixel_x_offset + base_pixel_x
		pixel_y = body_pixel_y_offset + base_pixel_y

/mob/living/pixel_shift(direction)
	switch(direction)
		if(NORTH)
			if(!canface())
				return FALSE
			if(pixel_y <= 16 + base_pixel_y)
				pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(!canface())
				return FALSE
			if(pixel_x <= 16 + base_pixel_x)
				pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(!canface())
				return FALSE
			if(pixel_y >= -16 + base_pixel_y)
				pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(!canface())
				return FALSE
			if(pixel_x >= -16 + base_pixel_x)
				pixel_x--
				is_shifted = TRUE
