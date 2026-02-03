///Gives a Human lizard-incompatible shoes, then changes their species over to see if they drop the now incompatible shoes.
/datum/unit_test/species_change_clothing

/datum/unit_test/species_change_clothing/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/human_to_lizard = allocate(/mob/living/carbon/human/dummy/consistent)
	human_to_lizard.equipOutfit(/datum/outfit/job/assistant/consistent)
	human_to_lizard.dna.features["legs"] = DIGITIGRADE_LEGS //you WILL have digitigrade legs

	var/obj/item/human_shoes = human_to_lizard.get_item_by_slot(ITEM_SLOT_FEET)
	human_shoes.supports_variations_flags = NONE //do not fit lizards at all costs.

	human_to_lizard.set_species(/datum/species/lizard)

	var/obj/item/lizard_shoes = human_to_lizard.get_item_by_slot(ITEM_SLOT_FEET)
	TEST_ASSERT_NOTEQUAL(human_shoes, lizard_shoes, "Lizard still has shoes after changing species.")

///Gives a Human items in both hands, then swaps them to be another species. Held items should remain.
/datum/unit_test/species_change_held_items

/datum/unit_test/species_change_held_items/Run()
	var/mob/living/carbon/human/morphing_human = allocate(/mob/living/carbon/human/dummy/consistent)
	var/obj/item/item_a = allocate(/obj/item/storage/toolbox)
	var/obj/item/item_b = allocate(/obj/item/melee/baton/loaded)
	morphing_human.put_in_hands(item_a)
	morphing_human.put_in_hands(item_b)

	var/pre_change_num = length(morphing_human.get_empty_held_indexes())
	TEST_ASSERT_EQUAL(pre_change_num, 0, "Human had empty hands before the species change happened.")

	morphing_human.set_species(/datum/species/lizard)

	var/post_change_num = length(morphing_human.get_empty_held_indexes())
	TEST_ASSERT_EQUAL(post_change_num, 0, "Human had empty hands after the species change happened, but they should've kept their items.")
