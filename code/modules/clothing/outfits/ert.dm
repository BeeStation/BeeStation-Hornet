/datum/outfit/ert
	name = "ERT Common"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt

/datum/outfit/ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
	..()

/datum/outfit/ert/commander
	name = "ERT Commander"

	id = /obj/item/card/id/ert
	suit = /obj/item/clothing/suit/space/hardsuit/ert
	suit_store = /obj/item/gun/energy/e_gun
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert
	belt = /obj/item/storage/belt/security/full
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/aiModule/core/full/ert=1)
	l_pocket = /obj/item/switchblade
	r_pocket = /obj/item/door_remote/omni

/datum/outfit/ert/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return
	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/captain
	R.recalculateChannels()

/datum/outfit/ert/commander/alert
	name = "ERT Commander - High Alert"

	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1)
	l_pocket = /obj/item/melee/transforming/energy/sword/saber

/datum/outfit/ert/security
	name = "ERT Security"

	id = /obj/item/card/id/ert/Security
	suit = /obj/item/clothing/suit/space/hardsuit/ert/sec
	suit_store = /obj/item/gun/energy/e_gun/stun
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/full
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1)

/datum/outfit/ert/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hos
	R.recalculateChannels()

/datum/outfit/ert/security/alert
	name = "ERT Security - High Alert"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/carbine/loyalpin=1)


/datum/outfit/ert/medic
	name = "ERT Medic"

	id = /obj/item/card/id/ert/Medical
	suit = /obj/item/clothing/suit/space/hardsuit/ert/med
	suit_store = /obj/item/gun/energy/e_gun
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/ert/medical
	belt = /obj/item/storage/belt/medical/ert
	l_hand = /obj/item/storage/firstaid/regular
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/reagent_containers/hypospray/combat=1,
		/obj/item/melee/baton/loaded=1)

/datum/outfit/ert/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/cmo
	R.recalculateChannels()

/datum/outfit/ert/medic/alert
	name = "ERT Medic - High Alert"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_hand = /obj/item/storage/firstaid/advanced
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,
		/obj/item/reagent_containers/hypospray/combat/nanites=1)

/datum/outfit/ert/engineer
	name = "ERT Engineer"

	id = /obj/item/card/id/ert/Engineer
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engi
	suit_store = /obj/item/gun/energy/e_gun
	glasses =  /obj/item/clothing/glasses/meson/engine
	back = /obj/item/storage/backpack/ert/engineer
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/rcd_ammo/large
	l_hand = /obj/item/storage/firstaid/regular
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/construction/rcd/loaded=1,
		/obj/item/bluespace_anchor=1)

/datum/outfit/ert/engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/ce
	R.recalculateChannels()

/datum/outfit/ert/engineer/alert
	name = "ERT Engineer - High Alert"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,
		/obj/item/construction/rcd/combat=1,
		/obj/item/bluespace_anchor=1)


/datum/outfit/centcom_official
	name = JOB_CENTCOM_OFFICIAL

	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/pen
	back = /obj/item/storage/backpack/satchel
	r_pocket = /obj/item/modular_computer/tablet/pda/heads
	l_hand = /obj/item/clipboard
	id = /obj/item/card/id/centcom

/datum/outfit/centcom_official/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/modular_computer/tablet/pda/heads/pda = H.r_store
	pda.saved_identification = H.real_name
	pda.saved_job = JOB_CENTCOM_OFFICIAL

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = list() // wipe access - they shouldn't get all centcom access.
	W.access = get_centcom_access(JOB_CENTCOM_OFFICIAL)
	W.access += ACCESS_WEAPONS
	W.assignment = JOB_CENTCOM_OFFICIAL
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/ert/commander/inquisitor
	name = "Inquisition Commander"
	l_hand = /obj/item/nullrod/scythe/talking/chainsword
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/aiModule/core/full/ert=1,
		/obj/item/door_remote/omni=1)

/datum/outfit/ert/security/inquisitor
	name = "Inquisition Security"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/e_gun/stun

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/construction/rcd/loaded=1)

/datum/outfit/ert/medic/inquisitor
	name = "Inquisition Medic"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/e_gun

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/reagent_containers/hypospray/combat=1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge=1,
		/obj/item/gun/medbeam=1)

/datum/outfit/ert/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hop
	R.recalculateChannels()

/datum/outfit/ert/chaplain
	name = "ERT Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor // Chap role always gets this suit
	suit_store = /obj/item/gun/energy/e_gun
	id = /obj/item/card/id/ert/chaplain
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/cultpack
	belt = /obj/item/storage/belt/soulstone
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/nullrod=1)

/datum/outfit/ert/chaplain/inquisitor
	name = "Inquisition Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	suit_store = /obj/item/gun/energy/e_gun

	belt = /obj/item/storage/belt/soulstone/full/chappy
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/grenade/chem_grenade/holy=1,
		/obj/item/nullrod=1)

/datum/outfit/ert/janitor
	name = "ERT Janitor"

	id = /obj/item/card/id/ert/Janitor
	suit = /obj/item/clothing/suit/space/hardsuit/ert/jani
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/janitor/full
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_hand = /obj/item/storage/bag/trash/bluespace
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/mop/advanced=1,
		/obj/item/reagent_containers/glass/bucket=1,
		/obj/item/grenade/clusterbuster/cleaner=1,
		/obj/item/choice_beacon/janicart)

/datum/outfit/ert/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

