/*
 * Job related
 */

//Botanist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	pockets = FALSE
	allowed = list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/cultivator,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/hatchet,
		/obj/item/storage/bag/plants
	)

/obj/item/clothing/suit/apron/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/exo/large)

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "captunic"
	inhand_icon_state = "bio_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/cup/glass/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/assembly/flash/handheld, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

//Chef
/obj/item/clothing/suit/toggle/chef
	name = "chef's apron"
	desc = "An apron-jacket used by a high class chef."
	icon_state = "chef"
	inhand_icon_state = "chef"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	gas_transfer_coefficient = 0.9
	armor_type = /datum/armor/toggle_chef
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
	)
	toggle_noun = "sleeves"

//Cook

/datum/armor/toggle_chef
	bio = 50

/obj/item/clothing/suit/apron/chef
	name = "cook's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
	)

//Detective
/obj/item/clothing/suit/jacket/det_suit
	name = "trenchcoat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	inhand_icon_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|ARMS
	armor_type = /datum/armor/jacket_det_suit
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/melee/classic_baton,
		/obj/item/clothing/accessory/holster/detective,
		) //Trench coats are a little more apt at carrying larger objects.


/datum/armor/jacket_det_suit
	melee = 25
	bullet = 10
	laser = 25
	energy = 10
	acid = 45
	stamina = 40
	bleed = 30

/obj/item/clothing/suit/jacket/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

/obj/item/clothing/suit/jacket/det_suit/dark
	name = "noir trenchcoat"
	desc = "A hard-boiled private investigator's grey trenchcoat."
	icon_state = "greydet"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/det_suit/noir
	name = "noir suit coat"
	desc = "A dapper private investigator's grey suit coat."
	icon_state = "detsuit"
	inhand_icon_state = null

//Brig Phys
/obj/item/clothing/suit/hazardvest/brig_physician
	name = "brig physician's vest"
	desc = "A lightweight vest worn by the Brig Physician."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "brig_phys_vest"
	inhand_icon_state = "sec_helm"//looks kinda similar, I guess
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/storage/firstaid, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/cup/bottle, /obj/item/reagent_containers/cup/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/soap, /obj/item/sensor_device, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor_type = /datum/armor/hazardvest_brig_physician

//Engineering

/datum/armor/hazardvest_brig_physician
	melee = 10
	bio = 10
	fire = 50
	acid = 50
	stamina = 30
	bleed = 20

/obj/item/clothing/suit/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/t_scanner,
		/obj/item/radio
	)
	resistance_flags = NONE

/obj/item/clothing/suit/hazardvest/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/exo/large)

//Lawyer
/obj/item/clothing/suit/toggle/lawyer
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	inhand_icon_state = null
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/toggle/lawyer/purple
	name = "purple suit jacket"
	desc = "A foppish dress jacket."
	icon_state = "suitjacket_purp"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/lawyer/black
	name = "black suit jacket"
	desc = "A professional suit jacket."
	icon_state = "suitjacket_black"
	inhand_icon_state = "ro_suit"

//Mime
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	worn_icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here

//Security
/obj/item/clothing/suit/jacket/officer/blue
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer isn't required to wear their armor."
	icon_state = "officerbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS
	custom_price = 50

/obj/item/clothing/suit/jacket/officer/tan
	name = "security officer's jacket"
	desc = "This jacket is for those special occasions when a security officer isn't required to wear their armor."
	icon_state = "officertanjacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/warden/blue
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardenbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/warden/tan
	name = "warden's jacket"
	desc = "Perfectly suited for the warden that wants to leave an impression of style on those who visit the brig."
	icon_state = "wardenbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/hos/blue
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hosbluejacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/jacket/hos/tan
	name = "head of security's jacket"
	desc = "This piece of clothing was specifically designed for asserting superior authority."
	icon_state = "hostanjacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

//Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "surgical apron"
	desc = "A sterile blue surgical apron."
	icon_state = "surgical"
	allowed = list(
		/obj/item/scalpel,
		/obj/item/surgical_drapes,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/retractor
	)

//Curator
/obj/item/clothing/suit/jacket/curator
	name = "treasure hunter's coat"
	desc = "Both fashionable and lightly armoured, this jacket is favoured by treasure hunters the galaxy over."
	icon_state = "curator"
	inhand_icon_state = null
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/melee/curator_whip
	)
	armor_type = /datum/armor/jacket_curator
	cold_protection = CHEST|ARMS
	heat_protection = CHEST|ARMS

//Roboticist


/datum/armor/jacket_curator
	melee = 25
	bullet = 10
	laser = 25
	energy = 10
	acid = 45
	stamina = 30
	bleed = 10

/obj/item/clothing/suit/hooded/techpriest
	name = "techpriest robes"
	desc = "For those who REALLY love their toasters."
	icon_state = "techpriest"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/techpriest

/obj/item/clothing/head/hooded/techpriest
	name = "techpriest's hood"
	desc = "A hood for those who REALLY love their toasters."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "techpriesthood"
	inhand_icon_state = null
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
