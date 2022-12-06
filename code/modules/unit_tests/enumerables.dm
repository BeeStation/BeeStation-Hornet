/// Verifies that roundstart dynamic rulesets are setup properly without external configuration.
/datum/unit_test/enumerables

/datum/unit_test/enumerables/Run()
	//Test list enumerable
	var/list/basic_list = list("a", "b", "c", "d", "e")
	var/datum/enumerator/basic_list_enumerator = get_list_enumerator(basic_list)
	var/i = 1
	//Test correct values read
	while (basic_list_enumerator.has_next())
		var/thing = basic_list_enumerator.next()
		TEST_ASSERT_EQUAL(basic_list[i++], thing, "List enumerator returned wrong results")
	//Set correct amount read
	TEST_ASSERT_EQUAL(length(basic_list), i, "List enumerator read the wrong number of elements")
	//Test resetting
	i = 1
	basic_list_enumerator.reset()
	//Test correct values read
	while (basic_list_enumerator.has_next())
		var/thing = basic_list_enumerator.next()
		TEST_ASSERT_EQUAL(basic_list[i++], thing, "List enumerator returned wrong results after resetting")
	//Set correct amount read
	TEST_ASSERT_EQUAL(length(basic_list), i, "List enumerator read the wrong number of elements after resetting")
