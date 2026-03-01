/datum/outfit/spacepol
	name = "Spacepol Nobody (Preview)"

	id = /obj/item/card/id/silver/spacepol
	uniform = /obj/item/clothing/under/rank/security/officer/spacepol
	ears = /obj/item/radio/headset/headset_spacepol
	back = /obj/item/storage/backpack/satchel
	box = /obj/item/storage/box/survival
	var/assignment

/datum/outfit/spacepol/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
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
	l_pocket = /obj/item/melee/baton/telescopic

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

/datum/outfit/spacepol/officer/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
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

/datum/outfit/russian_hunter/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
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

/datum/outfit/russian_hunter/leader/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return
	if(prob(50))
		gloves = /obj/item/clothing/gloves/tackler/combat
	else if(prob(30))
		gloves = /obj/item/clothing/gloves/fingerless

// Stuff they all have
/datum/outfit/bounty
	name = "Bounty Hunter"

	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/syndicate/combat
	id = /obj/item/card/id/silver/bounty

/datum/outfit/bounty/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

// OPERATIVE. STEALTHY, SOLID-SNAKE TYPE GUY. INTENDED LEADER.
/datum/outfit/bounty/operative
	name = "Bounty Hunter - Solid Serpent"

	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	head = /obj/item/clothing/head/beanie/black
	uniform = /obj/item/clothing/under/syndicate/combat
	belt = /obj/item/storage/belt/military
	l_hand = /obj/item/implanter/stealth
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/mini_uzi
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/reagent_containers/hypospray/combat/nanites

	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/ammo_box/magazine/uzim9mm=2,
		/obj/item/ammo_box/c9mm=1,
		/obj/item/storage/firstaid/tactical = 1,
		/obj/item/pinpointer/shuttle = 1,
	)

// GUNNER. THIS GUY DEALS DAMAGE. HE'S A CIGAR-SMOKING SYNTH THAT TAKES NAMES AND CHEWS BUBBLEGUM, OR SOMETHING.
/datum/outfit/bounty/gunner
	name = "Bounty Hunter - Heavy Weapons Synth"

	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	uniform = /obj/item/clothing/under/color/white
	belt = /obj/item/storage/belt/military
	suit = /obj/item/clothing/suit/armor/riot
	glasses = /obj/item/clothing/glasses/eyepatch
	suit_store = /obj/item/gun/ballistic/automatic/pistol/m1911
	back = /obj/item/minigunpack
	r_hand = /obj/item/autosurgeon/hydraulic_blade

	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/ammo_box/magazine/m45

/datum/outfit/bounty/gunner/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return
	var/obj/item/organ/eyes/robotic/glow/eyes = new()
	eyes.Insert(H, drop_if_replaced = FALSE)

// TECHNICIAN. MISTER GNEEP GNARP HERE LIKES TECH AND GOT A VOICEBOX IMPLANT SO HE CAN TALK. WANTED IN ALL ALIEN STATES.
/datum/outfit/bounty/technician
	name = "Bounty Hunter - Techwizz"

	uniform = /obj/item/clothing/under/abductor
	ears = /obj/item/radio/headset/abductor
	belt = /obj/item/storage/belt/military/abductor/full
	r_pocket = /obj/item/gun/energy/alien
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites

	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/tactical = 1,
		/obj/item/bountytrap = 4,
	)

/datum/outfit/bounty/technician/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	H.set_species(/datum/species/abductor, icon_update=0)

	var/obj/item/organ/tongue/robot/tongue = new()
	tongue.Insert(H, drop_if_replaced = FALSE)
