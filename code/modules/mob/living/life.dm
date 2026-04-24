/// This divisor controls how fast body temperature changes to match the environment
#define BODYTEMP_DIVISOR 16

/**
 * Handles the biological and general over-time processes of the mob.
 *
 *
 * Arguments:
 * - delta_time: The amount of time that has elapsed since this last fired.
 * - times_fired: The number of times SSmobs has fired
 */
/mob/living/proc/Life(delta_time = SSMOBS_DT, times_fired)
	set waitfor = FALSE
	set invisibility = 0

	SEND_SIGNAL(src, COMSIG_LIVING_LIFE, delta_time, times_fired)

	if (notransform)
		return
	if(!loc)
		return

	if(!has_status_effect(/datum/status_effect/grouped/stasis))

		if(stat != DEAD)
			//Mutations and radiation
			handle_mutations(delta_time, times_fired)
			//Breathing, if applicable
			handle_breathing(delta_time, times_fired)

		handle_diseases(delta_time, times_fired)// DEAD check is in the proc itself; we want it to spread even if the mob is dead, but to handle its disease-y properties only if you're not.

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return

		if(stat != DEAD)
			//Random events (vomiting etc)
			handle_random_events(delta_time, times_fired)

		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment, delta_time, times_fired)

		handle_gravity(delta_time, times_fired)

		if(stat != DEAD)
			handle_traits(delta_time, times_fired) // eye, ear, brain damages

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(delta_time, times_fired)
	// SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, delta_time, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, SSMOBS_DT, times_fired)
	return

/mob/living/proc/handle_mutations(delta_time, times_fired)
	return

/mob/living/proc/handle_diseases(delta_time, times_fired)
	return

//mob/living/proc/handle_wounds(delta_time, times_fired)
//	return

/mob/living/proc/handle_random_events(delta_time, times_fired)
	return

// Base mob environment handler for body temperature
/mob/living/proc/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	var/loc_temp = get_temperature(environment)
	var/temp_delta = loc_temp - bodytemperature

	if(temp_delta < 0) // it is cold here
		if(!on_fire) // do not reduce body temp when on fire
			adjust_bodytemperature(max(max(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_COOLING_MAX) * delta_time, temp_delta))
	else // this is a hot place
		adjust_bodytemperature(min(min(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_HEATING_MAX) * delta_time, temp_delta))


/mob/living/proc/handle_traits(delta_time, times_fired)
	//Eyes
	if(eye_blind) //blindness, heals slowly over time
		if(HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED)) //covering your eyes heals blurry eyes faster
			adjust_blindness(-1.5 * delta_time)
		else if(!stat && !(HAS_TRAIT(src, TRAIT_BLIND)))
			adjust_blindness(-0.5 * delta_time)

/**
 * Get the fullness of the mob
 *
 * This returns a value form 0 upwards to represent how full the mob is.
 * The value is a total amount of consumable reagents in the body combined
 * with the total amount of nutrition they have.
 * This does not have an upper limit.
 */
/mob/living/proc/get_fullness()
	var/fullness = nutrition
	// we add the nutrition value of what we're currently digesting
	for(var/bile in reagents.reagent_list)
		var/datum/reagent/consumable/bits = bile
		if(bits)
			fullness += bits.get_nutriment_factor(src) * bits.volume / bits.metabolization_rate
	return fullness

/**
 * Check if the mob contains this reagent.
 *
 * This will validate the the reagent holder for the mob and any sub holders contain the requested reagent.
 * Vars:
 * * reagent (typepath) takes a PATH to a reagent.
 * * amount (int) checks for having a specific amount of that chemical.
 * * needs_metabolizing (bool) takes into consideration if the chemical is matabolizing when it's checked.
 */
/mob/living/proc/has_reagent(reagent, amount = -1, needs_metabolizing = FALSE)
	return reagents.has_reagent(reagent, amount, needs_metabolizing)

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_gravity(delta_time, times_fired)
	if(gravity_state > STANDARD_GRAVITY)
		handle_high_gravity(gravity_state, delta_time, times_fired)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	animate(get_filter("gravity"), y = 1, time = 10, loop = -1)
	animate(y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity, delta_time, times_fired)
	if(gravity < GRAVITY_DAMAGE_THRESHOLD) //Aka gravity values of 3 or more
		return

	var/grav_strength = gravity - GRAVITY_DAMAGE_THRESHOLD
	adjustBruteLoss(min(GRAVITY_DAMAGE_SCALING * grav_strength, GRAVITY_DAMAGE_MAXIMUM) * delta_time)

#undef BODYTEMP_DIVISOR
