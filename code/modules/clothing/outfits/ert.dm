/datum/outfit/centcom
	name = "CentCom Base"

/datum/outfit/centcom/post_equip(mob/living/carbon/human/centcom_member, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/mindshield = new /obj/item/implant/mindshield(centcom_member)//hmm lets have centcom officials become revs
	mindshield.implant(centcom_member, null, silent = TRUE)

/datum/outfit/centcom/ert
	name = "ERT Common"

	uniform = /obj/item/clothing/under/rank/centcom/official
	mask = /obj/item/clothing/mask/gas/sechailer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt

/datum/outfit/centcom/ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
	..()

/datum/outfit/centcom/ert/commander
	name = "ERT Commander"

	id = /obj/item/card/id/ert
	suit_store = /obj/item/melee/baton/loaded
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	l_hand = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/ai_module/core/full/ert=1
		)
	belt = /obj/item/storage/belt/security/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/switchblade
	r_pocket = /obj/item/door_remote/omni

/datum/outfit/centcom/ert/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return
	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/captain
	R.recalculateChannels()

/datum/outfit/centcom/ert/commander/alert
	name = "ERT Commander - High Alert"

	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1
	)
	l_pocket = /obj/item/melee/energy/sword/saber/blue

/datum/outfit/centcom/ert/security
	name = "ERT Security"

	id = /obj/item/card/id/ert/Security
	suit_store = /obj/item/melee/baton/loaded
	back = /obj/item/mod/control/pre_equipped/responsory/security
	l_hand = /obj/item/gun/energy/e_gun/stun
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
	)
	belt = /obj/item/storage/belt/security/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/restraints/handcuffs

/datum/outfit/centcom/ert/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hos
	R.recalculateChannels()

/datum/outfit/centcom/ert/security/alert
	name = "ERT Security - High Alert"

	l_hand = /obj/item/gun/energy/pulse/carbine/loyalpin
	mask = /obj/item/clothing/mask/gas/sechailer/swat


/datum/outfit/centcom/ert/medic
	name = "ERT Medic"

	id = /obj/item/card/id/ert/Medical
	suit_store = /obj/item/melee/baton/loaded
	back = /obj/item/mod/control/pre_equipped/responsory/medic
	backpack_contents = list(
		/obj/item/gun/medbeam = 1,
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/reagent_containers/hypospray/combat=1,
	)
	belt = /obj/item/storage/belt/medical/ert
	glasses = /obj/item/clothing/glasses/hud/health
	l_hand = /obj/item/storage/firstaid/compact
	r_hand = /obj/item/gun/energy/e_gun

/datum/outfit/centcom/ert/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/cmo
	R.recalculateChannels()

/datum/outfit/centcom/ert/medic/alert
	name = "ERT Medic - High Alert"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_hand = /obj/item/storage/firstaid/advanced/compact
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,
		/obj/item/reagent_containers/hypospray/combat/nanites=1
	)

/datum/outfit/centcom/ert/engineer
	name = "ERT Engineer"

	id = /obj/item/card/id/ert/Engineer
	suit_store = /obj/item/melee/baton/loaded
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	l_hand = /obj/item/gun/energy/e_gun
	r_hand = /obj/item/storage/firstaid/compact
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/bluespace_anchor=1
	)
	belt = /obj/item/storage/belt/utility/full/powertools
	glasses =  /obj/item/clothing/glasses/meson/engine
	l_pocket = /obj/item/rcd_ammo/large
	l_hand = /obj/item/construction/rcd/loaded

/datum/outfit/centcom/ert/engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/ce
	R.recalculateChannels()

/datum/outfit/centcom/ert/engineer/alert
	name = "ERT Engineer - High Alert"

	mask = /obj/item/clothing/mask/gas/sechailer/swat
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/gun/energy/pulse/pistol/loyalpin=1,
		/obj/item/bluespace_anchor=1
		)
	l_hand = /obj/item/construction/rcd/combat


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

/datum/outfit/centcom/centcom_official/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
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

/datum/outfit/centcom/ert/commander/inquisitor
	name = "Inquisition Commander"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	r_hand = /obj/item/nullrod/scythe/talking/chainsword
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/ai_module/core/full/ert=1,
		/obj/item/door_remote/omni=1
		)

/datum/outfit/centcom/ert/security/inquisitor
	name = "Inquisition Security"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/security
	r_hand = /obj/item/construction/rcd/loaded

/datum/outfit/centcom/ert/medic/inquisitor
	name = "Inquisition Medic"

	suit_store = /obj/item/melee/baton/loaded
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/medic
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/reagent_containers/hypospray/combat=1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge=1,
		/obj/item/gun/medbeam=1
		)

/datum/outfit/centcom/ert/chaplain
	name = "ERT Chaplain"

	id = /obj/item/card/id/ert/chaplain
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/responsory/chaplain
	l_hand = /obj/item/gun/energy/e_gun
	belt = /obj/item/storage/belt/soulstone
	glasses = /obj/item/clothing/glasses/hud/health
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/nullrod=1
		)

