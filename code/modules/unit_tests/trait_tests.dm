#define TEST_TRAIT "test_trait"
#define SOURCE_A "a"
#define SOURCE_B "b"
#define SOURCE_C "c"
#define SOURCE_D "d"
#define SOURCE_E "e"

/datum/unit_test/test_trait_add/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_has_trait_from/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT_FROM(target, TEST_TRAIT, SOURCE_A), "test failed")

/datum/unit_test/test_has_trait_from_only/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT_FROM_ONLY(target, TEST_TRAIT, SOURCE_A), "test failed")
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_FALSE(HAS_TRAIT_FROM_ONLY(target, TEST_TRAIT, SOURCE_A), "test failed")

/datum/unit_test/test_trait_remove/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_trait_stacking/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_trait_remove_multi/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_trait_value/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A, 5, 5)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 5, "test failed")

/datum/unit_test/test_trait_value_priority/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A, 5, 5)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B, 6, 6)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_C, 4, 4)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_D, 7, 7)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_E, 2, 2)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 7, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_D)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 6, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 6, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 4, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_C)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 2, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_E)
	TEST_ASSERT_NULL(GET_TRAIT_VALUE(target, TEST_TRAIT), "test failed")

