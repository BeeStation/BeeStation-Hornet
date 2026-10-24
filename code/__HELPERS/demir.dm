#ifdef __DEMIR_BAKE__

// Demir bewlshit

/datum/demir/hornet
	default = TRUE

/datum/demir/hornet/bake(atom/target)
	target.demir_bake_appearance()

/datum/demir/hornet/light(atom/target)
	target.demir_apply_light()

// Stand ins

/atom/proc/demir_bake_appearance()
	return

/atom/proc/demir_apply_light()
	//if(light_system != COMPLEX_LIGHT || !light_on || !light_range || !light_power)
	//	return
	demir_light_range = light_range
	demir_light_power = light_power
	demir_light_color = light_color
	// demir_light_angle = light_angle
	// demir_light_dir = light_dir
	// var/list/light_offset = get_light_offset()
// The game adds these offsets to the sample position, which moves the source the opposite way.
	// demir_light_offset_x = -light_offset[1]
	// demir_light_offset_y = -light_offset[2]
	demir_light_height = light_height

/obj/machinery/light/demir_apply_light()
	demir_light_range = brightness
	demir_light_power = bulb_power
	demir_light_color = pick(list("#ffa8a8", "#97ff94", "#bcd2ff"))//bulb_colour
	demir_light_height = light_height

/turf/closed/wall/demir_bake_appearance()
	. = ..()
	//icon_state = "wall-255"
	//color = pick(list("#f00", "#0f0", "#00f"))

#endif