/datum/outfit/ert/janitor/heavy
	name = "ERT Janitor - Heavy Duty"
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/grenade/clusterbuster/cleaner=3,
		/obj/item/reagent_containers/spray/chemsprayer/janitor=1,
		/obj/item/choice_beacon/janicart)

/datum/outfit/ert/kudzu
	name = "ERT Weed Whacker"

	id = /obj/item/card/id/ert/kudzu
	suit = /obj/item/clothing/suit/space/hardsuit/ert/jani
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/janitor/full
	r_pocket = /obj/item/grenade/chem_grenade/antiweed
	l_pocket = /obj/item/grenade/chem_grenade/antiweed
	l_hand = /obj/item/scythe
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/choice_beacon/pet/goat,
		/obj/item/grenade/clusterbuster/antiweed=2)

/datum/outfit/ert/kudzu/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

/datum/outfit/centcom_attorney
	name = "CentCom Attorney"

	uniform = /obj/item/clothing/under/rank/centcom/intern
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/modular_computer/tablet/pda/lawyer
	back = /obj/item/storage/backpack/satchel
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	id = /obj/item/card/id/ert/lawyer
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/datum/outfit/centcom_intern
	name = "CentCom Intern"

	uniform = /obj/item/clothing/under/rank/centcom/intern
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/melee/classic_baton/police
	l_hand = /obj/item/gun/ballistic/rifle/boltaction
	back = /obj/item/storage/backpack/satchel
	l_pocket = /obj/item/ammo_box/a762
	r_pocket = /obj/item/ammo_box/a762
	id = /obj/item/card/id/centcom
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/datum/outfit/centcom_intern/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.access = list() //wipe access - they shouldn't get all centcom access.
	W.access = get_centcom_access(name)
	W.access += ACCESS_WEAPONS
	W.assignment = name
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/centcom_intern/leader
	name = "CentCom Head Intern"
	belt = /obj/item/melee/baton/loaded
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/rifle/boltaction
	l_hand = /obj/item/megaphone
	head = /obj/item/clothing/head/intern

/datum/outfit/centcom_clown
	name = "Code Banana ERT"
	id = /obj/item/card/id/centcom
	belt = /obj/item/modular_computer/tablet/pda/clown
	ears = /obj/item/radio/headset/headset_cent
	uniform = /obj/item/clothing/under/rank/civilian/clown
	back = /obj/item/storage/backpack/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)


/datum/outfit/centcom_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	ADD_TRAIT(H, TRAIT_NAIVE, INNATE_TRAIT)

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.access += ACCESS_THEATRE
	W.update_label(W.registered_name, W.assignment)
	H.dna.add_mutation(CLOWNMUT)

/datum/outfit/centcom_clown/honk_squad
	name = "HONK Squad Trooper"
	back = /obj/item/storage/backpack/holding/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/taeclowndo
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/bikehorn/golden
	r_pocket = /obj/item/shield/energy/bananium
	l_hand = /obj/item/pneumatic_cannon/pie/selfcharge
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		/obj/item/reagent_containers/spray/chemsprayer/janitor/clown = 1,
		)

/datum/outfit/death_commando
	name = JOB_ERT_DEATHSQUAD

	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/space/hardsuit/deathsquad
	shoes = /obj/item/clothing/shoes/magboots/commando
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/storage/backpack/security
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	r_pocket = /obj/item/shield/energy
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	belt = /obj/item/gun/ballistic/revolver/mateba
	l_hand = /obj/item/gun/energy/pulse/loyalpin
	id = /obj/item/card/id/centcom
	ears = /obj/item/radio/headset/headset_cent/alt

	backpack_contents = list(/obj/item/storage/box=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/storage/firstaid/regular=1,\
		/obj/item/storage/box/flashbangs=1,\
		/obj/item/flashlight=1,\
		/obj/item/grenade/plastic/x4=1)

/datum/outfit/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)//Here you go Deuryn
	L.implant(H, null, 1)


	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = list() //wipe access first
	W.access = get_all_accesses()//They get full station access.
	W.access += get_centcom_access(JOB_ERT_DEATHSQUAD)//Let's add their alloted CentCom access.
	W.assignment = JOB_ERT_DEATHSQUAD
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

/datum/outfit/death_commando/officer
	name = "Death Commando Officer"
	head = /obj/item/clothing/head/helmet/space/beret
	backpack_contents = list(/obj/item/aiModule/core/full/deathsquad=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/storage/firstaid/regular=1,\
		/obj/item/storage/box/flashbangs=1,\
		/obj/item/flashlight=1,\
		/obj/item/grenade/plastic/x4=1,
		/obj/item/door_remote/omni=1)

/datum/outfit/death_commando/doomguy
	name = "The Juggernaut"

	suit = /obj/item/clothing/suit/space/hardsuit/shielded/doomguy
	shoes = /obj/item/clothing/shoes/jackboots/fast
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	mask = /obj/item/clothing/mask/gas/sechailer
	suit_store = /obj/item/gun/energy/pulse/destroyer
	belt = /obj/item/storage/belt/grenade/full/webbing
	back = /obj/item/storage/backpack/hammerspace
	l_pocket = /obj/item/kitchen/knife/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/reagent_containers/hypospray/combat,\
		/obj/item/radio=1,\
		/obj/item/chainsaw/energy/doom=1,\
		/obj/item/gun/ballistic/sniper_rifle=1,\
		/obj/item/gun/grenadelauncher/security=1,\
		/obj/item/gun/ballistic/automatic/ar=1)
