/**
 * # Vending Refills Cargo Items
 *
 * All vending machine refills consolidated into a single category.
 * Split into Wardrobe Refills, Department Vendors, Food & Drink Vendors,
 * Hydroponics Vendors, and General Vendors.
 */

// =============================================================================
// WARDROBE REFILLS
// =============================================================================

/datum/cargo_item/refills_wardrobe
	category = "Vending Refills"
	subcategory = "Wardrobe Refills"

/datum/cargo_item/refills_wardrobe/autodrobe
	name = "AutoDrobe Refill"
	item_path = /obj/item/vending_refill/autodrobe
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_wardrobe/clothesmate
	name = "ClothesMate Refill"
	item_path = /obj/item/vending_refill/clothing
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_wardrobe/cargo_wardrobe
	name = "Cargo Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/cargo_wardrobe
	cost = 800
	max_supply = 3
	access_budget = ACCESS_CARGO

/datum/cargo_item/refills_wardrobe/hydro_wardrobe
	name = "Hydroponics Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/hydro_wardrobe
	cost = 800
	max_supply = 3
	access_budget = ACCESS_HYDROPONICS

/datum/cargo_item/refills_wardrobe/engi_wardrobe
	name = "Engineering Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/engi_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_ENGINE_EQUIP

/datum/cargo_item/refills_wardrobe/atmos_wardrobe
	name = "Atmospherics Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/atmos_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_ATMOSPHERICS

/datum/cargo_item/refills_wardrobe/curator_wardrobe
	name = "Curator Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/curator_wardrobe
	cost = 600
	max_supply = 3

/datum/cargo_item/refills_wardrobe/bar_wardrobe
	name = "Bar Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/bar_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_BAR

/datum/cargo_item/refills_wardrobe/chef_wardrobe
	name = "Chef Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/chef_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_KITCHEN

/datum/cargo_item/refills_wardrobe/jani_wardrobe
	name = "Janitor Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/jani_wardrobe
	cost = 600
	max_supply = 3

/datum/cargo_item/refills_wardrobe/chap_wardrobe
	name = "Chaplain Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/chap_wardrobe
	cost = 600
	max_supply = 3

/datum/cargo_item/refills_wardrobe/medi_wardrobe
	name = "Medical Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/medi_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/refills_wardrobe/chem_wardrobe
	name = "Chemistry Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/chem_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/refills_wardrobe/gene_wardrobe
	name = "Genetics Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/gene_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/refills_wardrobe/viro_wardrobe
	name = "Virology Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/viro_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_MEDICAL

/datum/cargo_item/refills_wardrobe/robo_wardrobe
	name = "Robotics Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/robo_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_RESEARCH

/datum/cargo_item/refills_wardrobe/science_wardrobe
	name = "Science Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/science_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_RESEARCH

/datum/cargo_item/refills_wardrobe/sec_wardrobe
	name = "Security Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/sec_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_SECURITY

/datum/cargo_item/refills_wardrobe/det_wardrobe
	name = "Detective Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/det_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_SECURITY

/datum/cargo_item/refills_wardrobe/law_wardrobe
	name = "Lawyer Wardrobe Refill"
	item_path = /obj/item/vending_refill/wardrobe/law_wardrobe
	cost = 600
	max_supply = 3
	access_budget = ACCESS_SECURITY

// =============================================================================
// DEPARTMENT VENDOR REFILLS
// =============================================================================

/datum/cargo_item/refills_dept
	category = "Vending Refills"
	subcategory = "Department Vendors"

/datum/cargo_item/refills_dept/sectech
	name = "SecTech Vendor Refill"
	item_path = /obj/item/vending_refill/security
	cost = 1200
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/refills_dept/engivend
	name = "EngiVend Refill"
	item_path = /obj/item/vending_refill/engivend
	cost = 800
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/refills_dept/youtool
	name = "YouTool Refill"
	item_path = /obj/item/vending_refill/tool
	cost = 800
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/refills_dept/nanomed
	name = "NanoMed Vendor Refill"
	item_path = /obj/item/vending_refill/medical
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_dept/wallmed
	name = "Wall NanoMed Refill"
	item_path = /obj/item/vending_refill/wallmed
	cost = 700
	max_supply = 3

