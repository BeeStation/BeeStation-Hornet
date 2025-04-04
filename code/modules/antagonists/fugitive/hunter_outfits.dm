/datum/outfit/spacepol
	name = "Spacepol Nobody (Preview)"

	id = /obj/item/card/id/silver/spacepol
	uniform = /obj/item/clothing/under/syndicate/combat
	ears = /obj/item/radio/headset/headset_spacepol
	back = /obj/item/storage/backpack/security
	box = /obj/item/storage/box/survival
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
	suit = /obj/item/clothing/suit/armor/vest/warden/sergeant
	belt = /obj/item/storage/belt/military
	head = /obj/item/clothing/head/beret/sergeant
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/melee/classic_baton/police/telescopic

/datum/outfit/spacepol/officer
	name = "Spacepol Officer"
	assignment = "Spacepol Officer"
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	belt = /obj/item/storage/belt/military
	head = /obj/item/clothing/head/beret/spacepol
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/outfit/spacepol/officer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	if(prob(40))
		head = /obj/item/clothing/head/helmet/alt
	else if(prob(20))
		head = /obj/item/clothing/head/helmet/toggleable/riot
	if(prob(50))
		suit = /obj/item/clothing/suit/armor/bulletproof

/datum/outfit/bounty
	name = "Bounty Hunter"

	uniform = /obj/item/clothing/under/rank/prisoner
	id = /obj/item/card/id/silver/bounty
	back = /obj/item/storage/backpack/ert
	r_pocket = /obj/item/restraints/handcuffs/cable
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	box = /obj/item/storage/box/survival

/datum/outfit/bounty/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/bounty/armor
	name = "Bounty Hunter - Armored"
	gloves = /obj/item/clothing/gloves/tackler/combat
	mask = /obj/item/clothing/mask/gas
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/garb

/datum/outfit/bounty/hook
	name = "Bounty Hunter - Hook"
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	gloves = /obj/item/clothing/gloves/tackler/combat
	uniform = /obj/item/clothing/under/color/black
	r_hand = /obj/item/implanter/stealth
	head = /obj/item/clothing/head/beanie/black
	belt = /obj/item/storage/belt/military

/datum/outfit/bounty/synth
	name = "Bounty Hunter - Synth"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/armor/riot
	glasses = /obj/item/clothing/glasses/eyepatch
	r_hand = /obj/item/autosurgeon/hydraulic_blade
	l_hand = /obj/item/bountytrap
	backpack_contents = list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/pinpointer/shuttle = 1,
		/obj/item/bountytrap = 2
		)

/datum/outfit/bounty/synth/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/organ/eyes/robotic/glow/eyes = new()
	eyes.Insert(H, drop_if_replaced = FALSE)

/datum/outfit/russian_hunter
	name = "Russian Hunter"

	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/costume/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old
	ears = /obj/item/radio/headset
	id = /obj/item/card/id/space_russian
	back = /obj/item/storage/backpack/satchel/leather
	box = /obj/item/storage/box/survival

/datum/outfit/russian_hunter/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	if(prob(50))
		head = /obj/item/clothing/head/costume/ushanka
	else if(prob(20))
		head = /obj/item/clothing/head/helmet/rus_ushanka
	else if(prob(10))
		head = /obj/item/clothing/head/helmet/rus_helmet
	if(prob(30))
		gloves = /obj/item/clothing/gloves/fingerless
	else if(prob(10))
		gloves = /obj/item/clothing/gloves/tackler/combat
	if(prob(10))
		uniform = /obj/item/clothing/under/pants/track
	else if(prob(10))
		uniform = /obj/item/clothing/under/syndicate/rus_army

/datum/outfit/russian_hunter/leader
	name = "Russian Hunter - Leader"

	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/jacket/officer/tan
	head = /obj/item/clothing/head/helmet/rus_ushanka

/datum/outfit/russian_hunter/leader/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	if(prob(50))
		gloves = /obj/item/clothing/gloves/tackler/combat
	else if(prob(30))
		gloves = /obj/item/clothing/gloves/fingerless


//ids and ert code

/obj/item/card/id/advanced/bountyhunter
	assignment = "Bounty Hunter"
	//icon_state = "card_flames" //oh SHIT
	//trim = /datum/id_trim/bounty_hunter

/datum/outfit/bounty/armor/ert
	id = /obj/item/card/id/silver/bounty/ert

/datum/outfit/bounty/hook/ert
	id = /obj/item/card/id/silver/bounty/ert

/datum/outfit/bounty/synth/ert
	id = /obj/item/card/id/silver/bounty/ert

/*
/obj/item/card/id/advanced/bountyhunter/ert
	trim = /datum/id_trim/centcom/bounty_hunter
*/
