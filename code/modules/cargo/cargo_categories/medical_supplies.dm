/**
 * # Medical Supplies Cargo Items
 *
 * First aid, pharmaceuticals, surgery, virology, and medical equipment.
 * Split into First Aid, Pharmaceuticals, Surgery & Equipment, and Virology.
 */

// =============================================================================
// FIRST AID
// =============================================================================

/datum/cargo_item/medical_firstaid
	category = "Medical Supplies"
	subcategory = "First Aid"
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/medical_firstaid/firstaid_regular
	name = "First Aid Kit"
	item_path = /obj/item/storage/firstaid/regular
	cost = 300
	max_supply = 5

/datum/cargo_item/medical_firstaid/firstaid_brute
	name = "Brute First Aid Kit"
	item_path = /obj/item/storage/firstaid/brute
	cost = 350
	max_supply = 4

/datum/cargo_item/medical_firstaid/firstaid_burn
	name = "Burn First Aid Kit"
	item_path = /obj/item/storage/firstaid/fire
	cost = 350
	max_supply = 4

/datum/cargo_item/medical_firstaid/firstaid_oxy
	name = "Oxygen Deprivation First Aid Kit"
	item_path = /obj/item/storage/firstaid/o2
	cost = 350
	max_supply = 4

/datum/cargo_item/medical_firstaid/firstaid_toxin
	name = "Toxin First Aid Kit"
	item_path = /obj/item/storage/firstaid/toxin
	cost = 350
	max_supply = 4

/datum/cargo_item/medical_firstaid/gauze
	name = "Medical Gauze"
	item_path = /obj/item/stack/medical/gauze
	cost = 100
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/medical_firstaid/antiviral_syringe
	name = "Antiviral Syringe"
	item_path = /obj/item/reagent_containers/syringe/antiviral
	cost = 100
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/medical_firstaid/biobag
	name = "Bio Bag"
	item_path = /obj/item/storage/bag/bio
	cost = 150
	max_supply = 4
	small_item = TRUE

// =============================================================================
// PHARMACEUTICALS
// =============================================================================

/datum/cargo_item/medical_pharma
	category = "Medical Supplies"
	subcategory = "Pharmaceuticals"
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/medical_pharma/synthflesh
	name = "Synthflesh Bottle"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/synthflesh
	cost = 600
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/medical_pharma/chem_bag_bicaridine
	name = "Bicaridine Infusion Bag"
	item_path = /obj/item/reagent_containers/chem_bag/bicaridine
	cost = 700
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/medical_pharma/chem_bag_kelotane
	name = "Kelotane Infusion Bag"
	item_path = /obj/item/reagent_containers/chem_bag/kelotane
	cost = 700
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/medical_pharma/chem_bag_antitoxin
	name = "Antitoxin Infusion Bag"
	item_path = /obj/item/reagent_containers/chem_bag/antitoxin
	cost = 700
	max_supply = 3
	small_item = TRUE

// =============================================================================
// MEDICAL EQUIPMENT
// =============================================================================

/datum/cargo_item/medical_equip
	category = "Medical Supplies"
	subcategory = "Equipment"
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/medical_equip/defibrillator
	name = "Defibrillator"
	item_path = /obj/item/defibrillator/loaded
	cost = 1500
	max_supply = 2

/datum/cargo_item/medical_equip/rollerbed
	name = "Roller Bed"
	item_path = /obj/item/rollerbed
	cost = 200
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/medical_equip/iv_drip
	name = "IV Drip Stand"
	item_path = /obj/machinery/iv_drip
	cost = 500
	max_supply = 3

/datum/cargo_item/medical_equip/salglu_iv
	name = "Saline-Glucose IV Drip"
	item_path = /obj/machinery/iv_drip/saline
	cost = 2000
	max_supply = 2

/datum/cargo_item/medical_equip/pandemic
	name = "PanD.E.M.I.C. Computer"
	item_path = /obj/machinery/computer/pandemic
	cost = 3000
	max_supply = 1
	access_budget = ACCESS_VIROLOGY

/datum/cargo_item/medical_equip/survival_capsule_medical
	name = "Medical Survival Capsule"
	item_path = /obj/item/survivalcapsule/medical
	cost = 1500
	max_supply = 2
	small_item = TRUE

