/obj/item/flashlight/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(flashlight_power)
			set_light(l_range = brightness_on, l_power = flashlight_power)
		else
			set_light(brightness_on)
		playsound(src, 'sound/items/flashlight_on.ogg', 25, 1)
	else
		icon_state = initial(icon_state)
		set_light(0)
		playsound(src, 'sound/items/flashlight_off.ogg', 25, 1)