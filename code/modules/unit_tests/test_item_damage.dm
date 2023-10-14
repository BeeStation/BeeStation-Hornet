/datum/unit_test/item_damage/Run()
	. = list()
	var/mob/living/carbon/human/aggressor = new(run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target = new(run_loc_floor_bottom_left)
	// Always pass probability checks
	GLOB.rigged_prob = TRUE
	for (var/obj/item/item_type as() in subtypesof(/obj/item))
		// Ignore non-weapons since they made do weird things
		if (!(initial(item_type.item_flags) & ISWEAPON))
			continue
		// Heal the target
		target.revive(TRUE, TRUE)
		RESOLVE_HEALTH(target)
		TEST_ASSERT_EQUAL(target.health, 100, "Target should be fully healthy")
		// Create the item
		var/obj/item/thing = new item_type
		aggressor.put_in_active_hand(thing)
		aggressor.a_intent = INTENT_HARM
		aggressor.ClickOn(target)
		RESOLVE_HEALTH(target)
		// Check damage was taken
		if (target.health != 100 - thing.force)
			. += "[thing] did not deal [thing.force] damage on attack, instead it dealt [100 - target.health] damage."
		qdel(thing)
	if (length(.))
		Fail(jointext(., "\n"))
