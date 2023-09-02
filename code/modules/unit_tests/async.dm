/datum/unit_test/test_async/Run()
	var/datum/task/task_1 = INVOKE_ASYNC(src, PROC_REF(synchronously_sleep), 1)
	var/datum/task/task_2 = INVOKE_ASYNC(src, PROC_REF(synchronously_sleep), 2)
	var/datum/task/task_3 = INVOKE_ASYNC(src, PROC_REF(synchronously_sleep), 3)
	var/datum/task/task_4 = INVOKE_ASYNC(src, PROC_REF(long_sleep), 4)
	// Long enough for the tasks to complete async, but not long enough for them to complete synchronous
	sleep(4)
	TEST_ASSERT_EQUAL(1, task_1.result, "Task 1 should have completed with a result of 1")
	TEST_ASSERT_EQUAL(2, task_2.result, "Task 2 should have completed with a result of 2")
	TEST_ASSERT_EQUAL(3, task_3.result, "Task 3 should have completed with a result of 3")
	TEST_ASSERT_EQUAL(FALSE, task_4.completed, "Task 4 should not have completed.")
	// Test this task
	TEST_ASSERT_EQUAL(5, AWAIT(INVOKE_ASYNC(src, PROC_REF(synchronously_sleep), 5), 3), "Awaiting a 2 ds task with a 4 ds timeout should yield the correct result.")
	// Test passed, behaviour is as expected

/datum/unit_test/test_async/proc/synchronously_sleep(value)
	sleep(2)
	return value

/datum/unit_test/test_async/proc/long_sleep(value)
	sleep(5)
	return value
