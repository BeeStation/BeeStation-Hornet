/datum/unit_test/handcuffs/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)
	// Put the test client inside them
	second.Move(get_step(second, NORTH), NORTH)
	first.a_intent = INTENT_GRAB
	first.ClickOn(second)
	TEST_ASSERT_EQUAL(second.pulledby, first, "Second mob should be pulled by the first")
	first.put_in_active_hand(cuffs)
	first.ClickOn(second)
	TEST_ASSERT_NOTNULL(second.handcuffed, "Second mob should be handcuffed")
	// Restore client
	var/previous_loc = second.loc
	second.Move(get_step(second, NORTH), NORTH)
	TEST_ASSERT_EQUAL(second.loc, previous_loc, "The mob should not be able to move while grabbed")
