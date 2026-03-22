#define DELAM_MAX_DEVASTATION 17.5

// These are supposed to be discrete effects so we can tell at a glance what does each override
// of [/datum/sm_delam/proc/delaminate] does.
// Please keep them discrete and give them proper, descriptive function names.
// Oh and all of them returns true if the effect succeeded.

/// Irradiates mobs around 20 tiles of the sm.
/// Just the mobs apparently.
/datum/sm_delam/proc/effect_irradiate(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim in range(DETONATION_RADIATION_RANGE, sm))
		if(!is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue

		SSradiation.irradiate(victim, intensity = 50)

	return TRUE

/// Hallucinates and makes mobs in Z level sad.
/datum/sm_delam/proc/effect_demoralize(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || !is_valid_z_level(get_turf(victim), sm_turf))
			continue
		if(victim.z == 0)
			continue

		//Hilariously enough, running into a closet should make you get hit the hardest.
		//duration between min and max, calculated by distance from the supermatter and size of the delam explosion

		var/hallucination_amount = LERP(DETONATION_HALLUCINATION_MIN, DETONATION_HALLUCINATION_MAX, 1 - get_dist(victim, sm) / 128) * LERP(0.75, 1.25, calculate_explosion(sm) * 0.5 / DELAM_MAX_DEVASTATION)
		victim.adjust_hallucinations(hallucination_amount)

	for(var/mob/victim in GLOB.player_list)
		var/turf/victim_turf = get_turf(victim)
		if(!is_valid_z_level(victim_turf, sm_turf))
			continue
		victim.playsound_local(victim_turf, 'sound/magic/charge.ogg')
		if(victim.z == 0) //victim is inside an object, this is to maintain an old bug turned feature with lockers n shit i guess. tg issue #69687
			var/message = ""
			var/location = victim.loc
			if(istype(location, /obj/structure/disposalholder)) // sometimes your loc can be a disposalsholder when you're inside a disposals type, so let's just pass a message that makes sense.
				message = "You hear a lot of rattling in the disposal pipes around you as reality itself distorts. Yet, you feel safe."
			else
				message = "You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."
			to_chat(victim, span_bolddanger(message))
			continue

		to_chat(victim, span_bolddanger("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)
	return TRUE

/// Spawns anomalies all over the station. Half instantly, the other half over time.
/datum/sm_delam/proc/effect_anomaly(obj/machinery/power/supermatter_crystal/sm)
	var/anomalies = 10
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DIMENSIONAL_ANOMALY = 35, BIOSCRAMBLER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	// Spawns this many anomalies instantly. Spawns the rest with callbacks.
	var/cutoff_point = round(anomalies * 0.5, 1)

	for(var/i in 1 to anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)

		if(i < cutoff_point)
			supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)
			continue

		var/current_spawn = rand(5 SECONDS, 10 SECONDS)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(supermatter_anomaly_gen), anomaly_location, anomaly_to_spawn, TRUE), current_spawn + extended_spawn)
	return TRUE

/// Explodes
/datum/sm_delam/proc/effect_explosion(obj/machinery/power/supermatter_crystal/sm)
	explosion(
		epicenter = get_turf(sm),
		devastation_range = calculate_explosion(sm) * 0.5, // 17.5 at SUPERMATTER_CRITICAL_TIME define.
		heavy_impact_range = calculate_explosion(sm) + 2, // 37
		light_impact_range = calculate_explosion(sm) + 4, // 39
		flash_range = calculate_explosion(sm) + 6, // 41
		adminlog = TRUE,
		ignorecap = TRUE,
	)
	return TRUE

/datum/sm_delam/proc/calculate_explosion(obj/machinery/power/supermatter_crystal/sm)
	return sm.explosion_power * max(sm.gas_heat_power_generation, 0.205) * min(((world.time - sm.activation_time) / SUPERMATTER_CRITICAL_TIME), 2) //energy builds over time for explosions

/// Spawns a scrung and eat the SM.
/datum/sm_delam/proc/effect_singulo(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn singularity, cant get current turf.")
		return FALSE
	var/obj/anomaly/singularity/created_singularity = new(sm_turf)
	created_singularity.energy = 800
	created_singularity.consume(sm)
	return TRUE

/// Teslas
/datum/sm_delam/proc/effect_tesla(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		stack_trace("Supermatter [sm] failed to spawn tesla, cant get current turf.")
		return FALSE

	var/obj/anomaly/energy_ball/created_tesla = new(sm_turf)
	created_tesla.energy = 200 //Gets us about 9 balls
	return TRUE

#undef DELAM_MAX_DEVASTATION