/datum/cargo_item/refills_dept/modularpc
	name = "Modular PC Vendor Refill"
	item_path = /obj/item/vending_refill/modularpc
	cost = 1000
	max_supply = 3

/datum/cargo_item/refills_dept/robotics
	name = "Robotics Vendor Refill"
	item_path = /obj/item/vending_refill/robotics
	cost = 500
	max_supply = 3
	access_budget = ACCESS_ROBOTICS

/datum/cargo_item/refills_dept/engineering_vendor
	name = "Engineering Vendor Refill"
	item_path = /obj/item/vending_refill/engineering
	cost = 500
	max_supply = 3
	access_budget = ACCESS_ENGINE_EQUIP

// =============================================================================
// FOOD & DRINK VENDOR REFILLS
// =============================================================================

/datum/cargo_item/refills_food
	category = "Vending Refills"
	subcategory = "Food & Drink Vendors"

/datum/cargo_item/refills_food/boozeomat
	name = "Booze-O-Mat Refill"
	item_path = /obj/item/vending_refill/boozeomat
	cost = 800
	max_supply = 3
	access_budget = ACCESS_BAR

/datum/cargo_item/refills_food/coffee
	name = "Coffee Machine Refill"
	item_path = /obj/item/vending_refill/coffee
	cost = 700
	max_supply = 3

/datum/cargo_item/refills_food/dinnerware
	name = "Dinnerware Vendor Refill"
	item_path = /obj/item/vending_refill/dinnerware
	cost = 800
	max_supply = 3
	access_budget = ACCESS_KITCHEN

/datum/cargo_item/refills_food/snack
	name = "Snack Vendor Refill"
	item_path = /obj/item/vending_refill/snack
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_food/cola
	name = "Soda Vendor Refill"
	item_path = /obj/item/vending_refill/cola
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_food/sustenance
	name = "Sustenance Vendor Refill"
	item_path = /obj/item/vending_refill/sustenance
	cost = 500
	max_supply = 3

/datum/cargo_item/refills_food/sovietsoda
	name = "Soviet Soda Vendor Refill"
	item_path = /obj/item/vending_refill/sovietsoda
	cost = 500
	max_supply = 3

// =============================================================================
// GENERAL VENDOR REFILLS
// =============================================================================

/datum/cargo_item/refills_general
	category = "Vending Refills"
	subcategory = "General Vendors"

/datum/cargo_item/refills_general/cigarette
	name = "Cigarette Vendor Refill"
	item_path = /obj/item/vending_refill/cigarette
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_general/games
	name = "Games Vendor Refill"
	item_path = /obj/item/vending_refill/games
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_general/ptech
	name = "PTech Vendor Refill"
	item_path = /obj/item/vending_refill/job_disk
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_general/vendomat
	name = "Vendomat Refill"
	item_path = /obj/item/vending_refill/assist
	cost = 800
	max_supply = 3

/datum/cargo_item/refills_general/donksoft
	name = "Donksoft Vending Refill"
	item_path = /obj/item/vending_refill/donksoft
	cost = 500
	max_supply = 3

// =============================================================================
// HYDROPONICS VENDOR REFILLS
// =============================================================================

/datum/cargo_item/refills_hydro
	category = "Vending Refills"
	subcategory = "Hydroponics Vendors"

/datum/cargo_item/refills_hydro/hydroseeds
	name = "Seed Vendor Refill"
	item_path = /obj/item/vending_refill/hydroseeds
	cost = 600
	max_supply = 3
	access_budget = ACCESS_HYDROPONICS

/datum/cargo_item/refills_hydro/hydronutrients
	name = "Nutrient Vendor Refill"
	item_path = /obj/item/vending_refill/hydronutrients
	cost = 600
	max_supply = 3
	access_budget = ACCESS_HYDROPONICS
