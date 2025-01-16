SUBSYSTEM_DEF(async_map_generator)
	name = "Async Map Generator"
	wait = 1
	flags = SS_TICKER | SS_NO_INIT
	// We need to be running while shuttles are loading
	runlevels = ALL

	/// List of all currently executing generator datums
	var/list/executing_generators = list()

	/// Index of current run
	var/current_run_index

	/// Length of current run
	var/current_run_length

/datum/controller/subsystem/async_map_generator/stat_entry()
	var/list/things = list()
	for(var/datum/async_map_generator/running_generator as() in executing_generators)
		things += "{Ticks: [running_generator.ticks]}"
	. = ..("GenCnt:[length(executing_generators)], [things.Join(",")]")

/datum/controller/subsystem/async_map_generator/fire()
	if (!length(executing_generators))
		return
	//Reset the queue
	if (current_run_index > current_run_length || !current_run_length)
		current_run_index = 1
		current_run_length = length(executing_generators)
	//Split the tick
	MC_SPLIT_TICK_INIT(current_run_length)
	//Start processing
	while (current_run_index <= current_run_length)
		//Get current action
		var/datum/async_map_generator/currently_running = executing_generators[current_run_index]
		current_run_index ++
		//Perform generate action
		var/completed = TRUE
		while (!currently_running.execute_run())
			// We overused our allocated amount of tick
			if(MC_TICK_CHECK)
				completed = FALSE
				break
		//We completed
		if (completed)
			currently_running.complete()
			//Remove the currently running generator
			executing_generators -= currently_running
			//Decrement the current run nidex
			current_run_index --
			//Decrement the current run length
			current_run_length --
			//to_chat(world, span_announce("Fully completed running map generator [current_run_index + 1]."))
		//Continue to the next process
		MC_SPLIT_TICK

/datum/controller/subsystem/async_map_generator/proc/run_to_completion()
	for (var/datum/async_map_generator/generator in executing_generators)
		while (!generator.execute_run())
			CHECK_TICK
		executing_generators -= generator
		generator.complete()
	current_run_index = 1
	current_run_length = 0
