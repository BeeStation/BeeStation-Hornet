SUBSYSTEM_DEF(ruin_generator)
	name = "Ruin Generator"
	wait = 1
	flags = SS_BACKGROUND | SS_NO_INIT

	/// List of all currently executing generator datums
	var/list/executing_generators = list()

	/// Index of current run
	var/current_run_index

	/// Length of current run
	var/current_run_length

/datum/controller/subsystem/ruin_generator/fire()
	if (!length(executing_generators))
		return
	//Reset the queue
	if (current_run_index > length(executing_generators) || !current_run_length)
		current_run_index = 1
		current_run_length = length(executing_generators)
	//Split the tick
	MC_SPLIT_TICK_INIT(current_run_length)
	//Start processing
	while (current_run_index <= current_run_length)
		//Get current action
		var/datum/ruin_generator/currently_running = executing_generators[current_run_index]
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
		//Continue to the next process
		MC_SPLIT_TICK

/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/ruin_generator

/// Begin generating
/datum/ruin_generator/proc/generate()
	SSruin_generator.executing_generators += src

/// Execute a current run.
/// Returns TRUE if finished
/datum/ruin_generator/proc/execute_run()
	return TRUE

/datum/ruin_generator/proc/complete()
	return
