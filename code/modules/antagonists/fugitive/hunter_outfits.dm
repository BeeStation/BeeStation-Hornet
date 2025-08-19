/datum/outfit/spacepol
	name = "Spacepol Nobody (Preview)"

	id = /obj/item/card/id/silver/spacepol
	uniform = /obj/item/clothing/under/rank/security/officer/spacepol
	ears = /obj/item/radio/headset/headset_spacepol
	back = /obj/item/storage/backpack/satchel
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
	belt = /obj/item/storage/belt/security/full
	head = /obj/item/clothing/head/beret/sergeant
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/swat/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/melee/classic_baton/police/telescopic

/datum/outfit/spacepol/officer
	name = "Spacepol Officer"
	assignment = "Spacepol Officer"
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/security/full
	head = /obj/item/clothing/head/beret/spacepol
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	mask = /obj/item/clothing/mask/gas/sechailer/spacepol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/outfit/spacepol/officer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	if(prob(40))
		head = /obj/item/clothing/head/helmet/swat/nanotrasen
	else if(prob(20))
		head = /obj/item/clothing/head/hats/warden
	if(prob(50))
		suit = /obj/item/clothing/suit/armor/bulletproof

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
