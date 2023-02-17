SUBSYSTEM_DEF(liquids)
	name = "Liquid Turfs"
	wait = 0.5 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/active_groups = list()

	var/list/evaporation_queue = list()
	var/evaporation_counter = 0 //Only process evaporation on intervals

	var/list/singleton_immutables = list()

	var/list/active_ocean_turfs = list()
	var/list/ocean_turfs = list()
	var/list/currentrun_active_ocean_turfs = list()
	var/list/unvalidated_oceans = list()
	var/ocean_counter = 0

	var/run_type = SSLIQUIDS_RUN_TYPE_TURFS

	///debug variable to toggle evaporation from running
	var/debug_evaporation = FALSE

	var/list/burning_turfs = list()
	var/fire_counter = 0

/datum/controller/subsystem/liquids/stat_entry(msg)
	msg += "AG:[active_groups.len]|BT:[burning_turfs.len]|EQ:[evaporation_queue.len]|AO:[active_ocean_turfs.len]|UO:[length(unvalidated_oceans)]"
	return ..()

/datum/controller/subsystem/liquids/fire(resumed = FALSE)
	if(!active_groups.len && !evaporation_queue.len && !active_ocean_turfs.len && !burning_turfs.len && !unvalidated_oceans.len)
		return

	if(length(unvalidated_oceans))
		for(var/turf/open/floor/plating/ocean/unvalidated_turf in unvalidated_oceans)
			unvalidated_turf.assume_self()

	if(active_groups.len)
		for(var/g in active_groups)
			var/datum/liquid_group/LG = g
			if(length(LG.burning_members))
				for(var/turf/burning_turf in LG.burning_members)
					LG.process_spread(burning_turf)

			LG.process_cached_edges()
			LG.process_group()
		run_type = SSLIQUIDS_RUN_TYPE_EVAPORATION

	if(run_type == SSLIQUIDS_RUN_TYPE_EVAPORATION && !debug_evaporation)
		run_type = SSLIQUIDS_RUN_TYPE_FIRE
		evaporation_counter++
		if(evaporation_counter >= REQUIRED_EVAPORATION_PROCESSES)
			evaporation_counter = 0
			for(var/g in active_groups)
				var/datum/liquid_group/LG = g
				LG.check_dead()
				LG.process_turf_disperse()
			for(var/t in evaporation_queue)
				var/turf/T = t
				if(T.liquids)
					if(prob(EVAPORATION_CHANCE))
						T.liquids.process_evaporation()
				else
					evaporation_queue -= T

	if(run_type == SSLIQUIDS_RUN_TYPE_FIRE)
		fire_counter++
		if(fire_counter > REQUIRED_FIRE_PROCESSES)
			for(var/g in active_groups)
				if(MC_TICK_CHECK)
					return
				var/datum/liquid_group/LG = g
				if(LG.burning_members.len)
					for(var/turf/burning_turf in LG.burning_members)
						LG.process_spread(burning_turf)
					LG.process_fire()
			fire_counter = 0

	run_type = SSLIQUIDS_RUN_TYPE_OCEAN
	if(!currentrun_active_ocean_turfs.len)
		currentrun_active_ocean_turfs = active_ocean_turfs
	if(run_type == SSLIQUIDS_RUN_TYPE_OCEAN)
		ocean_counter++
		if(ocean_counter >= REQUIRED_OCEAN_PROCESSES)
			for(var/turf/open/floor/plating/ocean/active_ocean in currentrun_active_ocean_turfs)
				if(MC_TICK_CHECK)
					return
				active_ocean.process_turf()
			ocean_counter = 0

/client/proc/toggle_liquid_debug()
	set category = "Debug"
	set name = "Liquid Groups Color Debug"
	set desc = "Liquid Groups Color Debug."
	if(!holder)
		return
	GLOB.liquid_debug_colors = !GLOB.liquid_debug_colors
