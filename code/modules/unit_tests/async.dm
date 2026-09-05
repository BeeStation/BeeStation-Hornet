/datum/unit_test/test_async/Run()
	var/datum/task/task_1 = src.async_sleep(1)
	var/datum/task/task_2 = src.async_sleep(2)
	var/datum/task/task_3 = src.async_sleep(3)
	var/datum/task/task_4 = src.async_long_sleep(4)
	// Long enough for the tasks to complete async, but not long enough for them to complete synchronous
	sleep(4)
	TEST_ASSERT_EQUAL(1, task_1.result, "Task 1 should have completed with a result of 1")
	TEST_ASSERT_EQUAL(2, task_2.result, "Task 2 should have completed with a result of 2")
	TEST_ASSERT_EQUAL(3, task_3.result, "Task 3 should have completed with a result of 3")
	TEST_ASSERT_EQUAL(FALSE, task_4.completed, "Task 4 should not have completed.")
	// Test this task
	TEST_ASSERT_EQUAL(5, AWAIT(src.async_sleep(5), 3), "Awaiting a 2 ds task with a 3 ds timeout should yield the correct result.")
	// Test passed, behaviour is as expected

/datum/unit_test/test_async/proc/async_sleep(value)
	DECLARE_ASYNC
	sleep(2)
	ASYNC_RETURN(value)

/datum/unit_test/test_async/proc/async_long_sleep(value)
	DECLARE_ASYNC
	sleep(5)
	ASYNC_RETURN(value)
