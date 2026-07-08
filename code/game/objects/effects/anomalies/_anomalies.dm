//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "vortex"
	density = FALSE
	anchored = TRUE
	light_range = 3

	/// The anomaly core we drop
	var/obj/item/assembly/signaler/anomaly/anomaly_core = /obj/item/assembly/signaler/anomaly
	/// The area that we were spawned in
	var/area/impact_area
	/// The time we expire
	var/death_time
	/// Our countdown timer
	var/obj/effect/countdown/anomaly/countdown

	/// Do we keep on living forever?
	var/immortal = FALSE
	/// How many harvested pierced realities do we spawn on destruction. Only used by subtypes
	var/max_spawned_faked = 2

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/anomaly)

/obj/effect/anomaly/Initialize(mapload, life_span = 1.5 MINUTES, spawned_fake_harvested)
	. = ..()

	AddElement(/datum/element/point_of_interest)

	START_PROCESSING(SSobj, src)

	anomaly_core = new anomaly_core(src)
	anomaly_core.code = rand(1,100)
	anomaly_core.anomaly_type = type
	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	anomaly_core.set_frequency(frequency)

	death_time = world.time + life_span

	if(spawned_fake_harvested)
		max_spawned_faked = spawned_fake_harvested

	impact_area = get_area(src)

	if(immortal)
		return // no countdown for forever anomalies
	countdown = new(src)
	countdown.start()

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	if(!isnull(anomaly_core))
		QDEL_NULL(anomaly_core)
	return ..()

/obj/effect/anomaly/analyzer_act(mob/living/user, obj/item/tool)
	if(isnull(anomaly_core))
		return
	to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(anomaly_core.frequency)], code [anomaly_core.code]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/effect/anomaly/process(delta_time)
	anomaly_process(delta_time)
	if(death_time < world.time && !immortal)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/ex_act(severity, target)
	if(severity == EXPLODE_DEVASTATE)
		qdel(src)

/// Called every process() tick. Do anomaly stuff here
/obj/effect/anomaly/proc/anomaly_process(delta_time)
	if(DT_PROB(ANOMALY_MOVECHANCE, delta_time))
		step(src, pick(GLOB.alldirs))

/// Called when the anomaly expires. Guaranteed to have a loc when called.
/obj/effect/anomaly/proc/detonate()
	return

/// Called when an anomaly neutralizer is used on this
/obj/effect/anomaly/proc/neutralize()
	new /obj/effect/particle_effect/smoke/bad(loc)

	anomaly_core.forceMove(drop_location())
	anomaly_core = null
	qdel(src)

/**
 * Helper proc to spawn fake pierced realities centered around a turf or around the station
 *
 * Arguments:
 * * centered_turf: The turf to center the influences around, if null, they will be spawned across the station
 * * max_amount: A random amount of influences will be spawned to a maximum of this value
 */
/proc/generate_fake_pierced_realities(turf/center_turf, max_amount = 2)
	if(max_amount <= 0)
		return
	var/to_spawn = rand(1, max_amount)

	var/list/turf/possible_locations
	if(!isnull(center_turf))
		possible_locations = get_teleport_turfs(center = center_turf, precision = 5 * to_spawn)
	else
		possible_locations = get_safe_random_station_turfs(amount = to_spawn)

	while(to_spawn > 0 && length(possible_locations))
		// Regardless of if we spawn a pierced reality or not, we want to remove this turf from the pool.
		// This is because if the turf is found to be invalid, we don't want future runs to loop over it.
		var/turf/chosen_location = pick_n_take(possible_locations)

		if(isspaceturf(chosen_location))
			continue

		// We don't want them close to each other - at least 1 tile of seperation
		var/found_nearby_influence = FALSE
		for(var/atom/nearby_thing as anything in range(1, chosen_location))
			if(istype(nearby_thing, /obj/effect/heretic_influence) || istype(nearby_thing, /obj/effect/visible_heretic_influence))
				found_nearby_influence = TRUE
				break
		if(found_nearby_influence)
			continue

		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_create_new_fake_reality), chosen_location), rand(0 SECONDS, 50 SECONDS))
		to_spawn--

/proc/_create_new_fake_reality(turf/location)
	new /obj/effect/visible_heretic_influence(location)
