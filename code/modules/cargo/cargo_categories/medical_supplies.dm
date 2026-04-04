/**
 * # Medical Supplies Cargo Items
 *
 * First aid, pharmaceuticals, surgery, virology, and medical equipment.
 * Split into: First Aid, Pharmaceuticals, Reagent Bottles, Chemistry Supplies,
 * Surgery Tools, Medical Equipment, Medical Diagnostics, Medical Containers,
 * Implants, Virology, and Emergency.
 */

// =============================================================================
// FIRST AID
// =============================================================================

/datum/cargo_list/medical_firstaid
	access_budget = ACCESS_MEDICAL
	entries = list(
		// -- First aid kits --
		list("path" = /obj/item/storage/firstaid/regular, "cost" = 300, "max_supply" = 5),
		list("path" = /obj/item/storage/firstaid/brute, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/fire, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/o2, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/firstaid/toxin, "cost" = 350, "max_supply" = 4),
		// -- Healing stacks --
		list("path" = /obj/item/stack/medical/gauze, "cost" = 100, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/stack/medical/bruise_pack, "cost" = 50, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/stack/medical/ointment, "cost" = 50, "max_supply" = 8, "small_item" = TRUE),
		// -- Patches --
		list("path" = /obj/item/reagent_containers/pill/patch/styptic, "cost" = 40, "max_supply" = 10, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/pill/patch/silver_sulf, "cost" = 40, "max_supply" = 10, "small_item" = TRUE),
		// -- Medipens --
		list("path" = /obj/item/reagent_containers/hypospray/medipen, "cost" = 75, "max_supply" = 10, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/dexalin, "cost" = 75, "max_supply" = 10, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/atropine, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/morphine, "cost" = 75, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/oxandrolone, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/salacid, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/penacid, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/salbutamol, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/hypospray/medipen/vactreat, "cost" = 150, "max_supply" = 6, "small_item" = TRUE),
		// -- Medsprays --
		list("path" = /obj/item/reagent_containers/medspray/styptic, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/medspray/silver_sulf, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/reagent_containers/medspray/sterilizine, "cost" = 75, "max_supply" = 8, "small_item" = TRUE),
		// -- Misc first aid --
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
		// -- IV bags --
		list("path" = /obj/item/reagent_containers/chem_bag/bicaridine, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/kelotane, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/antitoxin, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/epi, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/chem_bag/tricordrazine, "cost" = 900, "max_supply" = 2),
		list("path" = /obj/item/reagent_containers/chem_bag/triamed, "cost" = 900, "max_supply" = 2),
		list("path" = /obj/item/reagent_containers/chem_bag/oxy_mix, "cost" = 1000, "max_supply" = 2),
		// -- Blood packs --
		list("path" = /obj/item/reagent_containers/blood/random, "cost" = 200, "max_supply" = 15),
		list("path" = /obj/item/reagent_containers/blood/OMinus, "cost" = 400, "max_supply" = 5),
		// -- Pill bottles --
		list("path" = /obj/item/storage/pill_bottle/charcoal, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/epinephrine, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/bicaridine, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/kelotane, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/mannitol, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/mutadone, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/antirad, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/psicodine, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/storage/pill_bottle/penacid, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/salbutamol, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle/mining, "cost" = 150, "max_supply" = 6),
		// -- Synthflesh bottle --
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/synthflesh, "cost" = 600, "max_supply" = 5),
		// -- Vending refills --
		list("path" = /obj/item/vending_refill/medical, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/vending_refill/wallmed, "cost" = 800, "max_supply" = 3),
	)

// =============================================================================
// REAGENT BOTTLES (NanoMed / Medicine Closet stock)
// =============================================================================

/datum/cargo_list/medical_bottles
	access_budget = ACCESS_MEDICAL
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/reagent_containers/cup/bottle/epinephrine, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/charcoal, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/morphine, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/toxin, "cost" = 50, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/tricordrazine, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bottle/spaceacillin, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/salglu_solution, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/mannitol, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/antitoxin, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/potass_iodide, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/atropine, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bottle/diphenhydramine, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/formaldehyde, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/calomel, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bottle/synaptizine, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bottle/chloralhydrate, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/cup/bottle/sodium_thiopental, "cost" = 200, "max_supply" = 3),
		// -- Pre-filled syringes (dangerous med closet) --
		list("path" = /obj/item/reagent_containers/syringe/calomel, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/syringe/diphenhydramine, "cost" = 75, "max_supply" = 4),
	)

// =============================================================================
// CHEMISTRY SUPPLIES
// =============================================================================

