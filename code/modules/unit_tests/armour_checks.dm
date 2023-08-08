/datum/unit_test/armour_checks

/datum/unit_test/armour_checks/Run()
	var/turf/spawn_loc = run_loc_floor_bottom_left
	var/mob/living/carbon/human/test_dummy = new(spawn_loc)
	// Test without armour
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(0), round(test_dummy.run_armor_check(), 1), "Mob with no armour returned an armour value.")
	// Give the mob some armour
	var/obj/item/clothing/suit/test_vest/armor50 = new /obj/item/clothing/suit/test_vest(spawn_loc, list(MELEE = 50))
	var/armor100 = new /obj/item/clothing/suit/test_vest(spawn_loc, list(MELEE = 100))
	var/armor200 = new /obj/item/clothing/suit/test_vest(spawn_loc, list(MELEE = 200))
	var/armorN50 = new /obj/item/clothing/suit/test_vest(spawn_loc, list(MELEE = -50))
	if (armor50.armor.melee != 50)
		Fail("Armour 50 did not have the correct armour applied to it. This is an error with the unit test.")
	// Run armour checks again without penetration
	equip_item(test_dummy, armor50)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(50), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 50 armour vest did not return 50 armour.")
	equip_item(test_dummy, armor100)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(100), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 100 armour vest did not return 100 armour.")
	equip_item(test_dummy, armor200)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(100), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 200 armour vest did not return 100 armour.")
	equip_item(test_dummy, armorN50)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(-50), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing -50 armour vest did not return -50 armour.")
	// Test with penetration
	// Run armour checks again without penetration
	equip_item(test_dummy, armor50)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(10), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 50 armour vest did not return 10 armour when 80% armour penetration was applied.")
	equip_item(test_dummy, armor100)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(20), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 100 armour vest did not return 20 armour when 80% armour penetration was applied.")
	equip_item(test_dummy, armor200)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(40), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 200 armour vest did not return 40 armour when 80% armour penetration was applied.")
	equip_item(test_dummy, armorN50)
	// Okay, this one is a bit weird
	// Accept this as a valid answer
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(-10), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing -50 armour vest returned a strange value when 80% armour penetration was applied. ([test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80)])")
	// Test stacking armour
	var/obj/item/clothing/suit/test_vest/suit50 = new /obj/item/clothing/suit/test_vest(spawn_loc, list(MELEE = 50))
	test_dummy.equip_to_slot_if_possible(suit50, ITEM_SLOT_ICLOTHING)
	ADD_TRAIT(suit50, TRAIT_NODROP, INNATE_TRAIT)

	equip_item(test_dummy, armor50)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(75), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 50+50 armour vest did not return 75 armour.")
	equip_item(test_dummy, armor100)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(100), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 100+50 armour vest did not return 100 armour.")
	equip_item(test_dummy, armor200)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(100), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing 200+50 armour vest did not return 100 armour.")
	equip_item(test_dummy, armorN50)
	// This one can also seem strange but makes sense
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(25), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE), 1), "Mob wearing -50+50 armour vest did not return 25 armour.")

	// Run armour checks again without penetration
	equip_item(test_dummy, armor50)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(19), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 50+50 armour vest did not return 19 armour when 80% armour penetration was applied.")
	equip_item(test_dummy, armor100)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(28), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 100+50 armour vest did not return 28 armour when 80% armour penetration was applied.")
	equip_item(test_dummy, armor200)
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(46), round(test_dummy.run_armor_check(BODY_ZONE_CHEST, MELEE, armour_penetration = 80), 1), "Mob wearing 200+50 armour vest did not return 46 armour when 80% armour penetration was applied.")

	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(50), 50, "50 armour should be 50.")
	TEST_ASSERT_EQUAL(STANDARDISE_ARMOUR(100), 70, "100 armour should be 70.")

/datum/unit_test/armour_checks/proc/equip_item(mob/living/carbon/human/user, obj/item/item)
	// Drop all items
	for (var/obj/item/I in user.contents)
		user.dropItemToGround(I)
	// Equip the item
	user.equip_to_slot_if_possible(item, ITEM_SLOT_OCLOTHING)
	// TEST THE TEST
	if (user.wear_suit != item)
		Fail("Equipping item failed, expected [item] to be equipped to the suit slot. The test itself has issues.")

/obj/item/clothing/suit/test_vest
	name = "Unit test vest"
	desc = "A vest on a quest for a unit test. Wear across chest."
	slot_flags = ALL
	body_parts_covered = ALL

/obj/item/clothing/suit/test_vest/Initialize(mapload, armour_values)
	armor = armour_values
	. = ..()
