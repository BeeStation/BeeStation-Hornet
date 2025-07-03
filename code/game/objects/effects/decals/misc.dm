//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = FLY_LAYER
	///The mob who sourced this puff, if one exists
	var/mob/user
	///The sprayer who fired this puff
	var/obj/item/reagent_containers/spray/sprayer
	///How many interactions we have left before we disappear early
	var/lifetime = INFINITY
	///Are we a part of a stream?
	var/stream

/obj/effect/decal/chempuff/Destroy(force)
	user = null
	sprayer = null
	return ..()

/obj/effect/decal/chempuff/blob_act(obj/structure/blob/B)
	return

/obj/effect/decal/chempuff/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/obj/effect/decal/chempuff/proc/check_move(datum/move_loop/source, succeeded)
	if(QDELETED(src))
		return
	if(!succeeded || lifetime < 0)
		qdel(src)
		return

	var/puff_reagents_string = reagents?.log_list()
	var/travelled_max_distance = (source.lifetime - source.delay <= 0)
	var/turf/our_turf = get_turf(src)

	for(var/atom/movable/turf_atom in our_turf)
		if(lifetime < 0)
			qdel(src)
			break

		//we ignore the puff itself and stuff below the floor
		if(turf_atom == src || turf_atom.invisibility)
			continue

		if(!stream)
			if(ismob(turf_atom))
				lifetime--
		else if(isliving(turf_atom))
			var/mob/living/turf_mob = turf_atom

			if(!turf_mob.can_inject())
				continue
			if(turf_mob.body_position != STANDING_UP && !travelled_max_distance)
				continue

			lifetime--
		else if(travelled_max_distance)
			lifetime--
		reagents?.expose(turf_atom, VAPOR)
		if(user)
			log_combat(user, turf_atom, "sprayed", sprayer, addition="which had [puff_reagents_string]")

	if(lifetime >= 0 && (!stream || travelled_max_distance))
		reagents?.expose(our_turf, VAPOR)
		lifetime--
		if(user)
			log_combat(user, our_turf, "sprayed", sprayer, addition="which had [puff_reagents_string]")

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/catwalks/lattice.dmi'
	icon_state = "lattice-255"
	density = FALSE

/obj/effect/decal/fakestairs
	name = "stairs"
	desc = "A great height, divided into small heights, all for your convenience."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs-p"
	layer = TURF_DECAL_STRIPE_LAYER
	density = FALSE

/obj/effect/decal/fakestairs/newstairs
	icon_state = "stairs-n"

/obj/effect/decal/fakestairs/newstairs/middle
	icon_state = "stairs-m"

/obj/effect/decal/fakestairs/newstairs/right
	icon_state = "stairs-r"

/obj/effect/decal/fakestairs/newstairs/left
	icon_state = "stairs-l"

/obj/effect/decal/fakestairs/Initialize(mapload)
	. = ..()
	var/turf/open/floor/T = get_turf(src)
	if(istype(T, /turf/open/floor))
		T.slowdown = 2
