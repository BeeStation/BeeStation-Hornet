/datum/outfit/spacepol
	name = "Spacepol Officer"
	uniform = /obj/item/clothing/under/rank/security/officer/spacepol
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/gun/ballistic/automatic/pistol/m1911
	head = /obj/item/clothing/head/helmet/police
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/restraints/handcuffs
	id = /obj/item/card/id/silver/spacepol

/datum/outfit/spacepol/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Police Officer"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/bounty
	uniform = /obj/item/clothing/under/rank/prisoner
	id = /obj/item/card/id/silver/spacepol/bounty
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/restraints/handcuffs/cable
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots

/datum/outfit/bounty/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Bounty Hunter"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/bounty/armor
	name = "Bounty Hunter - Armored"
	head = /obj/item/clothing/head/hunter
	suit = /obj/item/clothing/suit/space/hunter
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/hunter
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/garb
	l_hand = /obj/item/tank/internals/plasma/full
	r_hand = /obj/item/flamethrower/full/tank

/datum/outfit/bounty/hook
	name = "Bounty Hunter - Hook"
	head = /obj/item/clothing/head/scarecrow_hat
	gloves = /obj/item/clothing/gloves/botanic_leather
	mask = /obj/item/clothing/mask/scarecrow
	r_hand = /obj/item/gun/ballistic/shotgun/doublebarrel/hook

	backpack_contents = list(
		/obj/item/ammo_casing/shotgun/incapacitate = 6
		)

/datum/outfit/bounty/synth
	name = "Bounty Hunter - Synth"
	suit = /obj/item/clothing/suit/armor/riot
	glasses = /obj/item/clothing/glasses/eyepatch
	r_hand = /obj/item/storage/firstaid/regular
	l_hand = /obj/item/pinpointer/shuttle

	backpack_contents = list(
		/obj/item/bountytrap = 4
		)

/datum/outfit/russian_hunter
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old
	ears = /obj/item/radio/headset
	r_hand = /obj/item/gun/ballistic/rifle/boltaction
	id = /obj/item/card/id/space_russian

/datum/outfit/russian_hunter/pre_equip(mob/living/carbon/human/H)
	if(prob(50))
		head = /obj/item/clothing/head/ushanka
