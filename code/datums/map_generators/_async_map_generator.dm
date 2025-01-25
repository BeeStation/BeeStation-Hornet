/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/async_map_generator
	var/completed = FALSE
	var/ticks = 0
	var/list/late_completion_callbacks = list()
	var/list/completion_callbacks = list()
	var/list/callback_args

/// Begin generating
/datum/async_map_generator/proc/generate(...)
	SSasync_map_generator.executing_generators += src
	callback_args = args.Copy(1)

/datum/async_map_generator/proc/on_completion(datum/callback/completion_callback)
	completion_callbacks += completion_callback

/datum/async_map_generator/proc/on_late_completion(datum/callback/completion_callback)
	late_completion_callbacks += completion_callback

/// Execute a current run.
/// Returns TRUE if finished
/datum/async_map_generator/proc/execute_run()
	ticks ++
	return TRUE

/datum/async_map_generator/proc/get_name()
	return "Async Map generator"

/datum/async_map_generator/proc/complete()
	completed = TRUE
	var/list/arguments = list(src)
	if (callback_args)
		arguments += callback_args
	for (var/datum/callback/on_completion as() in completion_callbacks)
		on_completion.Invoke(arglist(arguments))
	for (var/datum/callback/on_completion as() in late_completion_callbacks)
		on_completion.Invoke(arglist(arguments))
	//to_chat(world, span_announce("[get_name()] completed and loaded successfully."))
