SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_deferred_airs
	var/cost_hotspots = 0
	var/cost_post_process = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_rebuilds = 0
	var/cost_atmos_machinery = 0
	var/cost_equalize = 0
	var/thread_wait_ticks = 0
	var/cur_thread_wait_ticks = 0
	///The last time the subsystem completely processed
	var/last_complete_process = 0

	var/low_pressure_turfs = 0
	var/high_pressure_turfs = 0

	var/num_group_turfs_processed = 0
	var/num_equalize_processed = 0

	var/list/hotspots = list()
	var/list/networks = list()
	var/list/pipenets_needing_rebuilt = list()
	var/list/deferred_airs = list()
	var/max_deferred_airs = 0
	var/list/obj/machinery/atmos_machinery = list()
	var/list/obj/machinery/atmos_air_machinery = list()
	var/list/pipe_init_dirs_cache = list()

	//atmos singletons
	var/list/gas_reactions = list()

	//Special functions lists
	var/list/turf/open/high_pressure_delta = list()


	var/list/currentrun = list()
	var/currentpart = SSAIR_REBUILD_PIPENETS

	var/map_loading = TRUE

	var/log_explosive_decompression = TRUE // If things get spammy, admemes can turn this off.

	// Max number of turfs equalization will grab.
	var/equalize_turf_limit = 10
	// Max number of turfs to look for a space turf, and max number of turfs that will be decompressed.
	var/equalize_hard_turf_limit = 2000
	// Whether equalization should be enabled at all.
	var/equalize_enabled = FALSE
	// Whether turf-to-turf heat exchanging should be enabled.
	var/heat_enabled = FALSE
	// Max number of times process_turfs will share in a tick.
	var/share_max_steps = 3
	// Excited group processing will try to equalize groups with total pressure difference less than this amount.
	var/excited_group_pressure_goal = 1

	var/list/paused_z_levels	//Paused z-levels will not add turfs to active
	var/list/unpausing_z_levels = list()
	var/list/unpause_processing = list()

	var/list/pausing_z_levels = list()
	var/list/pause_processing = list()

/datum/controller/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "HP:[round(cost_highpressure,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "HE:[round(heat_process_time(),1)]|"
	msg += "SC:[round(cost_superconductivity,1)]|"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]"
	msg += "} "
	msg += "TC:{"
	msg += "AT:[round(cost_turfs,1)]|"
	msg += "EG:[round(cost_groups,1)]|"
	msg += "EQ:[round(cost_equalize,1)]|"
	msg += "PO:[round(cost_post_process,1)]"
	msg += "}"
	msg += "TH:[round(thread_wait_ticks,1)]|"
	msg += "HS:[hotspots.len]|"
	msg += "PN:[networks.len]|"
	msg += "HP:[high_pressure_delta.len]|"
	msg += "HT:[high_pressure_turfs]|"
	msg += "LT:[low_pressure_turfs]|"
	msg += "ET:[num_equalize_processed]|"
	msg += "GT:[num_group_turfs_processed]|"
	msg += "DF:[max_deferred_airs]|"
	msg += "GA:[get_amt_gas_mixes()]|"
	msg += "MG:[get_max_gas_mixes()]"
	return ..()

/datum/controller/subsystem/air/Initialize(timeofday)
	map_loading = FALSE
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	gas_reactions = init_gas_reactions()
	auxtools_update_reactions()
	return ..()

/datum/controller/subsystem/air/proc/extools_update_ssair()

/datum/controller/subsystem/air/proc/auxtools_update_reactions()

/proc/reset_all_air()
	SSair.can_fire = 0
	message_admins("Air reset begun.")
	for(var/turf/open/T in world)
		T.Initalize_Atmos(0)
		CHECK_TICK
	message_admins("Air reset done.")
	SSair.can_fire = 1

/datum/controller/subsystem/air/proc/thread_running()
	return FALSE

/proc/fix_corrupted_atmos()

/datum/admins/proc/fixcorruption()
	set category = "Debug"
	set desc="Fixes air that has weird NaNs (-1.#IND and such). Hopefully."
	set name="Fix Infinite Air"
	fix_corrupted_atmos()

