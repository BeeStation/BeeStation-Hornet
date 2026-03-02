/**
 * # Medical Supplies Cargo Items
 *
 * First aid, pharmaceuticals, surgery, virology, and medical equipment.
 * Split into First Aid, Pharmaceuticals, Surgery & Equipment, and Virology.
 */

// =============================================================================
// FIRST AID
// =============================================================================

/datum/cargo_list/medical_firstaid
	access_budget = ACCESS_MEDICAL
	entries = list(
		list("path" = /obj/item/storage/firstaid/regular, "cost" = 300, "max_supply" = 5),
		list("path" = /obj/item/storage/firstaid/brute, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/fire, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/o2, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/toxin, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/stack/medical/gauze, "cost" = 100, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/syringe/antiviral, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/storage/bag/bio, "cost" = 150, "max_supply" = 4, "small_item" = TRUE),
	)

// =============================================================================
// PHARMACEUTICALS
// =============================================================================

/datum/cargo_list/medical_pharma
	access_budget = ACCESS_MEDICAL
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/synthflesh, "cost" = 600, "max_supply" = 5),
		list("path" = /obj/item/reagent_containers/chem_bag/bicaridine, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/kelotane, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/antitoxin, "cost" = 700, "max_supply" = 3),
	)

// =============================================================================
// IMPLANTS
// =============================================================================

/datum/cargo_list/medical_implants
	access_budget = ACCESS_MEDICAL
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/implantcase/chem, "cost" = 300, "max_supply" = 10),
		list("path" = /obj/item/implantcase/exile, "cost" = 500, "max_supply" = 5, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// IMPLANT KITS
// =============================================================================

/datum/cargo_list/medical_implant_kits
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/storage/box/chemimp, "cost" = 1500, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/storage/box/exileimp, "cost" = 2500, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
		list("path" = /obj/item/storage/lockbox/loyalty, "cost" = 3500, "max_supply" = 2, "access" = ACCESS_ARMORY, "access_budget" = ACCESS_ARMORY),
	)

// =============================================================================
// MEDICAL EQUIPMENT
// =============================================================================

/datum/cargo_list/medical_equip
	access_budget = ACCESS_MEDICAL
	entries = list(
		list("path" = /obj/item/defibrillator/loaded, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/rollerbed, "cost" = 200, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/machinery/iv_drip, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/machinery/iv_drip/saline, "cost" = 2000, "max_supply" = 2),
		list("path" = /obj/machinery/computer/pandemic, "cost" = 3000, "max_supply" = 1, "access_budget" = ACCESS_VIROLOGY),
		list("path" = /obj/item/survivalcapsule/medical, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/implanter, "cost" = 200, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/implantpad, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
	)

// =============================================================================
// EMERGENCY MEDICAL
// =============================================================================

/datum/cargo_list/medical_emergency
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/tank/internals/emergency_oxygen, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/clothing/mask/breath, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/tank/internals/air, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/tank/internals/oxygen/red, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/extinguisher/advanced, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/flashlight, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/storage/box/metalfoam, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/grenade/chem_grenade/antiweed, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/survivalcapsule/space, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/watertank/atmos, "cost" = 1500, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// MEDICAL SUPPLY CRATES
// =============================================================================

/datum/cargo_crate/medical
	access_budget = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

/datum/cargo_crate/medical/bloodpacks
	name = "Blood Pack Crate"
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
	cost = 3000
	max_supply = 2
	access = ACCESS_MEDICAL
	contains = list(/obj/item/storage/backpack/duffelbag/med/implant)

/datum/cargo_crate/medical/virology
	name = "Virology Crate"
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
