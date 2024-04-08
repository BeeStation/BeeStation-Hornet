/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/enumerables

/datum/unit_test/enumerables/Run()
	//Test list enumerable
	var/list/basic_list = list("a", "b", "c", "d", "e")
	var/datum/enumerator/basic_list_enumerator = get_list_enumerator(basic_list)
	var/i = 0
	//Test that the value is null before reading
	TEST_ASSERT_EQUAL(null, basic_list_enumerator.current(), "Since we have not called next(), current() should return null (It hasn't entered the enumeration cycle yet.)")
	//Test correct values read
	while (basic_list_enumerator.has_next())
		i++
		var/thing = basic_list_enumerator.next()
		TEST_ASSERT_EQUAL(basic_list[i], thing, "List enumerator returned wrong results")
	//Set correct amount read
	TEST_ASSERT_EQUAL(length(basic_list), i, "List enumerator read the wrong number of elements")
	//Test resetting
	i = 0
	basic_list_enumerator.reset()
	//Test correct values read
	while (basic_list_enumerator.has_next())
		i++
		var/thing = basic_list_enumerator.next()
		TEST_ASSERT_EQUAL(basic_list[i], thing, "List enumerator returned wrong results after resetting")
	//Set correct amount read
	TEST_ASSERT_EQUAL(length(basic_list), i, "List enumerator read the wrong number of elements after resetting")

	//Create a selection enumerator
	var/datum/enumerator/selected = basic_list_enumerator.select(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(debug_prepend)))
	var/list/test_list = list("_a", "_b", "_c", "_d", "_e")

	//Test correct values read
	while (selected.has_next())
		var/thing = selected.next()
		TEST_ASSERT_EQUAL(test_list[i++], thing, "Select enumerator returned wrong results")
	//Set correct amount read
	TEST_ASSERT_EQUAL(length(test_list), i, "Select enumerator read the wrong number of elements")

/proc/debug_prepend(input)
	return "_[input]"
