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
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Basic tools (found in tool closets, YouTool, emergency closets) --
		list("path" = /obj/item/screwdriver, "cost" = 7, "max_supply" = 8),
		list("path" = /obj/item/wrench, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/weldingtool, "cost" = 40, "max_supply" = 6),
		list("path" = /obj/item/crowbar, "cost" = 12, "max_supply" = 8),
		list("path" = /obj/item/wirecutters, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/multitool, "cost" = 75, "max_supply" = 4),
		list("path" = /obj/item/t_scanner, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/analyzer, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/flashlight, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/flashlight/seclite, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/stack/cable_coil, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/stack/sticky_tape, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/stack/sticky_tape/duct, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/clothing/ears/earmuffs, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/clothing/suit/hazardvest, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/extinguisher, "cost" = 50, "max_supply" = 8),
		list("path" = /obj/item/extinguisher/mini, "cost" = 30, "max_supply" = 8),
		// -- Toolboxes --
		list("path" = /obj/item/storage/toolbox/emergency, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/storage/toolbox/mechanical, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/storage/toolbox/electrical, "cost" = 250, "max_supply" = 4),
		// -- Upgraded tools (YouTool premium) --
		list("path" = /obj/item/weldingtool/hugetank, "cost" = 200, "max_supply" = 3),
	)

// =============================================================================
// ENGINEERING TOOLS
// =============================================================================

/datum/cargo_list/tools_engineering
	crate_type = /obj/structure/closet/crate/secure/engineering
	access_budget = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	entries = list(
		// -- Belts & bags --
		list("path" = /obj/item/storage/belt/utility, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/storage/bag/construction, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/storage/box/emptysandbags, "cost" = 100, "max_supply" = 6),
		// -- Personal protective equipment --
		list("path" = /obj/item/clothing/head/utility/welding, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/clothing/glasses/meson/engine, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/clothing/gloves/color/yellow, "cost" = 500, "max_supply" = 4),
		// -- Repair & construction --
		list("path" = /obj/item/sealant, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/inducer, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/item/construction/rcd, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/rcd_ammo, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/rcd_ammo/large, "cost" = 900, "max_supply" = 3),
		list("path" = /obj/item/electronics/apc, "cost" = 100, "max_supply" = 6),
		// -- Atmospherics & signage --
		list("path" = /obj/item/pipe_dispenser, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/airlock_painter, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/airlock_painter/decal, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/holosign_creator/engineering, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/holosign_creator/atmos, "cost" = 400, "max_supply" = 3, "access_budget" = ACCESS_ATMOSPHERICS),
		// -- Fire & emergency --
		list("path" = /obj/item/extinguisher/advanced, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/watertank/atmos, "cost" = 1500, "max_supply" = 2, "small_item" = FALSE, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/item/forcefield_projector, "cost" = 600, "max_supply" = 2),
	)

// =============================================================================
// JANITORIAL
// =============================================================================

/datum/cargo_list/tools_janitor
	crate_type = /obj/structure/closet/crate/secure/gear
	access_budget = ACCESS_JANITOR
	small_item = TRUE
	entries = list(
		// -- Cleaning supplies --
		list("path" = /obj/item/mop, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/bucket, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/pushbroom, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/storage/bag/trash, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/spray/cleaner, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/reagent_containers/cup/rag, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/soap/nanotrasen, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/caution, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/grenade/chem_grenade/cleaner, "cost" = 150, "max_supply" = 6),
		// -- Tools & equipment --
		list("path" = /obj/item/lightreplacer, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/holosign_creator, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/holosign_creator/janibarrier, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/storage/box/lights/mixed, "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/storage/box/lights/bulbs, "cost" = 80, "max_supply" = 8),
		list("path" = /obj/item/storage/box/lights/tubes, "cost" = 80, "max_supply" = 8),
		// -- Large equipment --
		list("path" = /obj/structure/janitorialcart, "cost" = 700, "max_supply" = 2, "small_item" = FALSE, "crate_type" = /obj/structure/closet/crate/large),
		list("path" = /obj/item/watertank/janitor, "cost" = 1500, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// HYDROPONICS TOOLS
// =============================================================================

/datum/cargo_list/tools_hydro
	crate_type = /obj/structure/closet/crate/secure/hydroponics
	access_budget = ACCESS_HYDROPONICS
	small_item = TRUE
	entries = list(
		// -- Hand tools (hydro closet / MegaSeed) --
		list("path" = /obj/item/hatchet, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/cultivator, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/plant_analyzer, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/clothing/gloves/botanic_leather, "cost" = 100, "max_supply" = 4),
		// -- Plant care sprays --
		list("path" = /obj/item/reagent_containers/spray/plantbgone, "cost" = 75, "max_supply" = 6),
		// -- Specialist equipment --
		list("path" = /obj/item/storage/box/disks_plantgene, "cost" = 200, "max_supply" = 3),
		// -- Large equipment --
		list("path" = /obj/item/watertank, "cost" = 1000, "max_supply" = 2, "small_item" = FALSE),
	)

// =============================================================================
// FORENSICS & DETECTION
// =============================================================================

/datum/cargo_list/tools_forensics
	crate_type = /obj/structure/closet/crate/secure/gear
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	entries = list(
		// -- Security / detective tools --
		list("path" = /obj/item/detective_scanner, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/camera/detective, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/taperecorder, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/storage/box/evidence, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/toy/crayon/white, "cost" = 10, "max_supply" = 6),
		// -- General-access scanners --
		list("path" = /obj/item/geiger_counter, "cost" = 100, "max_supply" = 4, "access_budget" = FALSE),
		list("path" = /obj/item/export_scanner, "cost" = 100, "max_supply" = 3, "access_budget" = FALSE),
		list("path" = /obj/item/binoculars, "cost" = 150, "max_supply" = 3, "access_budget" = FALSE),
	)

// =============================================================================
// CARGO & SERVICE
// =============================================================================

/datum/cargo_list/tools_cargo
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Cargo tools (QM locker / cargo bay) --
		list("path" = /obj/item/dest_tagger, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/stack/package_wrap, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/megaphone, "cost" = 200, "max_supply" = 2),
		// -- Mining --
		list("path" = /obj/item/storage/backpack/duffelbag/mining_conscript, "cost" = 2000, "max_supply" = 2, "small_item" = FALSE, "access_budget" = ACCESS_MINING),
	)

// =============================================================================
// EVA & MOBILITY
// =============================================================================

/datum/cargo_list/equipment_eva
	crate_type = /obj/structure/closet/crate/secure/engineering
	access_budget = ACCESS_ENGINE_EQUIP
	entries = list(
		// -- Internals tanks (larger capacity, for EVA use) --
		list("path" = /obj/item/tank/internals/oxygen, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/tank/internals/emergency_oxygen/engi, "cost" = 100, "max_supply" = 6),
		// -- Jetpacks --
		list("path" = /obj/item/tank/jetpack/oxygen, "cost" = 2000, "max_supply" = 2),
		list("path" = /obj/item/tank/jetpack/void, "cost" = 2000, "max_supply" = 2),
		list("path" = /obj/item/tank/jetpack/carbondioxide, "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/item/tank/jetpack/combustion, "cost" = 3000, "max_supply" = 1),
	)

// =============================================================================
// EQUIPMENT PACKS (CRATES)
// Only for dangerous, specialty bundles, or items that require special handling.
// Standard equipment should be purchaseable individually from the lists above.
// =============================================================================

/datum/cargo_crate/tools

/datum/cargo_crate/tools/minerkit
	name = "Mining Conscription Kit"
	cost = 2000
	max_supply = 2
	access_budget = ACCESS_MINING
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
