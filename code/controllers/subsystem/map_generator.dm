SUBSYSTEM_DEF(map_generator)
	name = "Map Generator"
	wait = 1
	flags = SS_TICKER | SS_NO_INIT
	runlevels = ALL

	/// List of all currently executing generator datums
	var/list/executing_generators = list()

	/// Index of current run
	var/current_run_index

	/// Length of current run
	var/current_run_length

/datum/controller/subsystem/map_generator/stat_entry()
	var/list/things = list()
	for(var/datum/map_generator/running_generator as() in executing_generators)
		things += "{Ticks: [running_generator.ticks]}"
	. = ..("GenCnt:[length(executing_generators)], [things.Join(",")]")

/datum/controller/subsystem/map_generator/fire()
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
		var/datum/map_generator/currently_running = executing_generators[current_run_index]
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
			//to_chat(world, "<span class='announce'>Fully completed running map generator [current_run_index + 1].</span>")
		//Continue to the next process
		MC_SPLIT_TICK
