/datum/outfit/siege
	name = "Operative - Template"
	var/role = "normal"
	suit = /obj/item/clothing/suit/space/syndicate
	head = /obj/item/clothing/head/helmet/space/syndicate
	mask = /obj/item/clothing/mask/gas/syndicate
	uniform = /obj/item/clothing/under/syndicate
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/syndicate
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival)

/datum/outfit/siege/specialist
	name = "Operative - Specialist"

/datum/outfit/siege/pirate
	name = "Operative - Pirate"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/bandana
	mask = null
	glasses = /obj/item/clothing/glasses/eyepatch
	belt = /obj/item/gun/energy/laser
	l_hand = /obj/item/gun/energy/laser
	backpack_contents = list(/obj/item/grenade/plastic/c4)
	r_pocket = /obj/item/grenade/plastic/x4

/datum/outfit/siege/grunt
	name = "Operative - Grunt"
	belt = /obj/item/gun/ballistic/automatic/c20r
	r_pocket = /obj/item/ammo_box/magazine/smgm45
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival,\
		/obj/item/ammo_box/magazine/smgm45 = 3)

/datum/outfit/siege/bomber
	name = "Operative - Bomber"
	backpack_contents = list(/obj/item/grenade/plastic/x4, /obj/item/grenade/syndieminibomb)
	r_pocket = /obj/item/grenade/plastic/x4
	suit = /obj/item/clothing/suit/space/syndicate/blue
	head = /obj/item/clothing/head/helmet/space/syndicate/blue

/datum/outfit/siege/medic
	name = "Operative - Medic"
	suit = /obj/item/clothing/suit/space/syndicate/blue
	head = /obj/item/clothing/head/helmet/space/syndicate/blue
	r_hand = /obj/item/gun/energy/e_gun
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/ert/medical
	belt = /obj/item/storage/belt/medical
	l_hand = /obj/item/storage/firstaid/regular
	backpack_contents = list(/obj/item/gun/medbeam=1)

/datum/outfit/siege/infiltrator
	name = "Operative - Infiltrator"
	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	gloves = /obj/item/clothing/gloves/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	glasses = /obj/item/clothing/glasses/chameleon
	head = /obj/item/clothing/head/chameleon
	mask = /obj/item/clothing/mask/chameleon
	neck = /obj/item/clothing/neck/chameleon
	back = /obj/item/storage/backpack/chameleon
	ears = /obj/item/radio/headset/chameleon
	head = /obj/item/clothing/head/wig
	l_hand = /obj/item/clothing/suit/space/syndicate
	r_hand = /obj/item/clothing/head/helmet/space/syndicate
	r_pocket = /obj/item/ammo_box/magazine/m10mm
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival,\
		/obj/item/razor=1,\
		/obj/item/handmirror=1,\
		/obj/item/card/emag,\
		/obj/item/ammo_box/magazine/m10mm = 2,\
		/obj/item/gun/ballistic/automatic/pistol/suppressed)

/datum/outfit/siege/intruder
	name = "Operative - Intruder"
	l_hand = /obj/item/melee/transforming/energy/sword/saber
	backpack_contents = list(/obj/item/card/emag=1)

/datum/outfit/siege/intruder/brawler //doesn't inherit intruder's unique implant
	name = "Operative - Brawler"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	head = null

/datum/outfit/siege/zombie
	name = "Operative - Zombie"
	back = null
	suit = /obj/item/clothing/suit/space/syndicate/black

/datum/outfit/siege/engineer
	name = "Operative - Engineer"
	belt = /obj/item/storage/belt/utility/full
	l_hand = /obj/item/gun/ballistic/shotgun/lethal
	uniform = /obj/item/clothing/under/misc/overalls
	suit = /obj/item/clothing/suit/space/syndicate/orange
	head = /obj/item/clothing/head/helmet/space/syndicate/orange
	backpack_contents = list(/obj/item/storage/box/lethalshot = 2,\
		/obj/item/syndPDA)
	r_pocket = /obj/item/stack/sheet/iron/fifty


//Elite Roles
/datum/outfit/siege/wizard
	name = "Operative - Wizard"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/wizard
	r_hand = /obj/item/spellbook
	l_hand = /obj/item/staff

/datum/outfit/siege/abductor
	name = "Operative - Abductor"
	suit = /obj/item/clothing/suit/armor/abductor/vest
	head = /obj/item/clothing/head/helmet/abductor
	r_pocket = /obj/item/teleportation_scroll
	l_hand = /obj/item/melee/transforming/energy/sword/saber

/datum/outfit/siege/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE

	var/obj/item/card/id/a = locate() in H.get_equipped_items()
	a.assignment = name

	var/obj/item/implant/i = new/obj/item/implant/explosive/siege(H)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	H.faction |= ROLE_SYNDICATE
	ADD_TRAIT(H, TRAIT_NODROP, ANTI_DROP_IMPLANT_TRAIT)
	H.update_icons()
	switch(name)
		if("Operative - Bomber")
			i = new/obj/item/implant/explosive/(H)
		if("Operative - Pirate")
			H.set_species(/datum/species/skeleton)
		if("Operative - Zombie")
			H.set_species(/datum/species/zombie/infectious)
			return
		if("Operative - Specialist")
			var/obj/item/U = new /obj/item/uplink/nuclear(/obj/item/uplink/nuclear, H.key, 10)
			H.equip_to_slot_or_del(U, ITEM_SLOT_BACKPACK)
		if("Operative - Infiltrator")
			var/obj/item/implant/s = new/obj/item/implant/freedom
			s.implant(H)
		if("Operative - Intruder")
			var/obj/item/implant/s = new/obj/item/implant/stealth
			s.implant(H)
		if("Operative - Wizard")
			H.name = pick(GLOB.wizard_first) + " " + pick(GLOB.wizard_second)
			H.real_name = H.name
			H.dna.add_mutation(SPACEMUT)
			var/obj/item/spellbook/S = locate() in H.held_items
			if(S)
				S.uses = 5
				S.owner = H
		if("Operative - Abductor")
			H.dna.add_mutation(SPACEMUT)

	a.registered_name = H.name
	if(name == "Operative - Infiltrator")
		a.registered_name = null
		a.assignment = null
	i.implant(H)
	H.update_icons()
