/datum/armor/test_first
	melee = 10
	bullet = 10

/datum/armor/test_second
	melee = 10
	laser = 10

/obj/item/clothing/suit/armor/test_first
	armor_type = /datum/armor/test_first

/obj/item/clothing/suit/armor/test_second
	armor_type = /datum/armor/test_second

/datum/unit_test/armour_readout/Run()
	var/obj/item/clothing/first = allocate(/obj/item/clothing/suit/armor/test_first)
	var/obj/item/clothing/second = allocate(/obj/item/clothing/suit/armor/test_second)
	TEST_ASSERT_EQUAL(first.generate_armor_readout(null), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE I\nBULLET I\nIt will insulate the wearer from cold, down to 160 kelvin."), "Failed")
	TEST_ASSERT_EQUAL(second.generate_armor_readout(null), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE I\nLASER I\nIt will insulate the wearer from cold, down to 160 kelvin."), "Failed")
	TEST_ASSERT_EQUAL(first.generate_armor_readout(null, second), span_notice("<u><b>PROTECTION CLASSES</u></b>\n<b>ARMOR (I-X)</b>\nMELEE I\nBULLET [span_green("I")]\nLASER [span_red("None")]\nIt will insulate the wearer from cold, down to 160 kelvin."), "Failed")
