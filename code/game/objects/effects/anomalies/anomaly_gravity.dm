/atom/movable/warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/288x288.dmi'
	icon_state = "gravitational_anti_lens"
	pixel_x = -126
	pixel_y = -128

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "gravity"
	density = FALSE
	anomaly_core = /obj/item/assembly/signaler/anomaly/grav
	var/boing = FALSE
	///Warp effect holder for displacement filter to "pulse" the anomaly
	var/atom/movable/warp_effect/warp

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/anomaly/grav)

/obj/effect/anomaly/grav/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	warp = new(src)
	vis_contents += warp

/obj/effect/anomaly/grav/Destroy()
	vis_contents -= warp
	QDEL_NULL(warp)
	return ..()

/obj/effect/anomaly/grav/anomaly_process(delta_time)
	. = ..()
	boing = TRUE

	var/list/mob/living/nearby_people
	var/turf/our_turf = get_turf(src)
	for(var/atom/thing_on_us as anything in our_turf)
		if(isliving(thing_on_us))
			grav_shock(thing_on_us)
			continue

		if(!isobj(thing_on_us))
			continue
		var/obj/obj_on_us = thing_on_us
		if(obj_on_us.anchored)
			continue

		if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(obj_on_us, TRAIT_T_RAY_VISIBLE))
			continue

		nearby_people ||= hearers(4, src)
		var/mob/living/target = locate() in nearby_people
		if(target?.stat == CONSCIOUS)
			obj_on_us.throw_at(target, 5, 10)

	for(var/atom/nearby_thing as anything in orange(4, src))
		if(isobj(nearby_thing))
			var/obj/nearby_obj = nearby_thing
			if(nearby_obj.anchored)
				continue
		else if(isliving(nearby_thing))
			var/mob/living/nearby_living = nearby_thing
			if(nearby_living.mob_negates_gravity())
				continue
		else
			continue
		step_towards(nearby_thing, src)

	//anomaly quickly contracts then slowly expands it's ring
	animate(warp, time = delta_time*3, transform = matrix().Scale(0.5,0.5))
	animate(time = delta_time*7, transform = matrix())

/obj/effect/anomaly/grav/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	grav_shock(AM)

/obj/effect/anomaly/grav/Bump(mob/A)
	grav_shock(A)

/obj/effect/anomaly/grav/Bumped(atom/movable/AM)
	grav_shock(AM)

/obj/effect/anomaly/grav/proc/grav_shock(mob/living/mob_to_grav)
	if(!boing || !istype(mob_to_grav) || mob_to_grav.stat != CONSCIOUS)
		return
	mob_to_grav.Paralyze(4 SECONDS)
	var/atom/target = get_edge_target_turf(mob_to_grav, get_dir(src, get_step_away(mob_to_grav, src)))
	mob_to_grav.throw_at(target, 5, 1)
	boing = FALSE

/obj/effect/anomaly/grav/high
	var/datum/proximity_monitor/advanced/gravity/grav_field

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/anomaly/grav/high)

/obj/effect/anomaly/grav/high/Initialize(mapload, new_lifespan)
	. = ..()
	setup_grav_field()

/obj/effect/anomaly/grav/high/proc/setup_grav_field()
	grav_field = new(src, 7, TRUE, rand(0, 3))

/obj/effect/anomaly/grav/high/Destroy()
	QDEL_NULL(grav_field)
	return ..()
