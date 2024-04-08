// Handles wearing jetpacks preventing zfalls
/mob/living/carbon/can_zFall(turf/source, turf/target, direction)
	if(!..())
		return FALSE
	// Jetpack allows flight over openspace
	if(has_jetpack_power(TRUE, thrust = THRUST_REQUIREMENT_GRAVITY))
		var/obj/item/tank/jetpack/J = get_jetpack()
		if(istype(J) && J.use_ion_trail)
			// Render particles to show we are using fuel
			var/obj/effect/particle_effect/ion_trails/E = new(get_turf(src))
			flick("ion_fade", E)
			E.icon_state = ""
			QDEL_IN(E, 5)
		return FALSE
	return TRUE
