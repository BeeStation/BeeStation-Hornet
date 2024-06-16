/datum/task
	var/result = null
	var/completed = FALSE
	var/list/subtasks
	var/list/continuation_tasks = list()

/// Add a subtask to this subtask. When awaiting a parent task, it will wait for all subtasks to complete
/// and then will return a list containing all the results.
/datum/task/proc/add_subtask(datum/task/subtask)
	LAZYADD(subtasks, subtask)

/// Mark the task as being completed
/datum/task/proc/mark_completed(result = null)
	if (length(subtasks))
		CRASH("Attempting to mark a subtask holder as completed. This is not allowed")
	completed = TRUE
	src.result = result
	for (var/datum/callback/callback as() in continuation_tasks)
		callback.InvokeAsync(result)

/// Wait for the task to be completed, or the timeout to expire
/// Returns true if the task was completed
/datum/task/proc/await(timeout = 30 SECONDS)
	var/start_time = world.time
	UNTIL (world.time >= start_time + timeout || is_completed())
	// Check for success
	var/success = length(subtasks) ? TRUE : completed
	if (length(subtasks) && !result)
		result = list()
		for (var/datum/task/subtask in subtasks)
			if (!subtask.completed)
				success = FALSE
			if (subtask.result)
				result += subtask.result
	return success

/datum/task/proc/is_completed()
	if (length(subtasks))
		for (var/datum/task/subtask in subtasks)
			if (!subtask.completed)
				return FALSE
		return TRUE
	return completed

/// Continue with a callback once the task has completed,
/// invokes immediately unlike AWAIT which may have a 1 second
/// delay causing it to be unresponsive.
/// This is the most effective option for use with UI or player-controlled
/// responses.
/datum/task/proc/continue_with(datum/callback/callback)
	if (!callback)
		return
	// If the async function wasn't async then
	// immediately invoke the continuation task
	if (completed)
		callback.InvokeAsync(result)
		return
	continuation_tasks += callback
