
/// Declars that a function is async, creates the task return type and will cause it to return the task
/// upon sleeping.
/// Place this as the first line in the body of the function, but after any other set X = val settings.
#define DECLARE_ASYNC set waitfor = FALSE; \
	RETURN_TYPE(/datum/task); \
	var/datum/task/created_task = new(); \
	. = created_task;

/// Marks an async function as finished without returning any value.
/// Async version of return;
#define ASYNC_FINISH created_task.mark_completed(); \
	return;

/// Marks an async function as completed and returns a result.
/// Async version of return value;
#define ASYNC_RETURN(value) created_task.mark_completed(value);\
	return;

/// Waits for the provided task to be completed, or the timeout to expire.
/// Returns null if the timeout expires, or the task's result otherwise.
/// Note that if a task's result is null, then null will be returned.
#define AWAIT(TASK, TIMEOUT) get_result(TASK, TIMEOUT)

/proc/get_result(datum/task/task, timeout)
	if (!istype(task))
		return task
	if (task.await(timeout))
		// Return the task result
		return task.result
	return null
