/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE
	if(has_jetpack_power(movement_dir, require_stabilization = FALSE))
		return TRUE
	return FALSE

/mob/living/silicon/robot/has_jetpack_power(movement_dir, thrust = THRUST_REQUIREMENT_SPACEMOVE, require_stabilization, use_fuel = TRUE)
	if(..())
		return TRUE
	if(ionpulse(thrust, use_fuel = use_fuel))
		return TRUE
	return FALSE

/mob/living/silicon/robot/mob_negates_gravity()
	return isspaceturf(get_turf(src)) ? FALSE : magpulse //We don't mimick gravity on space turfs

/mob/living/silicon/robot/has_gravity(turf/T)
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
