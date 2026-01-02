/datum/outfit/pirate
	name = "Space Pirate"

	id = /obj/item/card/id/pirate
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate
	ears = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana
	shoes = /obj/item/clothing/shoes/sneakers/brown

/datum/outfit/pirate/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= FACTION_PIRATE

	var/obj/item/radio/outfit_radio = equipped.ears
	if(outfit_radio)
		outfit_radio.set_frequency(FREQ_SYNDICATE)
		outfit_radio.freqlock = TRUE

	var/obj/item/card/id/outfit_id = equipped.wear_id
	if(outfit_id)
		outfit_id.registered_name = equipped.real_name
		outfit_id.update_label(equipped.real_name)
		outfit_id.update_icon()

/datum/outfit/pirate/captain
	name = "Space Pirate Captain"

	head = /obj/item/clothing/head/helmet/space/pirate
	ears = /obj/item/radio/headset/syndicate/alt/leader

/datum/outfit/pirate/captain/skeleton
	name = "Space Pirate Captain (Skeleton)"

/datum/outfit/pirate/space
	name = "Space Pirate (EVA)"

	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana

/datum/outfit/pirate/space/captain
	name = "Space Pirate Captain (EVA)"

	head = /obj/item/clothing/head/helmet/space/pirate
	ears = /obj/item/radio/headset/syndicate/alt/leader
