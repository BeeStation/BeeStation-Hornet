/datum/unity_test/test_janky_actions/Run()
	for (var/obj/item/item_path as anything in subtypesof(/obj/item))
		if (!item_path::icon || !item_path::icon_state || !item_path::name)
			continue
		var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/created_item = allocate(item_path)
		// Equip and test
		test_mob.equip_to_appropriate_slot(created_item)
		TEST_ASSERT_EQUAL(length(created_item.actions), length(test_mob.actions), "Expected the mob's action count to be equal to the item's action count.")
		test_mob.unequip_everything()
		TEST_ASSERT_EQUAL(0, length(test_mob.actions), "Expected the mob's action count to be equal 0 after dropping the item.")
		// Equip and test
		test_mob.equip_to_appropriate_slot(created_item)
		TEST_ASSERT_EQUAL(length(created_item.actions), length(test_mob.actions), "Expected the mob's action count to be equal to the item's action count after re-equipping the item again.")
		test_mob.unequip_everything()
		TEST_ASSERT_EQUAL(0, length(test_mob.actions), "Expected the mob's action count to be equal 0 after dropping the item for a second time.")
		qdel(test_mob)
