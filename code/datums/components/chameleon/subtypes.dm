/datum/component/chameleon/jumpsuit
	original_name = "Jumpsuit"
	base_disguise_path = /obj/item/clothing/under
	disguise_blacklist = list(
		/obj/item/clothing/under,
		/obj/item/clothing/under/color,
		/obj/item/clothing/under/color/random,
		/obj/item/clothing/under/color/jumpskirt,
		/obj/item/clothing/under/color/jumpskirt/random,
		/obj/item/clothing/under/rank,
		/obj/item/clothing/under/changeling
	)

/datum/component/chameleon/suit
	original_name = "Suit"
	base_disguise_path = /obj/item/clothing/suit
	disguise_blacklist = list(
		/obj/item/clothing/suit/armor/abductor,
		/obj/item/clothing/suit/changeling,
		/obj/item/clothing/suit/armor/changeling
	)

/datum/component/chameleon/glasses
	original_name = "Glasses"
	base_disguise_path = /obj/item/clothing/glasses
	disguise_blacklist = list(/obj/item/clothing/glasses/changeling)

/datum/component/chameleon/gloves
	original_name = "Gloves"
	base_disguise_path = /obj/item/clothing/gloves
	disguise_blacklist = list(
		/obj/item/clothing/gloves,
		/obj/item/clothing/gloves/color,
		/obj/item/clothing/gloves/changeling
	)

/datum/component/chameleon/hat
	original_name = "Hat"
	base_disguise_path = /obj/item/clothing/head
	disguise_blacklist = list(
		/obj/item/clothing/head/changeling,
		/obj/item/clothing/head/helmet/changeling
	)

/datum/component/chameleon/mask
	original_name = "Mask"
	base_disguise_path = /obj/item/clothing/mask
	disguise_blacklist = list(/obj/item/clothing/mask/changeling)

/datum/component/chameleon/shoes
	original_name = "Shoes"
	base_disguise_path = /obj/item/clothing/shoes
	disguise_blacklist = list(/obj/item/clothing/shoes/changeling)

/datum/component/chameleon/backpack
	original_name = "Backpack"
	base_disguise_path = /obj/item/storage/backpack

/datum/component/chameleon/belt
	original_name = "Belt"
	base_disguise_path = /obj/item/storage/belt

/datum/component/chameleon/headset
	original_name = "Headset"
	base_disguise_path = /obj/item/radio/headset

/datum/component/chameleon/pda
	original_name = "PDA"
	base_disguise_path = /obj/item/modular_computer/tablet/pda
	disguise_blacklist = list(/obj/item/modular_computer/tablet/pda/heads)

/datum/component/chameleon/stamp
	original_name = "Stamp"
	base_disguise_path = /obj/item/stamp

/datum/component/chameleon/neck
	original_name = "Neck Accessory"
	base_disguise_path = /obj/item/clothing/neck

/datum/component/chameleon/id
	original_name = "ID"
	disguise_whitelist = list(
		/obj/item/card/id/job,
		/obj/item/card/id/syndicate
	)
	disguise_blacklist = list(
		/obj/item/card/id/job,
		/obj/item/card/id/syndicate/anyone,
		/obj/item/card/id/syndicate/broken,
		/obj/item/card/id/syndicate/debug,
		/obj/item/card/id/syndicate/nuke_leader
	)
	hide_duplicates = FALSE
