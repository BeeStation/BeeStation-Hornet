SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize()
#ifndef UNIT_TESTS
	trigger_migration(CONFIG_GET(number/mice_roundstart))
#endif
	place_satchels()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/minor_mapping/proc/trigger_migration(to_spawn=10)
	var/list/exposed_wires = find_exposed_wires()
	var/turf/proposed_turf
	while((to_spawn > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)
		if (!valid_mouse_turf(proposed_turf))
			continue

		to_spawn--
		new /mob/living/basic/mouse(proposed_turf)

/// Returns true if a mouse won't die if spawned on this turf
/datum/controller/subsystem/minor_mapping/proc/valid_mouse_turf(turf/open/proposed_turf)
	if(!istype(proposed_turf))
		return FALSE
	var/datum/gas_mixture/turf/turf_gasmix = proposed_turf.air
	var/turf_temperature = proposed_turf.temperature
	return turf_gasmix.has_gas(/datum/gas/oxygen, 5) && turf_temperature < NPC_DEFAULT_MAX_TEMP && turf_temperature > NPC_DEFAULT_MIN_TEMP

/datum/controller/subsystem/minor_mapping/proc/place_satchels(amount=10)
	var/list/turfs = find_satchel_suitable_turfs()

	while(turfs.len && amount > 0)
		var/turf/T = pick_n_take(turfs)
		var/obj/item/storage/backpack/satchel/flat/F = new(T)

		SEND_SIGNAL(F, COMSIG_OBJ_HIDE, T.underfloor_accessibility)
		amount--

/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += block(locate(1,1,z), locate(world.maxx,world.maxy,z))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(T.is_blocked_turf())
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T

	return shuffle(exposed_wires)

/proc/find_satchel_suitable_turfs()
	var/list/suitable = list()

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/detected_turf as anything in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			if(isfloorturf(detected_turf) && detected_turf.underfloor_accessibility == UNDERFLOOR_HIDDEN)
				suitable += detected_turf

	return shuffle(suitable)
