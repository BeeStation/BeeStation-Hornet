/datum/unit_test/test_janky_actions
	// Since this unit test takes so damn long, we split it up across all runners
	test_flags = parent_type::test_flags & ~UNIT_TEST_DEBUG_MAP_ONLY
	priority = TEST_LONGER

/datum/unit_test/test_janky_actions/Run()
	var/list/type_paths_to_check = valid_subtypesof(/obj/item) - uncreatables

	// This code is responsible for splitting up work across multiple integration tests.
	var/total_amount_to_check = length(type_paths_to_check)
#ifdef RUNNING_LOCAL_TESTS
	// not ci? do everything
	var/start_index = 0
	var/end_index = total_amount_to_check
#else
	var/runner_count = max(length(config.maplist), 1)

	var/split_up_amount = floor(total_amount_to_check / runner_count)

	var/what_map_index_are_we = 1
	for(var/map_name in config.maplist)
		if(SSmapping.current_map.map_name == map_name)
			break
		what_map_index_are_we++

	var/start_index = (what_map_index_are_we - 1) * split_up_amount
	// Instead of super trying to make it an equal split, we just give the remainder tests to the final runner
	var/end_index = (what_map_index_are_we == runner_count) ? total_amount_to_check : start_index + split_up_amount
#endif

	// +1 because byond's list.Copy() implementation is weird
	type_paths_to_check = type_paths_to_check.Copy(start_index, end_index + 1)

	log_world("Running janky actions on [length(type_paths_to_check)] items out of the [total_amount_to_check] total")
	log_world("([start_index + 1] [type_paths_to_check[1]]) - ([end_index] [type_paths_to_check[length(type_paths_to_check)]])")

	for (var/obj/item/item_path as anything in type_paths_to_check)
		if (!item_path::icon || !item_path::icon_state || !item_path::name || (item_path in uncreatables) || (item_path.item_flags & ABSTRACT) || (item_path.item_flags & DROPDEL))
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
			qdel(test_mob, force = TRUE)
			qdel(created_item, force = TRUE)
			continue
		test_mob.equip_to_appropriate_slot(created_item)
		var/worn_actions = length(test_mob.actions)
		test_mob.dropItemToGround(created_item, TRUE)
		TEST_ASSERT_EQUAL(length(test_mob.actions), mob_actions, "When taking off [item_path], the mob had more actions assigned than they started with.")
		test_mob.equip_to_appropriate_slot(created_item)
		TEST_ASSERT_EQUAL(length(test_mob.actions), worn_actions, "When wearing [item_path], the mob had a different amount of actions than they had when they first wore it.")
		qdel(test_mob, force = TRUE)
