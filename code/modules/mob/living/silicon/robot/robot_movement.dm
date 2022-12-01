/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE
	if(has_jetpack_power(movement_dir, require_stabilization = FALSE))
		return TRUE
	return FALSE

/mob/living/silicon/robot/can_zFall(turf/source, levels, turf/target, direction)
	if(!..())
		return FALSE
	// Jetpack allows flight over openspace
	if(has_jetpack_power(TRUE, thrust = THRUST_REQUIREMENT_GRAVITY))
		// Render particles to show we are using fuel
		var/obj/effect/particle_effect/ion_trails/E = new(get_turf(src))
		flick("ion_fade", E)
		E.icon_state = ""
		QDEL_IN(E, 5)
		return FALSE
	return TRUE

/mob/living/silicon/robot/has_jetpack_power(movement_dir, thrust = THRUST_REQUIREMENT_SPACEMOVE, require_stabilization)
	if(..())
		return TRUE
	if(ionpulse(thrust))
		return TRUE
	return FALSE

/mob/living/silicon/robot/mob_negates_gravity()
	return isspaceturf(get_turf(src)) ? FALSE : magpulse //We don't mimick gravity on space turfs

/mob/living/silicon/robot/has_gravity(turf/T)
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
