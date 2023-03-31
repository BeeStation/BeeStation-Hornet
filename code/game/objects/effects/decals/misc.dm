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
			if(!(turf_mob.mobility_flags & MOBILITY_STAND) && !travelled_max_distance)
				continue

			lifetime--
		else if(travelled_max_distance)
			lifetime--
		reagents?.reaction(turf_atom, VAPOR)
		if(user)
			log_combat(user, turf_atom, "sprayed", sprayer, addition="which had [puff_reagents_string]")

	if(lifetime >= 0 && (!stream || travelled_max_distance))
		reagents?.reaction(our_turf, VAPOR)
		lifetime--
		if(user)
			log_combat(user, our_turf, "sprayed", sprayer, addition="which had [puff_reagents_string]")

/obj/effect/decal/fakelattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/catwalks/lattice.dmi'
	icon_state = "lattice"
	density = TRUE
