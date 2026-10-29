#define PLUTONIUM_SLUDGE_RANGE 50
#define PLUTONIUM_SLUDGE_RANGE_STRONG 80

#define PLUTONIUM_SLUDGE_CHANCE 15

/obj/effect/nuclear_sludge_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "nuclear waste spawner"
	/// tile radius to spawn goop
	var/range = PLUTONIUM_SLUDGE_RANGE
	/// List of objs that the waste does not spawn on
	var/static/list/avoid_objs = typecacheof(list(
		/obj/structure/stairs, // Sludge is hidden below stairs
		/obj/structure/ladder, // Going down the ladder directly on sludge bad
		/obj/effect/decal/cleanable/nuclear_waste, // No stacked sludge
	))

/// Tries to place plutonium sludge on 'floor'. Returns TRUE if the turf has been successfully processed, FALSE otherwise.
/obj/effect/nuclear_sludge_spawner/proc/place_sludge(turf/open/floor, epicenter = FALSE)
	if(!prob(PLUTONIUM_SLUDGE_CHANCE)) //Scatter the sludge, don't smear it everywhere
		return

	for(var/obj/object in floor)
		if(object.density || object.layer >= layer)
			return
		if(avoid_objs[object.type])
			return

	new /obj/effect/decal/cleanable/nuclear_waste(floor)

/obj/effect/nuclear_sludge_spawner/strong
	range = PLUTONIUM_SLUDGE_RANGE_STRONG

/obj/effect/nuclear_sludge_spawner/proc/fire()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return

	playsound(src, 'sound/effects/gib_step.ogg', 100)

	for(var/turf/open/floor in RANGE_TURFS(range, get_turf(src)))
		place_sludge(floor)

	qdel(src)

#undef PLUTONIUM_SLUDGE_RANGE
#undef PLUTONIUM_SLUDGE_RANGE_STRONG
#undef PLUTONIUM_SLUDGE_CHANCE
