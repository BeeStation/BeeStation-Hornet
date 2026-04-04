/**
 * # Vending Refills Cargo Items
 *
 * All vending machine refills consolidated into a single category.
 * Split into Wardrobe Refills, Department Vendors, Food & Drink Vendors,
 * Hydroponics Vendors, and General Vendors.
 *
 * NOTE: The following refills are intentionally housed in other categories:
 *   - NanoMed & WallMed refills       → medical_supplies.dm
 *   - Donksoft refill                  → contraband.dm (Syndicate vendor)
 *   - Sticker Vendor refill           → miscellaneous.dm (part of arts crate)
 *
 * NOT purchaseable (non-station / non-NT):
 *   - CentDrobe (cent_wardrobe)       → CentCom only
 *   - Custom Vendor refill            → player-built vendors, not station standard
 */

// =============================================================================
// WARDROBE REFILLS
// =============================================================================

/datum/cargo_list/refills_wardrobe
	entries = list(
		// -- Public wardrobes (no department access needed) --
		list("path" = /obj/item/vending_refill/autodrobe, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/clothing, "name" = "ClothesMate Refill", "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/wardrobe/curator_wardrobe, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/wardrobe/jani_wardrobe, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/wardrobe/chap_wardrobe, "cost" = 600, "max_supply" = 3),
		// -- Cargo & supply --
		list("path" = /obj/item/vending_refill/wardrobe/cargo_wardrobe, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_CARGO),
		// -- Service --
		list("path" = /obj/item/vending_refill/wardrobe/bar_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_BAR),
		list("path" = /obj/item/vending_refill/wardrobe/chef_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_KITCHEN),
		// -- Hydroponics --
		list("path" = /obj/item/vending_refill/wardrobe/hydro_wardrobe, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_HYDROPONICS),
		// -- Engineering --
		list("path" = /obj/item/vending_refill/wardrobe/engi_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_ENGINE_EQUIP),
		list("path" = /obj/item/vending_refill/wardrobe/atmos_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_ATMOSPHERICS),
		// -- Medical --
		list("path" = /obj/item/vending_refill/wardrobe/medi_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/vending_refill/wardrobe/chem_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/vending_refill/wardrobe/gene_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/vending_refill/wardrobe/viro_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_MEDICAL),
		// -- Science --
		list("path" = /obj/item/vending_refill/wardrobe/robo_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/vending_refill/wardrobe/science_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
		// -- Security --
		list("path" = /obj/item/vending_refill/wardrobe/sec_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/vending_refill/wardrobe/det_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/vending_refill/wardrobe/law_wardrobe, "cost" = 600, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
	)

// =============================================================================
// DEPARTMENT VENDOR REFILLS
// =============================================================================

/datum/cargo_list/refills_dept
	entries = list(
		// -- Security --
		list("path" = /obj/item/vending_refill/security, "name" = "SecTech Vendor Refill", "cost" = 1200, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/item/vending_refill/deputy, "name" = "DepVend Refill", "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_SECURITY),
		// -- Engineering --
		list("path" = /obj/item/vending_refill/engivend, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_ENGINE_EQUIP),
		list("path" = /obj/item/vending_refill/tool, "name" = "YouTool Refill", "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/engineering, "name" = "Engineering Vendor Refill", "cost" = 500, "max_supply" = 3, "access_budget" = ACCESS_ENGINE_EQUIP),
		// -- Science --
		list("path" = /obj/item/vending_refill/robotics, "cost" = 500, "max_supply" = 3, "access_budget" = ACCESS_ROBOTICS),
		list("path" = /obj/item/vending_refill/modularpc, "name" = "Modular PC Vendor Refill", "cost" = 1000, "max_supply" = 3),
		// -- Mining --
		list("path" = /obj/item/vending_refill/mining, "name" = "Mining Vendor Refill", "cost" = 500, "max_supply" = 3),
	)

// =============================================================================
// FOOD & DRINK VENDOR REFILLS
// =============================================================================

/datum/cargo_list/refills_food
	entries = list(
		list("path" = /obj/item/vending_refill/boozeomat, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_BAR),
		list("path" = /obj/item/vending_refill/coffee, "cost" = 700, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/dinnerware, "cost" = 800, "max_supply" = 3, "access_budget" = ACCESS_KITCHEN),
		list("path" = /obj/item/vending_refill/snack, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/cola, "name" = "Soda Vendor Refill", "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/sustenance, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/sovietsoda, "cost" = 500, "max_supply" = 3),
	)

// =============================================================================
// GENERAL VENDOR REFILLS
// =============================================================================

/datum/cargo_list/refills_general
	entries = list(
		list("path" = /obj/item/vending_refill/cigarette, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/games, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/job_disk, "name" = "PTech Vendor Refill", "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/assist, "name" = "Vendomat Refill", "cost" = 800, "max_supply" = 3),
	)

// =============================================================================
// HYDROPONICS VENDOR REFILLS
// =============================================================================

/datum/cargo_list/refills_hydro
	access_budget = ACCESS_HYDROPONICS
	entries = list(
		list("path" = /obj/item/vending_refill/hydroseeds, "name" = "Seed Vendor Refill", "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/vending_refill/hydronutrients, "name" = "Nutrient Vendor Refill", "cost" = 600, "max_supply" = 3),
	)