// =============================================================================
// EMERGENCY MEDICAL
// =============================================================================

/datum/cargo_item/medical_emergency
	category = "Medical Supplies"
	subcategory = "Emergency"

/datum/cargo_item/medical_emergency/oxygen_tank
	name = "Emergency Oxygen Tank"
	item_path = /obj/item/tank/internals/emergency_oxygen
	cost = 50
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/medical_emergency/breath_mask
	name = "Breath Mask"
	item_path = /obj/item/clothing/mask/breath
	cost = 10
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/medical_emergency/air_tank
	name = "Air Tank"
	item_path = /obj/item/tank/internals/air
	cost = 75
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/medical_emergency/red_oxy_tank
	name = "Red Oxygen Tank"
	item_path = /obj/item/tank/internals/oxygen/red
	cost = 100
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/medical_emergency/extinguisher
	name = "Advanced Fire Extinguisher"
	item_path = /obj/item/extinguisher/advanced
	cost = 150
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/medical_emergency/flashlight
	name = "Flashlight"
	item_path = /obj/item/flashlight
	cost = 10
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/medical_emergency/metalfoam
	name = "Metal Foam Grenades"
	desc = "A box of metal foam grenades for quick hull repair."
	item_path = /obj/item/storage/box/metalfoam
	cost = 300
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/medical_emergency/antiweed_grenade
	name = "Anti-Weed Grenade"
	item_path = /obj/item/grenade/chem_grenade/antiweed
	cost = 200
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/medical_emergency/survival_capsule_space
	name = "Space Survival Capsule"
	item_path = /obj/item/survivalcapsule/space
	cost = 1500
	max_supply = 2
	small_item = TRUE

/datum/cargo_item/medical_emergency/atmos_watertank
	name = "Atmos Firefighting Tank"
	desc = "A backpack water tank for atmospherics firefighting."
	item_path = /obj/item/watertank/atmos
	cost = 1500
	max_supply = 2

// =============================================================================
// MEDICAL SUPPLY CRATES
// =============================================================================

/datum/cargo_crate/medical
	category = "Medical Supplies"
	subcategory = "Medical Packs"
	access_budget = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

/datum/cargo_crate/medical/bloodpacks
	name = "Blood Pack Crate"
	desc = "Contains fifteen random blood packs."
	cost = 3000
	max_supply = 2
	contains = list(
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
		/obj/item/reagent_containers/blood/random,
	)
	crate_type = /obj/structure/closet/crate/freezer

/datum/cargo_crate/medical/chemical
	name = "Chemistry Crate"
	desc = "Contains a variety of chemical reagent bottles, science goggles, a dropper, and beakers."
	cost = 2500
	max_supply = 2
	access_budget = ACCESS_CHEMISTRY
	contains = list(
		/obj/item/reagent_containers/cup/bottle/hydrogen,
		/obj/item/reagent_containers/cup/bottle/carbon,
		/obj/item/reagent_containers/cup/bottle/nitrogen,
		/obj/item/reagent_containers/cup/bottle/oxygen,
		/obj/item/reagent_containers/cup/bottle/fluorine,
		/obj/item/reagent_containers/cup/bottle/phosphorus,
		/obj/item/reagent_containers/cup/bottle/silicon,
		/obj/item/reagent_containers/cup/bottle/chlorine,
		/obj/item/reagent_containers/cup/bottle/radium,
		/obj/item/reagent_containers/cup/bottle/sacid,
		/obj/item/reagent_containers/cup/bottle/ethanol,
		/obj/item/reagent_containers/cup/bottle/potassium,
		/obj/item/reagent_containers/cup/bottle/sugar,
		/obj/item/clothing/glasses/science,
		/obj/item/reagent_containers/dropper,
		/obj/item/storage/box/beakers,
	)

