/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	. = ..()
	if(.)
		return TRUE
	if(ionpulse())
		return TRUE
	return FALSE

/mob/living/silicon/robot/has_jetpack_power(thrust, use_fuel = TRUE)
	return ionpulse(thrust, use_fuel)
