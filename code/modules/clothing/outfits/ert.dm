/datum/outfit/centcom
	name = "CentCom Base"

/datum/outfit/centcom/post_equip(mob/living/carbon/human/centcom_member, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/implant/mindshield/mindshield = new /obj/item/implant/mindshield(centcom_member)//hmm lets have centcom officials become revs
	mindshield.implant(centcom_member, null, silent = TRUE)

//////////////////////////////////////////////
//                                          //
//              ERT PERSONNEL               //
//                                          //
//////////////////////////////////////////////
/datum/outfit/centcom/ert
	name = "ERT Common"

	uniform = /obj/item/clothing/under/rank/centcom/official
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt

/datum/outfit/centcom/ert/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
	..()

//////////////////////////////////////////
///////////   COMMANDER    ///////////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/commander
	name = "ERT Commander - Class Blue"

	id = /obj/item/card/id/ert
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/zipties/compact=1,
		/obj/item/ammo_box/magazine/x200law=1,
		/obj/item/ai_module/core/full/ert=1
		)
	r_hand = /obj/item/gun/ballistic/automatic/pistol/security
	belt = /obj/item/storage/belt/security/ert/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/door_remote/omni
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/outfit/centcom/ert/commander/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return
	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/captain
	R.recalculateChannels()

/datum/outfit/centcom/ert/commander/amber
	name = "ERT Commander - Class Amber"

	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/zipties/compact=1,
		/obj/item/ai_module/core/full/ert=1,
		/obj/item/door_remote/omni,
		)
	r_hand = /obj/item/gun/energy/e_gun/stun
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

//Subtype of amber so we can avoid duplicating like 50% of our code
/datum/outfit/centcom/ert/commander/amber/red
	name = "ERT Commander - Class Red"

	l_pocket = /obj/item/melee/energy/sword/saber/blue
	r_hand = /obj/item/gun/energy/pulse/pistol/loyalpin

/datum/outfit/centcom/ert/commander/inquisitor
	name = "ERT Commander - Inquisition"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	r_hand = /obj/item/nullrod/claymore/chainsaw_sword
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/ai_module/core/full/ert=1,
		/obj/item/door_remote/omni=1,
		/obj/item/storage/book/bible=1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater=1,
		/obj/item/grenade/chem_grenade/holy=1,
		)

//////////////////////////////////////////
///////////    SECURITY     //////////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/security
	name = "ERT Security - Class Blue"

	id = /obj/item/card/id/ert/Security
	back = /obj/item/mod/control/pre_equipped/responsory/security
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/handcuffs/compact=1,
		/obj/item/ammo_box/magazine/x200law=1,
	)
	r_hand = /obj/item/gun/ballistic/automatic/pistol/security
	belt = /obj/item/storage/belt/security/ert/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/outfit/centcom/ert/security/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hos
	R.recalculateChannels()

/datum/outfit/centcom/ert/security/amber
	name = "ERT Security - Class Amber"

	r_hand = /obj/item/gun/energy/e_gun/stun
	mask = /obj/item/clothing/mask/gas/sechailer/swat

/datum/outfit/centcom/ert/security/amber/red
	name = "ERT Security - Class Red"

	r_hand = /obj/item/gun/energy/pulse/pistol/loyalpin

/datum/outfit/centcom/ert/security/inquisitor
	name = "ERT Security - Inquisition"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/security

	r_hand = /obj/item/nullrod/claymore/chainsaw_sword
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/handcuffs/compact=1,
		/obj/item/storage/book/bible=1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater=1,
		/obj/item/grenade/chem_grenade/holy=1,
	)

//////////////////////////////////////////
///////////       MEDIC      /////////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/medic
	name = "ERT Medic - Class Blue"

	id = /obj/item/card/id/ert/Medical

	back = /obj/item/mod/control/pre_equipped/responsory/medic
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/compact,
		/obj/item/ammo_box/magazine/x200law=1,
	)
	l_hand = /obj/item/reagent_containers/hypospray/combat
	r_hand = /obj/item/gun/ballistic/automatic/pistol/security
	belt = /obj/item/storage/belt/medical/ert
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/outfit/centcom/ert/medic/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/cmo
	R.recalculateChannels()

/datum/outfit/centcom/ert/medic/amber
	name = "ERT Medic - Class Amber"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/advanced/compact,
	)
	l_hand = /obj/item/reagent_containers/hypospray/combat/nanites
	r_hand = /obj/item/gun/energy/e_gun/stun

/datum/outfit/centcom/ert/medic/amber/red
	name = "ERT Medic - Class Red"

	r_hand = /obj/item/gun/energy/pulse/pistol/loyalpin

/datum/outfit/centcom/ert/medic/inquisitor
	name = "ERT Medic - Inquisition"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/medic

	l_hand = /obj/item/reagent_containers/hypospray/combat/heresypurge
	r_hand = /obj/item/nullrod/claymore/chainsaw_sword

	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/compact,
		/obj/item/storage/book/bible=1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater=1,
	)

