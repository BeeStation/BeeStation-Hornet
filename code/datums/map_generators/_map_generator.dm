/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/map_generator
	var/completed = FALSE
	var/ticks = 0
	var/datum/callback/on_completion
	var/list/callback_args

/// Begin generating
/datum/map_generator/proc/generate(datum/callback/completion_callback, ...)
	SSmap_generator.executing_generators += src
	on_completion = completion_callback
	callback_args = args

/// Execute a current run.
/// Returns TRUE if finished
/datum/map_generator/proc/execute_run()
	ticks ++
	return TRUE

/datum/map_generator/proc/complete()
	message_admins("Map generator [type] finished generating in [ticks] ticks.")
	completed = TRUE
	var/list/arguments = list(src)
	arguments += callback_args
	on_completion?.Invoke(arguments)
