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

	SEND_SIGNAL(src, COMSIG_LIVING_LIFE, delta_time, times_fired)

	if (notransform)
		return
	if(!loc)
		return

	if(!has_status_effect(/datum/status_effect/grouped/stasis))

		if(stat != DEAD)
			//Mutations and radiation
			handle_mutations_and_radiation(delta_time, times_fired)

		if(stat != DEAD)
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
			handle_status_effects(delta_time, times_fired) //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

	handle_fire(delta_time, times_fired)

	if(machine)
		machine.check_eye(src)

	if(stat != DEAD)
		return 1

/mob/living/proc/handle_breathing(delta_time, times_fired)
	// SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, delta_time, times_fired)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, SSMOBS_DT, times_fired)
	return

/mob/living/proc/handle_mutations_and_radiation(delta_time, times_fired)
	radiation = 0 //so radiation don't accumulate in simple animals
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

/mob/living/proc/handle_fire(delta_time, times_fired)
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + (0.5 * delta_time)) //So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return TRUE //the mob is no longer on fire, no need to do the rest.
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.05 * delta_time) //the fire is slowly consumed
	else
		ExtinguishMob()
		return TRUE //mob was put out, on_fire = FALSE via ExtinguishMob(), no need to update everything down the chain.
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(GET_MOLES(/datum/gas/oxygen, G) < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return TRUE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 25 * delta_time, TRUE)

//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects(delta_time, times_fired)
	if(confused)
		confused = max(0, confused - (1 * delta_time))

/mob/living/proc/handle_traits(delta_time, times_fired)
	//Eyes
	if(eye_blind) //blindness, heals slowly over time
		if(HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED)) //covering your eyes heals blurry eyes faster
			adjust_blindness(-1.5 * delta_time)
		else if(!stat && !(HAS_TRAIT(src, TRAIT_BLIND)))
			adjust_blindness(-0.5 * delta_time)
	else if(eye_blurry) //blurry eyes heal slowly
		adjust_blurriness(-0.5 * delta_time)

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_gravity(seconds_per_tick, times_fired)
	if(gravity_state > STANDARD_GRAVITY)
		handle_high_gravity(gravity_state, seconds_per_tick, times_fired)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	animate(get_filter("gravity"), y = 1, time = 10, loop = -1)
	animate(y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity, seconds_per_tick, times_fired)
	if(gravity < GRAVITY_DAMAGE_THRESHOLD) //Aka gravity values of 3 or more
		return

	var/grav_strength = gravity - GRAVITY_DAMAGE_THRESHOLD
	adjustBruteLoss(min(GRAVITY_DAMAGE_SCALING * grav_strength, GRAVITY_DAMAGE_MAXIMUM) * seconds_per_tick)

#undef BODYTEMP_DIVISOR
