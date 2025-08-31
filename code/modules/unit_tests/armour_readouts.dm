/datum/armor/test_first
	blunt = 10
	penetration = 10

/datum/armor/test_second
	blunt = 10
	reflectivity = 10

/obj/item/clothing/suit/armor/test_first
	armor_type = /datum/armor/test_first

/obj/item/clothing/suit/armor/test_second
	armor_type = /datum/armor/test_second

/datum/unit_test/armour_readout/Run()
	var/obj/item/clothing/first = allocate(/obj/item/clothing/suit/armor/test_first)
	var/obj/item/clothing/second = allocate(/obj/item/clothing/suit/armor/test_second)
	TEST_ASSERT_EQUAL(first.generate_armor_readout(), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nPENETRATION I\nBLUNT I\n<b>ENVIRONMENT</b>\nHEAT 600k or less\nCOLD 600k or greater"), "Failed")
	TEST_ASSERT_EQUAL(second.generate_armor_readout(), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nBLUNT I\nREFLECTIVITY I\n<b>ENVIRONMENT</b>\nHEAT 600k or less\nCOLD 600k or greater"), "Failed")
	TEST_ASSERT_EQUAL(first.generate_armor_readout(second), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nPENETRATION [span_green("I")]\nBLUNT I\nREFLECTIVITY [span_red("None")]\nI<b>ENVIRONMENT</b>\nHEAT 600k or less\nCOLD 600k or greater"), "Failed")
