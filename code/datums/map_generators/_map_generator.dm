/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/map_generator
	var/completed = FALSE
	var/ticks = 0
	var/datum/priority_queue/completion_callbacks = new()
	var/list/callback_args

/// Begin generating
/datum/map_generator/proc/generate(...)
	SSmap_generator.executing_generators += src
	callback_args = args.Copy(1)

/// Adds a callback to be executed when this generator completes.
/// Note that the order of execution is defined as the order the completion callbacks are added in
/// and this property should be preserved.
/datum/map_generator/proc/on_completion(priority, datum/callback/completion_callback)
	//We want lower priorities to come out first, so invert priority
	completion_callbacks.enqueue(-priority, completion_callback)

/// Execute a current run.
/// Returns TRUE if finished
/datum/map_generator/proc/execute_run()
	ticks ++
	return TRUE

/datum/map_generator/proc/get_name()
	return "Map generator"

/datum/map_generator/proc/complete()
	completed = TRUE
	var/list/arguments = list(src)
	if (callback_args)
		arguments += callback_args
	while (completion_callbacks.has_elements())
		var/datum/callback/on_completion = completion_callbacks.dequeue()
		on_completion.Invoke(arglist(arguments))
	//to_chat(world, "<span class='announce'>[get_name()] completed and loaded succesfully.</span>")
