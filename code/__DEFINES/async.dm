
#define DECLARE_ASYNC set waitfor = FALSE; \
	RETURN_TYPE(/datum/task); \
	var/datum/task/created_task = new(); \
	. = created_task;

#define ASYNC_FINISH created_task.mark_completed()

#define ASYNC_RETURN(value) created_task.mark_completed(value)

#define AWAIT(TASK, TIMEOUT) get_result(TASK, TIMEOUT)

/proc/get_result(datum/task/task, timeout)
	if (!istype(task))
		return task
	if (task.await(timeout))
		// Return the task result
		return task.result
	return null
