//Plutonium sludge

#define PLUTONIUM_SLUDGE_RANGE 5
#define PLUTONIUM_SLUDGE_RANGE_STRONG 10
#define PLUTONIUM_SLUDGE_RANGE_WEAK 3

#define PLUTONIUM_SLUDGE_CHANCE 35


/obj/modules/power/rbmk/nuclear_sludge_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "nuclear waste spawner"
	var/range = PLUTONIUM_SLUDGE_RANGE //tile radius to spawn goop
	var/center_sludge = TRUE // Whether or not the center turf should spawn sludge or not.
	var/static/list/avoid_objs = typecacheof(list( // List of objs that the waste does not spawn on
		/obj/structure/stairs, // Sludge is hidden below stairs
		/obj/structure/ladder, // Going down the ladder directly on sludge bad
		/obj/effect/decal/cleanable/nuclear_waste, // No stacked sludge
		/obj/structure/girder,
		/obj/structure/grille,
		/obj/structure/window/fulltile,
		/obj/structure/window/plasma/fulltile,
		/obj/structure/window/plasma/reinforced/fulltile,
		/obj/structure/window/plastitanium,
		/obj/structure/window/reinforced/fulltile,
		/obj/structure/window/reinforced/clockwork/fulltile,
		/obj/structure/window/reinforced/tinted/fulltile,
		/obj/structure/window,
		/obj/structure/window/shuttle,
		/obj/machinery/gateway,
		/obj/machinery/gravity_generator,
		))
/// Tries to place plutonium sludge on 'floor'. Returns TRUE if the turf has been successfully processed, FALSE otherwise.
/obj/modules/power/rbmk/nuclear_sludge_spawner/proc/place_sludge(turf/open/floor, epicenter = FALSE)
	if(!floor)
		return FALSE

	if(epicenter)
		for(var/obj/effect/decal/cleanable/nuclear_waste/waste in floor) //Replace nuclear waste with the stronger version
			qdel(waste)
		new /obj/effect/decal/cleanable/nuclear_waste/epicenter (floor)
		return TRUE

	if(!prob(PLUTONIUM_SLUDGE_CHANCE)) //Scatter the sludge, don't smear it everywhere
		return TRUE

	for(var/obj/O in floor)
		if(avoid_objs[O.type])
			return TRUE

	new /obj/effect/decal/cleanable/nuclear_waste (floor)
	return TRUE

/obj/modules/power/rbmk/nuclear_sludge_spawner/strong
	range = PLUTONIUM_SLUDGE_RANGE_STRONG

/obj/modules/power/rbmk/nuclear_sludge_spawner/weak
	range = PLUTONIUM_SLUDGE_RANGE_WEAK
	center_sludge = FALSE

/obj/modules/power/rbmk/nuclear_sludge_spawner/proc/fire()
	playsound(src, 'sound/effects/gib_step.ogg', 100)

	if(center_sludge)
		place_sludge(get_turf(src), TRUE)

	for(var/turf/open/floor in orange(range, get_turf(src)))
		place_sludge(floor, FALSE)

	qdel(src)

#undef PLUTONIUM_SLUDGE_RANGE
#undef PLUTONIUM_SLUDGE_RANGE_STRONG
#undef PLUTONIUM_SLUDGE_RANGE_WEAK
#undef PLUTONIUM_SLUDGE_CHANCE
