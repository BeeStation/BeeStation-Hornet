/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/map_generator
	var/completed = FALSE
	var/ticks = 0
	var/list/datum/callback/completion_callbacks = list()
	var/list/callback_args

/// Begin generating
/datum/map_generator/proc/generate(...)
	SSmap_generator.executing_generators += src
	callback_args = args.Copy(1)

/datum/map_generator/proc/on_completion(datum/callback/completion_callback)
	completion_callbacks += completion_callback

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
	for (var/datum/callback/on_completion as() in completion_callbacks)
		on_completion.Invoke(arglist(arguments))
	//to_chat(world, "<span class='announce'>[get_name()] completed and loaded successfully.</span>")