//////////////////////////////////////////
///////////     ENGINEER     /////////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/engineer
	name = "ERT Engineer - Class Blue"

	id = /obj/item/card/id/ert/Engineer
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/ammo_box/magazine/x200law=1,
		/obj/item/bluespace_anchor=1,
		/obj/item/rcd_ammo/large=2,
	)
	belt = /obj/item/storage/belt/utility/full/powertools/rcd
	glasses =  /obj/item/clothing/glasses/meson/engine
	r_hand = /obj/item/gun/ballistic/automatic/pistol/security
	l_pocket = /obj/item/holosign_creator/atmos/ert
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/outfit/centcom/ert/engineer/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/ce
	R.recalculateChannels()

/datum/outfit/centcom/ert/engineer/amber
	name = "ERT Engineer - Class Amber"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/bluespace_anchor=1,
		/obj/item/rcd_ammo/large=2,
	)
	r_hand = /obj/item/gun/energy/e_gun/stun

/datum/outfit/centcom/ert/engineer/amber/red
	name = "ERT Engineer - Class Red"

	r_hand = /obj/item/gun/energy/pulse/pistol/loyalpin

/datum/outfit/centcom/ert/engineer/inquisitor
	name = "ERT Engineer - Inquisition"

	id = /obj/item/card/id/ert/Engineer
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/engineer

	r_hand = /obj/item/nullrod/claymore/chainsaw_sword
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/bluespace_anchor=1,
		/obj/item/rcd_ammo/large=2,
		/obj/item/storage/book/bible=1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater=1,
	)

//////////////////////////////////////////
////////   JANI & WEEDWHACKER    /////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/janitor
	name = "ERT Janitor - Standard"

	id = /obj/item/card/id/ert/Janitor
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/grenade/clusterbuster/cleaner=1,
		/obj/item/mop/advanced=1,
		/obj/item/ammo_box/magazine/x200law=1,
		/obj/item/choice_beacon/janicart=1,
		)
	belt = /obj/item/storage/belt/janitor/ertfull
	glasses = /obj/item/clothing/glasses/night
	r_hand = /obj/item/gun/ballistic/automatic/pistol/security
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/outfit/centcom/ert/janitor/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

/datum/outfit/centcom/ert/janitor/heavy
	name = "ERT Janitor - Heavy"
	l_hand = /obj/item/reagent_containers/spray/chemsprayer/janitor

/datum/outfit/centcom/ert/janitor/kudzu
	name = "ERT Janitor - Weed Control"

	id = /obj/item/card/id/ert/kudzu

	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	l_pocket = /obj/item/grenade/chem_grenade/antiweed
	l_hand = /obj/item/scythe
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/choice_beacon/pet/goat=1,
		/obj/item/ammo_box/magazine/x200law=1,
		/obj/item/grenade/clusterbuster/antiweed=2,
	)

//////////////////////////////////////////
////////      DEATH COMMANDO     /////////
//////////////////////////////////////////
/datum/outfit/centcom/ert/death_commando
	name = JOB_ERT_DEATHSQUAD

	id = /obj/item/card/id/centcom
	uniform = /obj/item/clothing/under/rank/centcom/commander
	back = /obj/item/mod/control/pre_equipped/apocryphal
	suit_store = /obj/item/gun/energy/pulse/destroyer/loyalpin
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/compact=1,
		/obj/item/grenade/plastic/x4=2,
	)
	belt = /obj/item/storage/belt/security/ert/full
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/magboots/commando
	l_pocket = /obj/item/melee/energy/sword/saber
	r_pocket = /obj/item/shield/energy
	r_hand = /obj/item/gun/energy/pulse/pistol/loyalpin

/datum/outfit/centcom/ert/death_commando/officer
	name = "Death Commando Officer"
	back = /obj/item/mod/control/pre_equipped/apocryphal/officer
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/firstaid/compact=1,
		/obj/item/grenade/plastic/x4=2,
		/obj/item/ai_module/core/full/deathsquad=1,
		/obj/item/door_remote/omni=1,
	)

/datum/outfit/centcom/ert/death_commando/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	. = ..()

	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = list() //wipe access first
	W.access = get_all_accesses()  //They get full station access.
	W.access |= get_centcom_access(JOB_ERT_DEATHSQUAD) //Let's add their alloted CentCom access.
	W.assignment = JOB_ERT_DEATHSQUAD
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)


/datum/outfit/centcom/ert/death_commando/officer/post_equip(mob/living/carbon/human/squaddie, visuals_only = FALSE)
	..()

	var/obj/item/mod/control/mod = squaddie.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/hat_stabilizer/hat_holder = locate() in mod.modules
	var/obj/item/clothing/head/helmet/space/beret/beret = new(hat_holder)
	hat_holder.attached_hat = beret
	squaddie.update_clothing(mod.slot_flags)

