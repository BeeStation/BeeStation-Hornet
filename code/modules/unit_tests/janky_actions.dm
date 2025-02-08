/datum/unit_test/test_janky_actions/Run()
	for (var/obj/item/item_path as anything in subtypesof(/obj/item))
		if (!item_path::icon || !item_path::icon_state || !item_path::name || (item_path in uncreatables))
			continue
		var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/created_item = allocate(item_path)
		if (length(test_mob.actions) != 0)
			TEST_FAIL("Expected the mob's action count to start at 0.")
		// Equip and test
		test_mob.equip_to_appropriate_slot(created_item)
		// Remember the number of actions we had
		var/action_count = length(test_mob.actions)
		// Unequip everything
		test_mob.unequip_everything()
		if (length(test_mob.actions) != 0)
			TEST_FAIL("Expected the mob's action count to be equal 0 after dropping the item [created_item].")
		// Equip and test to make sure we have the same number of actions
		test_mob.equip_to_appropriate_slot(created_item)
		if (action_count != length(test_mob.actions))
			TEST_FAIL("Expected the mob's action count to be equal to the item's action count after re-equipping the item  [created_item] again.")
		test_mob.unequip_everything()
		if (length(length(test_mob.actions)) > 0)
			TEST_FAIL("Expected the mob's action count to be equal 0 after dropping the item  [created_item] for a second time.")
		qdel(test_mob)
