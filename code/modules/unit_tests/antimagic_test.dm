/// Verifies that antag datums have banning_keys.
/datum/unit_test/antimagic_test/Run()
	var/mob/living/carbon/human/consistent/priest = allocate(/mob/living/carbon/human/consistent)
	var/obj/nullrod = new /obj/item/nullrod()
	priest.put_in_active_hand(nullrod)
	var/result = priest.can_block_magic()
	TEST_ASSERT(result, "Antimagic failed despite nullrod being equipped")
