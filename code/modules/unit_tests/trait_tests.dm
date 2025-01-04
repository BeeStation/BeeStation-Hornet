#define TEST_TRAIT "test_trait"
#define TEST_TRAIT_B "test_trait_b"
#define TEST_TRAIT_C "test_trait_c"
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

/datum/unit_test/test_has_trait_not_from/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT_NOT_FROM(target, TEST_TRAIT, SOURCE_B), "test failed")
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_TRUE(HAS_TRAIT_NOT_FROM(target, TEST_TRAIT, SOURCE_B), "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_FALSE(HAS_TRAIT_NOT_FROM(target, TEST_TRAIT, SOURCE_B), "test failed")

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
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_A, 5, 5)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 5, "test failed")

/datum/unit_test/test_trait_value_priority/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_A, 5, 5)
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_B, 6, 6)
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_C, 4, 4)
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_D, 7, 7)
	ADD_VALUE_TRAIT(target, TEST_TRAIT, SOURCE_E, 2, 2)
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

/datum/unit_test/test_trait_remove_in/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT_B, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT_B), "test failed")
	REMOVE_TRAITS_IN(target, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT_B), "test failed")

/datum/unit_test/test_cumulative_trait/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_CUMULATIVE_TRAIT(target, TEST_TRAIT, SOURCE_A, 1)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 1, "test failed")
	ADD_CUMULATIVE_TRAIT(target, TEST_TRAIT, SOURCE_B, 2)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 3, "test failed")
	ADD_CUMULATIVE_TRAIT(target, TEST_TRAIT, SOURCE_C, 3)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 6, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 5, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 3, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_C)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), null, "test failed")
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_multiplicative_trait/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_CUMULATIVE_TRAIT(target, TEST_TRAIT, SOURCE_A, 1)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 1, "test failed")
	ADD_MULTIPLICATIVE_TRAIT(target, TEST_TRAIT, SOURCE_B, 2)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 2, "test failed")
	ADD_MULTIPLICATIVE_TRAIT(target, TEST_TRAIT, SOURCE_C, 0.5)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 1, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_B)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 0.5, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_A)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), 0, "test failed")
	REMOVE_TRAIT(target, TEST_TRAIT, SOURCE_C)
	TEST_ASSERT_EQUAL(GET_TRAIT_VALUE(target, TEST_TRAIT), null, "test failed")
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT), "test failed")

/datum/unit_test/test_trait_remove_not_in/Run()
	var/atom/target = allocate(/atom/movable)
	ADD_TRAIT(target, TEST_TRAIT, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT_B, SOURCE_A)
	ADD_TRAIT(target, TEST_TRAIT_C, SOURCE_B)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT_B), "test failed")
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT_C), "test failed")
	REMOVE_TRAITS_NOT_IN(target, SOURCE_A)
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT), "test failed")
	TEST_ASSERT_TRUE(HAS_TRAIT(target, TEST_TRAIT_B), "test failed")
	TEST_ASSERT_FALSE(HAS_TRAIT(target, TEST_TRAIT_C), "test failed")
	// Handle a false-positive in spaceman DMM
	return

#undef TEST_TRAIT
#undef TEST_TRAIT_B
#undef TEST_TRAIT_C
#undef SOURCE_A
#undef SOURCE_B
#undef SOURCE_C
#undef SOURCE_D
#undef SOURCE_E