/datum/outfit/centcom/ert/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hop
	R.recalculateChannels()

/datum/outfit/centcom/ert/chaplain/inquisitor
	name = "Inquisition Chaplain"

	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/grenade/chem_grenade/holy=1,
		/obj/item/nullrod=1
		)
	belt = /obj/item/storage/belt/soulstone/full/chappy

/datum/outfit/centcom/ert/janitor
	name = "ERT Janitor"

	id = /obj/item/card/id/ert/Janitor
	suit_store = /obj/item/storage/bag/trash/bluespace
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/reagent_containers/cup/bucket=1,
		)
	belt = /obj/item/storage/belt/janitor/ertfull
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/grenade/clusterbuster/cleaner
	r_hand = /obj/item/choice_beacon/janicart
	l_hand = /obj/item/mop/advanced

/datum/outfit/centcom/ert/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

/datum/outfit/centcom/ert/janitor/heavy
	name = "ERT Janitor - Heavy Duty"
	l_hand = /obj/item/reagent_containers/spray/chemsprayer/janitor

/datum/outfit/centcom/ert/kudzu
	name = "ERT Weed Whacker"

	id = /obj/item/card/id/ert/kudzu
	suit = /obj/item/clothing/suit/space/hardsuit/ert/jani
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack/ert
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/janitor/ertfull
	r_pocket = /obj/item/grenade/chem_grenade/antiweed
	l_pocket = /obj/item/grenade/chem_grenade/antiweed
	l_hand = /obj/item/scythe
	backpack_contents = list(
		/obj/item/storage/box/survival/engineer=1,
		/obj/item/storage/box/lights/mixed=1,
		/obj/item/choice_beacon/pet/goat=1,
		/obj/item/grenade/clusterbuster/antiweed=2,
	)

/datum/outfit/centcom/ert/kudzu/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

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

/datum/outfit/centcom/centcom_intern
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

/datum/outfit/centcom/centcom_intern/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
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
	belt = /obj/item/melee/baton/loaded
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

/datum/outfit/centcom/centcom_clown
	name = "Code Banana ERT"
	id = /obj/item/card/id/centcom
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


/datum/outfit/centcom/centcom_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
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

/datum/outfit/centcom/centcom_clown/honk_squad
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
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		/obj/item/reagent_containers/spray/chemsprayer/janitor/clown = 1,
	)

/datum/outfit/centcom/death_commando
	name = JOB_ERT_DEATHSQUAD

	id = /obj/item/card/id/centcom
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/apocryphal
	backpack_contents = list(
		/obj/item/storage/box=1,
		/obj/item/ammo_box/a357=1,
		/obj/item/storage/firstaid/compact=1,
		/obj/item/storage/box/flashbangs=1,
		/obj/item/flashlight=1,
		/obj/item/grenade/plastic/x4=1
	)
	belt = /obj/item/gun/ballistic/revolver/mateba
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/magboots/commando
	l_pocket = /obj/item/melee/energy/sword/saber
	r_pocket = /obj/item/shield/energy
	l_hand = /obj/item/gun/energy/pulse/loyalpin

/datum/outfit/centcom/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
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

/datum/outfit/centcom/death_commando/officer
	name = "Death Commando Officer"
	back = /obj/item/mod/control/pre_equipped/apocryphal/officer
	backpack_contents = list(
		/obj/item/ai_module/core/full/deathsquad=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/storage/firstaid/compact=1,\
		/obj/item/storage/box/flashbangs=1,\
		/obj/item/flashlight=1,\
		/obj/item/grenade/plastic/x4=1,
		/obj/item/door_remote/omni=1
	)

/datum/outfit/centcom/death_commando/officer/post_equip(mob/living/carbon/human/squaddie, visualsOnly = FALSE)
	. = ..()
	var/obj/item/mod/control/mod = squaddie.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/hat_stabilizer/hat_holder = locate() in mod.modules
	var/obj/item/clothing/head/helmet/space/beret/beret = new(hat_holder)
	hat_holder.attached_hat = beret
	squaddie.update_clothing(mod.slot_flags)

/datum/outfit/centcom/death_commando/doomguy
	name = "The Juggernaut"

	suit = /obj/item/clothing/suit/space/hardsuit/shielded/doomguy
	shoes = /obj/item/clothing/shoes/jackboots/fast
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	mask = /obj/item/clothing/mask/gas/sechailer
	suit_store = /obj/item/gun/energy/pulse/destroyer
	belt = /obj/item/storage/belt/grenade/full/webbing
	back = /obj/item/storage/backpack/hammerspace
	l_pocket = /obj/item/knife/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	backpack_contents = list(/obj/item/storage/box/survival/engineer=1,\
		/obj/item/reagent_containers/hypospray/combat,\
		/obj/item/radio=1,\
		/obj/item/chainsaw/energy/doom=1,\
		/obj/item/gun/ballistic/sniper_rifle=1,\
		/obj/item/gun/grenadelauncher/security=1,\
		/obj/item/gun/ballistic/automatic/ar=1)
