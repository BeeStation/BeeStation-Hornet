/mob/living/silicon/cyborg/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE
	if(ionpulse())
		return TRUE
	return FALSE

/mob/living/silicon/cyborg/mob_negates_gravity()
	return magpulse

/mob/living/silicon/cyborg/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/cyborg/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
