//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 45

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	anchored = TRUE
	light_range = 3

	var/obj/item/assembly/signaler/anomaly/aSignal = /obj/item/assembly/signaler/anomaly
	var/area/impact_area

	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we keep on living forever?
	var/immortal = FALSE
	///How many harvested pierced realities do we spawn on destruction
	var/max_spawned_faked = 2

/obj/effect/anomaly/Initialize(mapload, new_lifespan, spawned_fake_harvested)
	. = ..()

	AddElement(/datum/element/point_of_interest)

	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	aSignal = new(src)
	aSignal.name = "[name] core"
	aSignal.code = rand(1,100)
	aSignal.anomaly_type = type

	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.set_frequency(frequency)

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan

	if(spawned_fake_harvested)
		max_spawned_faked = spawned_fake_harvested

	if(immortal)
		return // no countdown for forever anomalies
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()

/obj/effect/anomaly/process(delta_time)
	anomalyEffect(delta_time)
	if(death_time < world.time && !immortal)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	return ..()

/obj/effect/anomaly/proc/anomalyEffect(delta_time)
	if(DT_PROB(ANOMALY_MOVECHANCE, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity, target)
	if(severity == 1)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/smoke/bad(loc)

	for(var/atom/movable/O in src)
		O.forceMove(drop_location())

	qdel(src)

/obj/effect/anomaly/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code].</span>")

#undef ANOMALY_MOVECHANCE