/datum/controller/subsystem/air/fire(resumed = 0)

	var/timer = TICK_USAGE_REAL

		//If we have unpausing z-level, process them first
	if(length(unpausing_z_levels) && !length(unpause_processing))
		var/z_value = unpausing_z_levels[1]
		unpausing_z_levels.Remove(z_value)
		unpause_processing = block(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value))

	while(length(unpause_processing))
		var/turf/T = unpause_processing[length(unpause_processing)]
		if(!isspaceturf(T))	//Skip space turfs, since they won't have atmos
			T.Initalize_Atmos()
		//Goodbye
		unpause_processing.len --
		//We overran this tick, stop processing
		//This may result in a very brief atmos freeze when running unpause_z at high loads
		//but that is better than freezing the entire MC
		if(MC_TICK_CHECK)
			return

	//If we have unpausing z-level, process them first
	if(length(pausing_z_levels) && !length(pause_processing))
		var/z_value = pausing_z_levels[1]
		pausing_z_levels.Remove(z_value)
		pause_processing = block(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value))

	while(length(pause_processing))
		var/turf/T = pause_processing[length(pause_processing)]
		T.ImmediateDisableAdjacency()
		//Goodbye
		pause_processing.len --
		//We overran this tick, stop processing
		//This may result in a very brief atmos freeze when running unpause_z at high loads
		//but that is better than freezing the entire MC
		if(MC_TICK_CHECK)
			return

	if(currentpart == SSAIR_REBUILD_PIPENETS)
		timer = TICK_USAGE_REAL
		var/list/pipenet_rebuilds = pipenets_needing_rebuilt
		for(var/thing in pipenet_rebuilds)
			var/obj/machinery/atmospherics/AT = thing
			if(!istype(AT))
				continue
			AT.build_network()
		cost_rebuilds = MC_AVERAGE(cost_rebuilds, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		pipenets_needing_rebuilt.Cut()
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_PIPENETS

	if(currentpart == SSAIR_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY
	// This is only machinery like filters, mixers that don't interact with air
	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		process_atmos_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HIGHPRESSURE

	if(currentpart == SSAIR_HIGHPRESSURE)
		timer = TICK_USAGE_REAL
		process_high_pressure_delta(resumed)
		cost_highpressure = MC_AVERAGE(cost_highpressure, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_FINALIZE_TURFS
	// This literally just waits for the turf processing thread to finish, doesn't do anything else.
	// this is necessary cause the next step after this interacts with the air--we get consistency
	// issues if we don't wait for it, disappearing gases etc.
	if(currentpart == SSAIR_FINALIZE_TURFS)
		finish_turf_processing(resumed)
		if(state != SS_RUNNING)
			cur_thread_wait_ticks++
			return
		resumed = 0
		thread_wait_ticks = MC_AVERAGE(thread_wait_ticks, cur_thread_wait_ticks)
		cur_thread_wait_ticks = 0
		currentpart = SSAIR_DEFERRED_AIRS
	if(currentpart == SSAIR_DEFERRED_AIRS)
		timer = TICK_USAGE_REAL
		process_deferred_airs(resumed)
		cost_deferred_airs = MC_AVERAGE(cost_deferred_airs, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY_AIR
	if(currentpart == SSAIR_ATMOSMACHINERY_AIR)
		timer = TICK_USAGE_REAL
		process_atmos_air_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = TICK_USAGE_REAL
		process_hotspots(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = heat_enabled ? SSAIR_TURF_CONDUCTION : SSAIR_ACTIVETURFS
	// Heat -- slow and of questionable usefulness. Off by default for this reason. Pretty cool, though.
	if(currentpart == SSAIR_TURF_CONDUCTION)
		timer = TICK_USAGE_REAL
		if(process_turf_heat(MC_TICK_REMAINING_MS))
			pause()
		cost_superconductivity = MC_AVERAGE(cost_superconductivity, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ACTIVETURFS
	// This simply starts the turf thread. It runs in the background until the FINALIZE_TURFS step, at which point it's waited for.
	// This also happens to do all the commented out stuff below, all in a single separate thread. This is mostly so that the
	// waiting is consistent.
	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		process_turfs(resumed)
		cost_turfs = MC_AVERAGE(cost_turfs, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
	/*
	// Monstermos and/or Putnamos--making large pressure deltas move faster
	if(currentpart == SSAIR_EQUALIZE)
		timer = TICK_USAGE_REAL
		process_turf_equalize(resumed)
		cost_equalize = MC_AVERAGE(cost_equalize, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_EXCITEDGROUPS
	// Making small pressure deltas equalize immediately so they don't process anymore
	if(currentpart == SSAIR_EXCITEDGROUPS)
		timer = TICK_USAGE_REAL
		process_excited_groups(resumed)
		cost_groups = MC_AVERAGE(cost_groups, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_TURF_POST_PROCESS
	// Quick multithreaded "should we display/react?" checks followed by finishing those up before the next step
	if(currentpart == SSAIR_TURF_POST_PROCESS)
		timer = TICK_USAGE_REAL
		post_process_turfs(resumed)
		cost_post_process = MC_AVERAGE(cost_post_process, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS
	*/
	currentpart = SSAIR_REBUILD_PIPENETS
	last_complete_process = world.time

/datum/controller/subsystem/air/Recover()
	thread_wait_ticks = SSair.thread_wait_ticks
	cur_thread_wait_ticks = SSair.cur_thread_wait_ticks
	low_pressure_turfs = SSair.low_pressure_turfs
	high_pressure_turfs = SSair.high_pressure_turfs
	num_group_turfs_processed = SSair.num_group_turfs_processed
	num_equalize_processed = SSair.num_equalize_processed
	hotspots = SSair.hotspots
	networks = SSair.networks
	pipenets_needing_rebuilt = SSair.pipenets_needing_rebuilt
	deferred_airs = SSair.deferred_airs
	max_deferred_airs = SSair.max_deferred_airs
	atmos_machinery = SSair.atmos_machinery
	atmos_air_machinery = SSair.atmos_air_machinery
	pipe_init_dirs_cache = SSair.pipe_init_dirs_cache
	gas_reactions = SSair.gas_reactions
	high_pressure_delta = SSair.high_pressure_delta
	currentrun = SSair.currentrun
	currentpart = SSair.currentpart
	map_loading = SSair.map_loading
	log_explosive_decompression = SSair.log_explosive_decompression
	equalize_turf_limit = SSair.equalize_turf_limit
	equalize_hard_turf_limit = SSair.equalize_hard_turf_limit
	equalize_enabled = SSair.equalize_enabled
	heat_enabled = SSair.heat_enabled
	share_max_steps = SSair.share_max_steps
	excited_group_pressure_goal = SSair.excited_group_pressure_goal
	paused_z_levels = SSair.paused_z_levels

/datum/controller/subsystem/air/proc/process_pipenets(resumed = FALSE)
	if (!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/add_to_rebuild_queue(atmos_machine)
	if(istype(atmos_machine, /obj/machinery/atmospherics))
		pipenets_needing_rebuilt += atmos_machine

/datum/controller/subsystem/air/proc/process_deferred_airs(resumed = 0)
	max_deferred_airs = max(deferred_airs.len,max_deferred_airs)
	while(deferred_airs.len)
		var/list/cur_op = deferred_airs[deferred_airs.len]
		deferred_airs.len--
		var/datum/gas_mixture/air1
		var/datum/gas_mixture/air2
		if(isopenturf(cur_op[1]))
			var/turf/open/T = cur_op[1]
			air1 = T.return_air()
		else
			air1 = cur_op[1]
		if(isopenturf(cur_op[2]))
			var/turf/open/T = cur_op[2]
			air2 = T.return_air()
		else
			air2 = cur_op[2]
		if(istype(cur_op[3], /datum/callback))
			var/datum/callback/cb = cur_op[3]
			cb.Invoke(air1, air2)
		else
			if(cur_op[3] == 0)
				air1.transfer_to(air2, air1.total_moles())
			else
				air1.transfer_ratio_to(air2, cur_op[3])
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = 0)
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/current_machinery = currentrun[currentrun.len]
		currentrun.len--
		if(!current_machinery)
			atmos_machinery -= current_machinery
		// Prevents uninitalized atmos machinery from processing.
		if (!(current_machinery.flags_1 & INITIALIZED_1))
			continue
		if(current_machinery.process_atmos() == PROCESS_KILL)
			stop_processing_machine(current_machinery)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_air_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = atmos_air_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/current_machinery = currentrun[currentrun.len]
		currentrun.len--
		// Prevents uninitalized atmos machinery from processing.
		if (!(current_machinery.flags_1 & INITIALIZED_1))
			continue
		if(!current_machinery)
			atmos_air_machinery -= current_machinery
		if(current_machinery.process_atmos(seconds) == PROCESS_KILL)
			stop_processing_machine(current_machinery)
		if(MC_TICK_CHECK)
			return

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/air/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	machine.atmos_processing = TRUE
	if(machine.interacts_with_air)
		atmos_air_machinery += machine
	else
		atmos_machinery += machine

/**
 * Removes a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/air/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	if(machine.interacts_with_air)
		atmos_air_machinery -= machine
	else
		atmos_machinery -= machine

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(currentpart == SSAIR_ATMOSMACHINERY)
		currentrun -= machine
	if(machine.interacts_with_air && currentpart == SSAIR_ATMOSMACHINERY_AIR)
		currentrun -= machine

/datum/controller/subsystem/air/proc/process_turf_heat()

/datum/controller/subsystem/air/proc/process_hotspots(resumed = FALSE)
	if (!resumed)
		src.currentrun = hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/hotspot/H = currentrun[currentrun.len]
		currentrun.len--
		if (H)
			H.process()
		else
			hotspots -= H
		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/air/proc/process_high_pressure_delta(resumed = 0)
	while (high_pressure_delta.len)
		var/turf/open/T = high_pressure_delta[high_pressure_delta.len]
		high_pressure_delta.len--
		T.high_pressure_movements()
		T.pressure_difference = 0
		T.pressure_specific_target = null
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_turf_equalize(resumed = 0)
	if(process_turf_equalize_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()
	/*
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.equalize_pressure_in_zone(fire_count)
			//equalize_pressure_in_zone(T, fire_count)
		if (MC_TICK_CHECK)
			return
	*/

/datum/controller/subsystem/air/proc/process_turfs(resumed = 0)
	if(process_turfs_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()
	/*
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.process_cell(fire_count)
		if (MC_TICK_CHECK)
			return
	*/

/datum/controller/subsystem/air/proc/process_excited_groups(resumed = 0)
	if(process_excited_groups_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/finish_turf_processing(resumed = 0)
	if(finish_turf_processing_auxtools(MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/post_process_turfs(resumed = 0)
	if(post_process_turfs_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/finish_turf_processing_auxtools()
/datum/controller/subsystem/air/proc/process_turfs_auxtools()
/datum/controller/subsystem/air/proc/post_process_turfs_auxtools()
/datum/controller/subsystem/air/proc/process_turf_equalize_auxtools()
/datum/controller/subsystem/air/proc/process_excited_groups_auxtools()
/datum/controller/subsystem/air/proc/get_amt_gas_mixes()
/datum/controller/subsystem/air/proc/get_max_gas_mixes()
/datum/controller/subsystem/air/proc/turf_process_time()
/datum/controller/subsystem/air/proc/heat_process_time()

/datum/controller/subsystem/air/StartLoadingMap()
	map_loading = TRUE

/datum/controller/subsystem/air/StopLoadingMap()
	map_loading = FALSE

/datum/controller/subsystem/air/proc/pause_z(z_level)
	LAZYADD(paused_z_levels, z_level)
	unpausing_z_levels -= z_level
	pausing_z_levels |= z_level

/datum/controller/subsystem/air/proc/unpause_z(z_level)
	pausing_z_levels -= z_level
	unpausing_z_levels |= z_level
	LAZYREMOVE(paused_z_levels, z_level)

/datum/controller/subsystem/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
	var/times_fired = ++src.times_fired

	for(var/turf/T as anything in turfs_to_init)
		if (!T.init_air)
			continue
		T.Initalize_Atmos(times_fired)
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery + atmos_air_machinery)
		AM.atmosinit()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery + atmos_air_machinery)
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	if(!initialized) // yogs - fixes randomized bars
		return // yogs
	var/obj/machinery/atmospherics/AM
	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.atmosinit()
		CHECK_TICK

	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/get_init_dirs(type, dir)
	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir)
		pipe_init_dirs_cache[type]["[dir]"] = temp.GetInitDirections()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[dir]"]

#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_EXCITEDGROUPS
#undef SSAIR_HIGHPRESSURE
#undef SSAIR_HOTSPOTS
#undef SSAIR_TURF_CONDUCTION
#undef SSAIR_EQUALIZE
#undef SSAIR_ACTIVETURFS
#undef SSAIR_TURF_POST_PROCESS
#undef SSAIR_FINALIZE_TURFS
#undef SSAIR_ATMOSMACHINERY_AIR
