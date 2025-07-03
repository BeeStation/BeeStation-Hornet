/datum/unit_test/test_janky_actions
	priority = TEST_LONGER

/datum/unit_test/test_janky_actions/Run()
	for (var/obj/item/item_path as anything in subtypesof(/obj/item))
		if (!item_path::icon || !item_path::icon_state || !item_path::name || (item_path in uncreatables) || (item_path.item_flags & ABSTRACT))
			continue
		var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/created_item = allocate(item_path)
		var/mob_actions = length(test_mob.actions)
		test_mob.put_in_active_hand(created_item)
		var/held_actions = length(test_mob.actions)
		test_mob.dropItemToGround(created_item, TRUE)
		TEST_ASSERT_EQUAL(length(test_mob.actions), mob_actions, "When dropping [item_path], the mob had more actions assigned than they started with.")
		test_mob.put_in_active_hand(created_item, TRUE)
		TEST_ASSERT_EQUAL(length(test_mob.actions), held_actions, "When picking [item_path] back up, the mob had a different amount of actions than they had when they first picked it up.")
		test_mob.drop_all_held_items()
		if (!isclothing(created_item))
			qdel(test_mob)
			qdel(created_item)
			continue
		test_mob.equip_to_appropriate_slot(created_item)
		var/worn_actions = length(test_mob.actions)
		test_mob.dropItemToGround(created_item, TRUE)
		TEST_ASSERT_EQUAL(length(test_mob.actions), mob_actions, "When taking off [item_path], the mob had more actions assigned than they started with.")
		test_mob.equip_to_appropriate_slot(created_item)
		TEST_ASSERT_EQUAL(length(test_mob.actions), worn_actions, "When wearing [item_path], the mob had a different amount of actions than they had when they first wore it.")
		qdel(test_mob)
