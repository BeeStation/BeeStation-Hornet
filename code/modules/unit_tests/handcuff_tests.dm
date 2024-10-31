/datum/unit_test/handcuffs/Run()
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)
	// Put the test client inside them
	second.Move(get_step(second, NORTH), NORTH)
	TEST_ASSERT_EQUAL(second.Adjacent(first), TRUE, "The 2 mobs should be adjacent to each other")
	first.a_intent = INTENT_GRAB
	first.ClickOn(second)
	TEST_ASSERT_EQUAL(second.pulledby, first, "Second mob should be pulled by the first")
	first.put_in_active_hand(cuffs)
	TEST_ASSERT_EQUAL(first.get_active_held_item(), cuffs, "First mob should be holding handcuffs")
	first.ClickOn(second)
	TEST_ASSERT_NOTNULL(second.handcuffed, "Second mob should be handcuffed")
	// We can't actually test movement with a client (no clients until we stub them), so we have to
	// check this instead for now
	TEST_ASSERT_EQUAL(second.Process_Grab(), TRUE, "The mob should not be able to move while grabbed")
