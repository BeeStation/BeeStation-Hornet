// WINTER COATS

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	icon_state = "coatwinter"
	worn_icon = 'icons/mob/clothing/suits/wintercoat.dmi'
	inhand_icon_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/hooded_wintercoat
	custom_price = 25
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)


/datum/armor/hooded_wintercoat
	bio = 10

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon = 'icons/obj/clothing/head/winterhood.dmi'
	icon_state = "winterhood"
	worn_icon = 'icons/mob/clothing/head/winterhood.dmi'
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/wintercoat/white
	name = "white winter coat"
	icon_state = "coatwhite"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/white

/obj/item/clothing/head/hooded/winterhood/white
	name = "winter hood"
	icon_state = "winterhood_white"

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "coatcaptain"
	inhand_icon_state = "coatcaptain"
	armor_type = /datum/armor/wintercoat_captain
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain


/datum/armor/wintercoat_captain
	melee = 25
	bullet = 30
	laser = 30
	energy = 10
	bomb = 25
	acid = 50
	stamina = 20

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	desc = "A thick jacket made from a light, fire-resistant kevlar-like material which provides some protection to the user. It is particularly effective against energy-based threats due to its thickness and insulation."
	icon_state = "coatsecurity"
	inhand_icon_state = "coatsecurity"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security
	armor_type = /datum/armor/wintercoat_security
	slowdown = 0.04
	custom_price = 50


/datum/armor/wintercoat_security
	melee = 15
	bullet = 15
	laser = 40
	energy = 50
	bomb = 25
	fire = 60
	acid = 45
	stamina = 40

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	armor_type = /datum/armor/winterhood_security
	icon_state = "winterhood_security"


/datum/armor/winterhood_security
	melee = 15
	bullet = 15
	laser = 40
	energy = 50
	bomb = 25
	fire = 60
	acid = 45
	stamina = 40

/obj/item/clothing/suit/hooded/wintercoat/detective
	name = "detective winter coat"
	icon_state = "coatdetective"
	inhand_icon_state = "coatdetective"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/melee/classic_baton,
		/obj/item/gun/ballistic/revolver/detective,
		/obj/item/detective_scanner,
		/obj/item/flashlight,
		/obj/item/taperecorder,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_detective
	heat_protection = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/winterhood/detective


/datum/armor/wintercoat_detective
	melee = 25
	bullet = 10
	laser = 25
	energy = 10
	acid = 45
	stamina = 40

/obj/item/clothing/head/hooded/winterhood/detective
	icon_state = "winterhood_detective"
	armor_type = /datum/armor/winterhood_detective


/datum/armor/winterhood_detective
	melee = 25
	bullet = 10
	laser = 25
	energy = 20
	acid = 45
	stamina = 30

/obj/item/clothing/suit/hooded/wintercoat/brigphys
	name = "brig physician winter coat"
	icon_state = "coatbrigphys"
	inhand_icon_state = "coatbrigphys"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_brigphys
	hoodtype = /obj/item/clothing/head/hooded/winterhood/brigphys


/datum/armor/wintercoat_brigphys
	melee = 10
	laser = 10
	bio = 20
	fire = 50
	acid = 50
	stamina = 20

/obj/item/clothing/head/hooded/winterhood/brigphys
	icon_state = "winterhood_brigphys"
	armor_type = /datum/armor/winterhood_brigphys


/datum/armor/winterhood_brigphys
	melee = 10
	laser = 10
	bio = 20
	fire = 50
	acid = 50
	stamina = 20

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "coatmedical"
	inhand_icon_state = "coatmedical"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_medical
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical


/datum/armor/wintercoat_medical
	bio = 50
	acid = 45

/obj/item/clothing/head/hooded/winterhood/medical
	icon_state = "winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/virologist
	name = "virology winter coat"
	icon_state = "coatviro"
	inhand_icon_state = "coatviro"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_virologist
	hoodtype = /obj/item/clothing/head/hooded/winterhood/virologist


/datum/armor/wintercoat_virologist
	bio = 80
	acid = 15

/obj/item/clothing/head/hooded/winterhood/virologist
	icon_state = "winterhood_viro"
	armor_type = /datum/armor/winterhood_virologist


/datum/armor/winterhood_virologist
	bio = 50

