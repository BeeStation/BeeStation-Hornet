/datum/outfit/spacepol
	id = /obj/item/card/id/silver/spacepol
	ears = /obj/item/radio/headset/headset_spacepol
	var/assignment

/datum/outfit/spacepol/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.assignment = assignment
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/spacepol/sergeant
	name = "Spacepol Sergeant"
	assignment = "Spacepol Sergeant"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/warden/sergeant
	belt = /obj/item/storage/belt/military
	head = /obj/item/clothing/head/beret/sergeant
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/security
	l_hand = /obj/item/melee/classic_baton/police/telescopic

/datum/outfit/spacepol/officer
	name = "Spacepol Officer"
	assignment = "Spacepol Officer"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/storage/belt/military
	head = /obj/item/clothing/head/beret/spacepol
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/security

/datum/outfit/spacepol/officer/pre_equip(mob/living/carbon/human/H)
	if(prob(40))
		head = /obj/item/clothing/head/helmet/alt
	else if(prob(20))
		head = /obj/item/clothing/head/helmet/riot
	if(prob(50))
		suit = /obj/item/clothing/suit/armor/bulletproof

/datum/outfit/bounty
	uniform = /obj/item/clothing/under/rank/prisoner
	id = /obj/item/card/id/silver/bounty
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
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old
	ears = /obj/item/radio/headset
	id = /obj/item/card/id/space_russian
	back = /obj/item/storage/backpack/satchel/leather

/datum/outfit/russian_hunter/pre_equip(mob/living/carbon/human/H)
	if(prob(50))
		head = /obj/item/clothing/head/ushanka
	else if(prob(20))
		head = /obj/item/clothing/head/helmet/rus_ushanka
	else if(prob(10))
		head = /obj/item/clothing/head/helmet/rus_helmet
	if(prob(30))
		gloves = /obj/item/clothing/gloves/fingerless
	else if(prob(10))
		gloves = /obj/item/clothing/gloves/combat
	if(prob(10))
		uniform = /obj/item/clothing/under/pants/track
	else if(prob(10))
		uniform = /obj/item/clothing/under/syndicate/rus_army

/datum/outfit/russian_hunter/leader
	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/security/officer/russian
	head = /obj/item/clothing/head/helmet/rus_ushanka

/datum/outfit/russian_hunter/leader/pre_equip(mob/living/carbon/human/H)
	if(prob(50))
		gloves = /obj/item/clothing/gloves/combat
	else if(prob(30))
		gloves = /obj/item/clothing/gloves/fingerless