/datum/cargo_list/medical_chemistry
	access_budget = ACCESS_CHEMISTRY
	small_item = TRUE
	entries = list(
		// -- Raw reagent bottles --
		list("path" = /obj/item/reagent_containers/cup/bottle/hydrogen, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/carbon, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/nitrogen, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/oxygen, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/fluorine, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/phosphorus, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/silicon, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/chlorine, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/radium, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/sacid, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/ethanol, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/potassium, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/sugar, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/lithium, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/sodium, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/aluminium, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/sulfur, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/iron, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/copper, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/mercury, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/silver, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/iodine, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/bromine, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/water, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/bottle/welding_fuel, "cost" = 25, "max_supply" = 10),
		// -- Chemistry glassware & tools --
		list("path" = /obj/item/reagent_containers/cup/beaker, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/beaker/large, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/dropper, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/syringe, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/clothing/glasses/science, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/storage/pill_bottle, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/bottle, "cost" = 25, "max_supply" = 10),
		// -- Boxes --
		list("path" = /obj/item/storage/box/beakers, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/box/syringes, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/box/medsprays, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/box/pillbottles, "cost" = 200, "max_supply" = 4),
		// -- Plumbing supplies --
		list("path" = /obj/item/construction/plumbing, "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/plunger, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/stack/ducts/fifty, "cost" = 200, "max_supply" = 8),
		// -- Chemistry storage --
		list("path" = /obj/item/storage/bag/chemistry, "cost" = 200, "max_supply" = 4),
	)

// =============================================================================
// SURGERY TOOLS
// =============================================================================

/datum/cargo_list/medical_surgery
	access_budget = ACCESS_SURGERY
	small_item = TRUE
	entries = list(
		// -- Basic surgery tools --
		list("path" = /obj/item/scalpel, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/hemostat, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/retractor, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/circular_saw, "cost" = 150, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/surgicaldrill, "cost" = 150, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/cautery, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/blood_filter, "cost" = 150, "max_supply" = 4, "small_item" = FALSE),
		list("path" = /obj/item/surgical_drapes, "cost" = 75, "max_supply" = 6),
		// -- Anesthesia --
		list("path" = /obj/item/tank/internals/anesthetic, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/clothing/mask/breath/medical, "cost" = 50, "max_supply" = 6),
		// -- Surgery duffel bag (contains all basic tools) --
		list("path" = /obj/item/storage/backpack/duffelbag/med/surgery, "cost" = 1200, "max_supply" = 3, "small_item" = FALSE),
		// -- Misc surgical --
		list("path" = /obj/item/clothing/suit/apron/surgical, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/clothing/mask/surgical, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/razor, "cost" = 25, "max_supply" = 4),
	)

// =============================================================================
// MEDICAL DIAGNOSTICS & HAND TOOLS
// =============================================================================

/datum/cargo_list/medical_diagnostics
	access_budget = ACCESS_MEDICAL
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/healthanalyzer, "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/sensor_device, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/pinpointer/crew, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/clothing/glasses/hud/health, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/storage/belt/medical, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/flashlight/pen, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/wrench/medical, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/color/latex, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/clothing/gloves/color/latex/nitrile, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/storage/box/rxglasses, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/storage/box/bodybags, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/bodybag, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/clothing/neck/stethoscope, "cost" = 100, "max_supply" = 4),
	)

// =============================================================================
// MEDICAL EQUIPMENT (large / machinery)
// =============================================================================

/datum/cargo_list/medical_equip
	access_budget = ACCESS_MEDICAL
	entries = list(
		list("path" = /obj/item/defibrillator/loaded, "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/item/wallframe/defib_mount, "cost" = 400, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/rollerbed, "cost" = 200, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/machinery/iv_drip, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/machinery/iv_drip/saline, "cost" = 2000, "max_supply" = 2),
		list("path" = /obj/item/survivalcapsule/medical, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/implanter, "cost" = 200, "max_supply" = 5, "small_item" = TRUE),
		list("path" = /obj/item/implantpad, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/machinery/computer/pandemic, "cost" = 3000, "max_supply" = 1, "access_budget" = ACCESS_VIROLOGY),
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
		// -- Implant duffel (contains random surplus cybernetic implants) --
		list("path" = /obj/item/storage/backpack/duffelbag/med/implant, "cost" = 1500, "max_supply" = 2, "small_item" = FALSE),
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
// VIROLOGY
// =============================================================================

/datum/cargo_list/medical_virology
	access_budget = ACCESS_VIROLOGY
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/reagent_containers/cup/bottle/mutagen, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bottle/plasma, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/food/monkeycube, "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/clothing/suit/bio_suit/virology, "cost" = 300, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/clothing/head/bio_hood/virology, "cost" = 200, "max_supply" = 3),
	)

// =============================================================================
// EMERGENCY MEDICAL
// =============================================================================

/datum/cargo_list/medical_emergency
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/tank/internals/emergency_oxygen, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/tank/internals/air, "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/tank/internals/oxygen/red, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/grenade/chem_grenade/antiweed, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/survivalcapsule/space, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/storage/box/medipens, "cost" = 400, "max_supply" = 4),
	)

// =============================================================================
// MEDICAL CRATES
// =============================================================================

/datum/cargo_crate/medical
	access_budget = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

// Virus crates are kept as crates because they contain dangerous biological material
// that should require deliberate purchase and access control.

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