//////////////////////////////////////////////
//                                          //
//            NON-ERT PERSONNEL             //
//                                          //
//////////////////////////////////////////////
///////////     OFFICIAL     /////////////
//////////////////////////////////////////
/datum/outfit/centcom/centcom_official
	name = JOB_CENTCOM_OFFICIAL

	id = /obj/item/card/id/centcom
	uniform = /obj/item/clothing/under/rank/centcom/official
	suit = /obj/item/clothing/suit/hooded/wintercoat/centcom
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
		/obj/item/storage/box/survival = 1,
	)
	belt = /obj/item/gun/energy/e_gun
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/pen
	r_pocket = /obj/item/modular_computer/tablet/pda/preset/heads
	l_hand = /obj/item/clipboard

/datum/outfit/centcom/centcom_official/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/modular_computer/tablet/pda/preset/heads/pda = H.r_store
	pda.saved_identification = H.real_name
	pda.saved_job = JOB_CENTCOM_OFFICIAL

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = list() // wipe access - they shouldn't get all centcom access.
	W.access = get_centcom_access(JOB_CENTCOM_OFFICIAL)
	W.access |= ACCESS_WEAPONS
	W.assignment = JOB_CENTCOM_OFFICIAL
	W.registered_name = H.real_name
	W.update_label()

//////////////////////////////////////////
////////        ATTORNEY         /////////
//////////////////////////////////////////
/datum/outfit/centcom/centcom_attorney
	name = "CentCom Attorney"

	uniform = /obj/item/clothing/under/rank/centcom/intern
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/modular_computer/tablet/pda/preset/lawyer
	back = /obj/item/storage/backpack/satchel
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	id = /obj/item/card/id/ert/lawyer
	backpack_contents = list(/obj/item/storage/box/survival = 1)

//////////////////////////////////////////
////////         INTERNS         /////////
//////////////////////////////////////////
/datum/outfit/centcom/centcom_intern
	name = "CentCom Intern"

	uniform = /obj/item/clothing/under/rank/centcom/intern
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/melee/baton
	l_hand = /obj/item/gun/ballistic/rifle/boltaction
	back = /obj/item/storage/backpack/satchel
	l_pocket = /obj/item/ammo_box/a762
	r_pocket = /obj/item/ammo_box/a762
	id = /obj/item/card/id/centcom
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/datum/outfit/centcom/centcom_intern/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.access = list() //wipe access - they shouldn't get all centcom access.
	W.access = get_centcom_access(name)
	W.access |= ACCESS_WEAPONS
	W.assignment = name
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/centcom/centcom_intern/unarmed
	name = "CentCom Intern (Unarmed)"
	belt = null
	l_hand = null
	l_pocket = null
	r_pocket = null

/datum/outfit/centcom/centcom_intern/leader
	name = "CentCom Head Intern"
	belt = /obj/item/melee/baton/security/loaded
	uniform = /obj/item/clothing/under/rank/centcom/officer_skirt
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/rifle/boltaction
	l_hand = /obj/item/megaphone
	head = /obj/item/clothing/head/hats/intern

/datum/outfit/centcom/centcom_intern/leader/unarmed // i'll be nice and let the leader keep their baton and vest
	name = "CentCom Head Intern (Unarmed)"
	suit_store = null
	l_pocket = null
	r_pocket = null

//////////////////////////////////////////
////////          CLOWNS         /////////
//////////////////////////////////////////
/datum/outfit/centcom/centcom_clown
	name = "Code Banana ERT"
	id = /obj/item/card/id/ert/clown
	belt = /obj/item/modular_computer/tablet/pda/preset/clown
	ears = /obj/item/radio/headset/headset_cent
	uniform = /obj/item/clothing/under/rank/civilian/clown
	back = /obj/item/storage/backpack/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/centcom/centcom_clown/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	ADD_TRAIT(H, TRAIT_NAIVE, INNATE_TRAIT)

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.access |= ACCESS_THEATRE
	W.update_label(W.registered_name, W.assignment)
	H.dna.add_mutation(/datum/mutation/clumsy)

//////////////////////////////////////////
////////     BOUNTY HUNTERS      /////////
//////////////////////////////////////////
// Base outfits in hunter_outfits.dm, where it defines silver IDs. These all use the CC one instead.

/datum/outfit/bounty/operative/ert
	name = "Bounty ERT - Solid Serpent"
	id = /obj/item/card/id/ert/bounty

/datum/outfit/bounty/gunner/ert
	name = "Bounty ERT - Heavy Weapons Synth"
	id = /obj/item/card/id/ert/bounty

/datum/outfit/bounty/technician/ert
	name = "Bounty ERT - Techwizz"
	id = /obj/item/card/id/ert/bounty
