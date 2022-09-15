/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/map_generator
	var/completed = FALSE
	var/ticks = 0

/// Begin generating
/datum/map_generator/proc/generate()
	SSmap_generator.executing_generators += src

/// Execute a current run.
/// Returns TRUE if finished
/datum/map_generator/proc/execute_run()
	ticks ++
	return TRUE

/datum/map_generator/proc/complete()
	message_admins("Map generator [type] finished generating in [ticks] ticks.")
	completed = TRUE