/obj/item/clothing/suit/hooded/wintercoat/chemist
	name = "chemist winter coat"
	desc = "A heavy jacket made from hardy 'synthetic' animal furs capable of enduring most chemical mishaps."
	icon_state = "coatchem"
	inhand_icon_state = "coatchem"
	allowed = list(
		/obj/item/grenade/chem_grenade,
		/obj/item/analyzer,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_chemist
	resistance_flags = FIRE_PROOF | ACID_PROOF
	hoodtype = /obj/item/clothing/head/hooded/winterhood/chemist


/datum/armor/wintercoat_chemist
	bomb = 15
	fire = 40
	acid = 40

/obj/item/clothing/head/hooded/winterhood/chemist
	icon_state = "winterhood_chem"
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/hooded/winterhood/virologist
	icon_state = "winterhood_viro"

/obj/item/clothing/suit/hooded/wintercoat/geneticist
	name = "geneticist winter coat"
	icon_state = "coatgene"
	inhand_icon_state = "coatgene"
	allowed = list(
		/obj/item/dnainjector,
		/obj/item/sequence_scanner,
		/obj/item/analyzer,
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/sensor_device,
		/obj/item/stack/medical,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	armor_type = /datum/armor/wintercoat_geneticist
	hoodtype = /obj/item/clothing/head/hooded/winterhood/geneticist


/datum/armor/wintercoat_geneticist
	bio = 20
	acid = 45

/obj/item/clothing/head/hooded/winterhood/geneticist
	icon_state = "winterhood_gene"

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "coatscience"
	inhand_icon_state = "coatscience"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor_type = /datum/armor/wintercoat_science
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science


/datum/armor/wintercoat_science
	bomb = 10

/obj/item/clothing/head/hooded/winterhood/science
	icon_state = "winterhood_science"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "coatengineer"
	inhand_icon_state = "coatengineer"
	armor_type = /datum/armor/wintercoat_engineering
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering


/datum/armor/wintercoat_engineering
	fire = 30
	acid = 45

/obj/item/clothing/head/hooded/winterhood/engineering
	icon_state = "winterhood_engineer"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "coatatmos"
	inhand_icon_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/extinguisher)

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "coathydro"
	inhand_icon_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/cup/bottle, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants, /obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs. It's especially tailored to hold Cargo related items." // Cargo players if I missed anything let me know
	icon_state = "coatcargo"
	inhand_icon_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo
	allowed = list(
		/obj/item/hand_labeler,
		/obj/item/stack/package_wrap,
		/obj/item/dest_tagger,
		/obj/item/clipboard,
		/obj/item/stamp,
		/obj/item/export_scanner,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)


/obj/item/clothing/head/hooded/winterhood/cargo
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs. It is quite armoured and well suited to explore harsh environments."
	icon_state = "coatminer"
	inhand_icon_state = "coatminer"
	allowed = list(
		/obj/item/pickaxe,
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/lighter,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter
	)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST|GROIN|ARMS
	armor_type = /datum/armor/wintercoat_miner
	resistance_flags = FIRE_PROOF
	high_pressure_multiplier = 0.4
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner


/datum/armor/wintercoat_miner
	melee = 30
	bullet = 20
	laser = 20
	energy = 20
	bomb = 50
	bio = 10
	fire = 50
	acid = 50
	stamina = 20

/obj/item/clothing/suit/hooded/wintercoat/miner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A hood attached to a heavy winter jacket. It is quite armoured and well suited to explore harsh environments."
	icon_state = "winterhood_miner"
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor_type = /datum/armor/winterhood_miner
	resistance_flags = FIRE_PROOF
	high_pressure_multiplier = 0.4


/datum/armor/winterhood_miner
	melee = 30
	bullet = 20
	laser = 20
	energy = 20
	bomb = 50
	bio = 10
	fire = 50
	acid = 50
	stamina = 20

/obj/item/clothing/head/hooded/winterhood/miner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

//Old winter coats

/obj/item/clothing/suit/hooded/wintercoat/old
	name = "nostalgic winter coat"
	desc = "A well-worn heavy jacket made from 'synthetic' animal furs."
	icon_state = "old_coatwinter"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/old

/obj/item/clothing/head/hooded/winterhood/old
	name = "winter hood"
	desc = "An old hood attached to a well-worn heavy winter jacket."
	icon_state = "old_winterhood"

/obj/item/clothing/suit/hooded/wintercoat/security/old
	name = "nostalgic security winter coat"
	icon_state = "old_coatsecurity"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/old

/obj/item/clothing/suit/hooded/wintercoat/security/old/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security/old
	icon_state = "old_winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/medical/old
	name = "nostalgic medical winter coat"
	icon_state = "old_coatmedical"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/old

/obj/item/clothing/head/hooded/winterhood/medical/old
	icon_state = "old_winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/science/old
	name = "nostalgic science winter coat"
	icon_state = "old_coatscience"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/old

/obj/item/clothing/head/hooded/winterhood/science/old
	icon_state = "old_winterhood_science"

/obj/item/clothing/suit/hooded/wintercoat/engineering/old
	name = "nostalgic engineering winter coat"
	icon_state = "old_coatengineer"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/old

/obj/item/clothing/head/hooded/winterhood/engineering/old
	icon_state = "old_winterhood_engineer"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos/old
	name = "nostalgic atmospherics winter coat"
	icon_state = "old_coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos/old

/obj/item/clothing/head/hooded/winterhood/engineering/atmos/old
	icon_state = "old_winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro/old
	name = "nostalgic hydroponics winter coat"
	icon_state = "old_coathydro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro/old

/obj/item/clothing/head/hooded/winterhood/hydro/old
	icon_state = "old_winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo/old
	name = "nostalgic cargo winter coat"
	icon_state = "old_coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo/old

/obj/item/clothing/head/hooded/winterhood/cargo/old
	icon_state = "old_winterhood_cargo"

//end of winter coats //uhhh... nuh uh

// CentCom
/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "coatcentcom"
	inhand_icon_state = "coatcentcom"
	armor_type = /datum/armor/wintercoat_centcom
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom


/datum/armor/wintercoat_centcom
	melee = 35
	bullet = 40
	laser = 40
	energy = 50
	bomb = 35
	bio = 10
	fire = 10
	acid = 60

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "hood_centcom"
	armor_type = /datum/armor/winterhood_centcom


/datum/armor/winterhood_centcom
	melee = 35
	bullet = 40
	laser = 40
	energy = 50
	bomb = 35
	bio = 10
	fire = 10
	acid = 60
