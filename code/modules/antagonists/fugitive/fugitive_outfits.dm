/datum/outfit/escapedprisoner
	name = "Prison Escapee"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/knife/shiv/carrot

/datum/outfit/escapedprisoner/post_equip(mob/living/carbon/human/H, visuals_only=FALSE)
	if(visuals_only)
		return
	H.fully_replace_character_name(null,"NTP #CC-0[rand(111,999)]") //same as the lavaland prisoner transport, but this time they are from CC, or CentCom

/datum/outfit/yalp_cultist
	name = "Cultist of Yalp Elor"
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	suit = /obj/item/clothing/suit/chaplainsuit/holidaypriest
	gloves = /obj/item/clothing/gloves/color/red
	shoes = /obj/item/clothing/shoes/sneakers/black
	mask = /obj/item/clothing/mask/gas/tiki_mask/yalp_elor

/datum/outfit/waldo
	name = "Waldo"
	uniform = /obj/item/clothing/under/pants/jeans
	suit = /obj/item/clothing/suit/costume/striped_sweater
	head = /obj/item/clothing/head/beanie/waldo
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/regular/circle

/datum/outfit/waldo/post_equip(mob/living/carbon/human/H, visuals_only=FALSE)
	if(visuals_only)
		return
	H.fully_replace_character_name(null,"Waldo")
	H.eye_color = COLOR_BLACK
	H.gender = MALE
	H.skin_tone = "caucasian3"
	H.hair_style = "Business Hair 3"
	H.facial_hair_style = "Shaved"
	H.hair_color = COLOR_BLACK
	H.facial_hair_color = H.hair_color
	H.update_body()

	var/list/no_drops = list()
	no_drops += H.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += H.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_HEAD)
	no_drops += H.get_item_by_slot(ITEM_SLOT_EYES)
	for(var/i in no_drops)
		var/obj/item/I = i
		ADD_TRAIT(I, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	var/datum/action/spell/aoe/knock/waldos_key = new /datum/action/spell/aoe/knock/
	waldos_key.Grant(H)

/datum/outfit/synthetic
	name = "Factory Error Synth"
	uniform = /obj/item/clothing/under/color/white
	ears = /obj/item/radio/headset

/datum/outfit/synthetic/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return
	var/obj/item/organ/eyes/robotic/glow/eyes = new()
	eyes.Insert(H, drop_if_replaced = FALSE)

/datum/outfit/synthetic/leader
	name = "Factory Error Synth Leader"
	r_hand = /obj/item/choice_beacon/augments
	l_hand = /obj/item/autosurgeon
