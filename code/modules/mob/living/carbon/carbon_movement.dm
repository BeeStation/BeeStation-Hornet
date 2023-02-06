/mob/living/carbon/movement_delay()
	. = ..()

	if(!get_leg_ignore() && legcuffed) //ignore the fact we lack legs
		. += legcuffed.slowdown

/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	if(movement_type & FLYING)
		return 0
	if(!(lube&SLIDE_ICE))
		log_combat(src, (O ? O : get_turf(src)), "slipped on the", null, ((lube & SLIDE) ? "(LUBE)" : null))
	return loc.handle_slip(src, knockdown_amount, O, lube, paralyze, force_drop)

/mob/living/carbon/Process_Spacemove(movement_dir = FALSE)
	if(..())
		return TRUE
	if(!isturf(loc))
		return FALSE

	// Do we have a jetpack implant (and is it on)?
	if(has_jetpack_power(movement_dir))
		return TRUE

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

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(. && !(movement_type & FLOATING)) //floating is easy
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			set_nutrition(NUTRITION_LEVEL_FED - 1)	//just less than feeling vigorous
		else if(nutrition && stat != DEAD)
			adjust_nutrition(-(HUNGER_FACTOR/10))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(HUNGER_FACTOR/10))
