/datum/armor/test_first
	melee = 10
	bullet = 10

/datum/armor/test_second
	melee = 10
	laser = 10

/datum/unit_test/armour_readout/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/datum/armor/test_first/first = allocate(/datum/armor/test_first)
	var/datum/armor/test_second/second = allocate(/datum/armor/test_second)
	TEST_ASSERT_EQUAL(first.generate_armor_readout(), "<span class='notice'><u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE \Roman["I"]\nBULLET \Roman["I"]</span>", "Failed")
	TEST_ASSERT_EQUAL(second.generate_armor_readout(), "<span class='notice'><u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE \Roman["I"]\nLASER \Roman["I"]</span>", "Failed")
	TEST_ASSERT_EQUAL(first.generate_armor_readout(second), "<span class='notice'><u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE \Roman["I"]\nBULLET [span_green("\Roman["I"]")]\nLASER [span_red("\Roman["None"]")]</span>", "Failed")
