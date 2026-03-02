/**
 * # Equipment Cargo Items
 *
 * Handheld gear, portable equipment, tools, and personal devices.
 * Split into Hand Tools, Engineering Tools, Janitorial, Hydroponics Tools,
 * Forensics & Detection, Cargo & Service, EVA & Mobility, and Tool Packs.
 */

// =============================================================================
// HAND TOOLS
// =============================================================================

/datum/cargo_list/tools_hand
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/screwdriver, "cost" = 7, "max_supply" = 8),
		list("path" = /obj/item/wrench, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/weldingtool, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/item/crowbar, "cost" = 12, "max_supply" = 8),
		list("path" = /obj/item/wirecutters, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/multitool, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/item/t_scanner, "cost" = 150, "max_supply" = 1),
		list("path" = /obj/item/storage/toolbox/electrical, "cost" = 250, "max_supply" = 2),
		list("path" = /obj/item/storage/toolbox/mechanical, "cost" = 250, "max_supply" = 2),
	)

// =============================================================================
// ENGINEERING TOOLS
// =============================================================================

/datum/cargo_list/tools_engineering
	access_budget = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/storage/belt/utility, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/hardhat, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/utility/welding, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/clothing/glasses/meson/engine, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/color/yellow, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/sealant, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/inducer, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/item/construction/rcd, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/rcd_ammo, "cost" = 300, "max_supply" = 6),
	)

// =============================================================================
// JANITORIAL
// =============================================================================

/datum/cargo_list/tools_janitor
	access_budget = ACCESS_JANITOR
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/mop, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bucket, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/pushbroom, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/storage/bag/trash, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/spray/cleaner, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/clothing/suit/caution, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/grenade/chem_grenade/cleaner, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/noslip/thirty, "cost" = 500, "max_supply" = 6, "small_item" = FALSE),
		list("path" = /obj/structure/janitorialcart, "cost" = 700, "max_supply" = 2, "small_item" = FALSE, "crate_type" = /obj/structure/closet/crate/large),
		list("path" = /obj/item/watertank/janitor, "cost" = 1500, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// HYDROPONICS TOOLS
// =============================================================================

/datum/cargo_list/tools_hydro
	access_budget = ACCESS_HYDROPONICS
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/hatchet, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/cultivator, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/plant_analyzer, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/spray/plantbgone, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/clothing/gloves/botanic_leather, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/watertank, "cost" = 1000, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// FORENSICS & DETECTION
// =============================================================================

/datum/cargo_list/tools_forensics
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/detective_scanner, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/healthanalyzer, "cost" = 200, "max_supply" = 4, "access_budget" = ACCESS_MEDICAL),
		list("path" = /obj/item/geiger_counter, "cost" = 100, "max_supply" = 4, "access_budget" = FALSE),
		list("path" = /obj/item/export_scanner, "cost" = 100, "max_supply" = 3, "access_budget" = FALSE),
	)

// =============================================================================
// CARGO & SERVICE
// =============================================================================

/datum/cargo_list/tools_cargo
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/stamp, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/stamp/denied, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/dest_tagger, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/hand_labeler, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/stack/package_wrap, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/storage/box/lights/mixed, "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/storage/backpack/duffelbag/mining_conscript, "cost" = 2000, "max_supply" = 2, "small_item" = FALSE, "access_budget" = ACCESS_MINING),
	)

// =============================================================================
// EVA & MOBILITY
// =============================================================================

/datum/cargo_list/equipment_eva
	access_budget = ACCESS_ENGINE_EQUIP
	entries = list(
		list("path" = /obj/item/tank/jetpack/carbondioxide, "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/item/tank/jetpack/combustion, "cost" = 2000, "max_supply" = 2),
	)

// =============================================================================
// EQUIPMENT PACKS (CRATES)
// =============================================================================

/datum/cargo_crate/tools

/datum/cargo_crate/tools/janitor
	name = "Janitorial Supplies Crate"
	cost = 1500
	max_supply = 2
	access_budget = ACCESS_JANITOR
	contains = list(
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/mop,
		/obj/item/pushbroom,
		/obj/item/clothing/suit/caution,
		/obj/item/clothing/suit/caution,
		/obj/item/clothing/suit/caution,
		/obj/item/storage/bag/trash,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/cup/rag,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
	)

/datum/cargo_crate/tools/forensics
	name = "Forensics Crate"
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_SECURITY
	contains = list(
		/obj/item/detective_scanner,
		/obj/item/storage/box/evidence,
		/obj/item/camera/detective,
		/obj/item/taperecorder,
		/obj/item/toy/crayon/white,
		/obj/item/clothing/head/fedora/det_hat,
	)
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/cargo_crate/tools/hydro_supplies
	name = "Hydroponics Supply Crate"
	cost = 1500
	max_supply = 2
	access_budget = ACCESS_HYDROPONICS
	contains = list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/cup/bottle/ammonia,
		/obj/item/reagent_containers/cup/bottle/ammonia,
		/obj/item/hatchet,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/clothing/suit/apron,
		/obj/item/storage/box/disks_plantgene,
	)
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/cargo_crate/tools/minerkit
	name = "Mining Conscription Kit"
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_MINING
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
