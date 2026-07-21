/// Checks add_access()/remove_access() handle lists, single values, and no-ops like the raw list ops did.
/datum/unit_test/id_card_access

/datum/unit_test/id_card_access/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list()

	// Add a list.
	card.add_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT(ACCESS_MEDICAL in card.access, "add_access(list) did not grant ACCESS_MEDICAL")
	TEST_ASSERT(ACCESS_ENGINE in card.access, "add_access(list) did not grant ACCESS_ENGINE")
	TEST_ASSERT_EQUAL(length(card.access), 2, "add_access(list) changed the access count unexpectedly")

	// Add a single value.
	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(ACCESS_BRIG in card.access, "add_access(single) did not grant ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access(single) changed the access count unexpectedly")

	// Re-adding held access does nothing.
	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access() duplicated an access the card already held")

	// Remove a single value.
	card.remove_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(!(ACCESS_BRIG in card.access), "remove_access(single) did not revoke ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 2, "remove_access(single) changed the access count unexpectedly")

	// Remove a list.
	card.remove_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access(list) did not revoke all listed access")

	// Removing absent access does nothing.
	card.remove_access(ACCESS_MEDICAL, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access() of an absent access altered the access list")