/datum/cargo_crate/medical/supplies
	name = "Medical Supplies Crate"
	desc = "A comprehensive medical resupply containing reagent bottles, beakers, syringes, body bags, first aid kits, a defibrillator, blood, and more."
	cost = 5000
	max_supply = 1
	contains = list(
		/obj/item/reagent_containers/cup/bottle/charcoal,
		/obj/item/reagent_containers/cup/bottle/epinephrine,
		/obj/item/reagent_containers/cup/bottle/morphine,
		/obj/item/reagent_containers/cup/bottle/toxin,
		/obj/item/reagent_containers/cup/beaker/large,
		/obj/item/reagent_containers/pill/insulin,
		/obj/item/stack/medical/gauze,
		/obj/item/storage/box/beakers,
		/obj/item/storage/box/medsprays,
		/obj/item/storage/box/syringes,
		/obj/item/storage/box/bodybags,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/o2,
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/fire,
		/obj/item/defibrillator/loaded,
		/obj/item/reagent_containers/blood/OMinus,
		/obj/item/storage/pill_bottle/mining,
		/obj/item/reagent_containers/pill/neurine,
		/obj/item/vending_refill/medical,
	)

/datum/cargo_crate/medical/supplies/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/medical/surgery
	name = "Surgery Crate"
	desc = "Contains a surgical duffelbag, sterilizine spray, and a roller bed."
	cost = 3500
	max_supply = 2
	access = ACCESS_SURGERY
	access_budget = ACCESS_SURGERY
	contains = list(
		/obj/item/storage/backpack/duffelbag/med/surgery,
		/obj/item/reagent_containers/medspray/sterilizine,
		/obj/item/rollerbed,
	)

/datum/cargo_crate/medical/implants
	name = "Medical Implant Crate"
	desc = "Contains a duffelbag of medical implants."
	cost = 3000
	max_supply = 2
	access = ACCESS_MEDICAL
	contains = list(/obj/item/storage/backpack/duffelbag/med/implant)

/datum/cargo_crate/medical/virology
	name = "Virology Crate"
	desc = "Contains virology supplies: a monkey cube, mutagen, formaldehyde, synaptizine, beakers, and a figurine."
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_VIROLOGY
	contains = list(
		/obj/item/food/monkeycube,
		/obj/item/reagent_containers/cup/bottle/mutagen,
		/obj/item/reagent_containers/cup/bottle/formaldehyde,
		/obj/item/reagent_containers/cup/bottle/synaptizine,
		/obj/item/storage/box/beakers,
		/obj/item/toy/figure/virologist,
	)

/datum/cargo_crate/medical/virus
	name = "Virus Crate"
	desc = "Contains a selection of disease cultures for virology research."
	cost = 3000
	max_supply = 1
	access = ACCESS_VIROLOGY
	access_budget = ACCESS_VIROLOGY
	contains = list(
		/obj/item/reagent_containers/cup/bottle/fake_gbs,
		/obj/item/reagent_containers/cup/bottle/magnitis,
		/obj/item/reagent_containers/cup/bottle/pierrot_throat,
		/obj/item/reagent_containers/cup/bottle/brainrot,
		/obj/item/reagent_containers/cup/bottle/anxiety,
		/obj/item/reagent_containers/cup/bottle/beesease,
	)
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/cargo_crate/medical/randomvirus
	name = "Utility Virus Crate"
	desc = "Contains five utility virology samples."
	cost = 3500
	max_supply = 1
	access = ACCESS_VIROLOGY
	access_budget = ACCESS_VIROLOGY
	contains = list(
		/obj/item/reagent_containers/cup/bottle/inorganic_virion,
		/obj/item/reagent_containers/cup/bottle/necrotic_virion,
		/obj/item/reagent_containers/cup/bottle/evolution_virion,
		/obj/item/reagent_containers/cup/bottle/adaptation_virion,
		/obj/item/reagent_containers/cup/bottle/aggression_virion,
	)
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/cargo_crate/medical/randomvirus/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/medical/emergency_equip
	name = "Emergency Equipment Crate"
	desc = "Contains two floorbots, two medbots, and five sets of internals."
	cost = 3500
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/medbot/filled,
		/mob/living/simple_animal/bot/medbot/filled,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)
	crate_type = /obj/structure/closet/crate/internals

// --- Contraband Emergency ---

/datum/cargo_crate/medical/specialops
	name = "Special Ops Supplies"
	desc = "A crate of dubiously-legal tactical equipment."
	cost = 5000
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/storage/box/emps,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/pen/paralytic,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	crate_type = /obj/structure/closet/crate/internals
