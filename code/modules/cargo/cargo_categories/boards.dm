/**
 * # Circuit Board Cargo Items
 *
 * All station-standard computer and machine circuit boards purchaseable through cargo.
 * Sourced from station starting equipment, tech storage spawners, and on-station computers/machines.
 * Excludes boards that are researchable-only, otherwise non-NT in origin, or only found inside
 * specific cargo crates (e.g. mech kits, nuclear reactor crate).
 * Split into: Command Boards, Engineering Boards, Atmospheric Boards, Telecomms Boards,
 * Medical Boards, Science Boards, Security Boards, Service Boards, Supply Boards, and Misc Boards.
 */

// =============================================================================
// COMMAND / BRIDGE BOARDS
// =============================================================================

/datum/cargo_list/boards_command
	access_budget = ACCESS_HOP
	small_item = TRUE
	entries = list(
		// -- ID & comms consoles --
		list("path" = /obj/item/circuitboard/computer/card, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/card/minor, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/communications, "cost" = 250, "max_supply" = 4),
		// -- AI consoles (command access) --
		list("path" = /obj/item/circuitboard/computer/aiupload, "cost" = 500, "max_supply" = 2, "access_budget" = ACCESS_CAPTAIN),
		list("path" = /obj/item/circuitboard/computer/borgupload, "cost" = 400, "max_supply" = 2, "access_budget" = ACCESS_CAPTAIN),
	)

// =============================================================================
// ENGINEERING BOARDS (Power & Station)
// =============================================================================

/datum/cargo_list/boards_engineering
	access_budget = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	entries = list(
		// -- Power monitoring & control --
		list("path" = /obj/item/circuitboard/computer/powermonitor, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/apc_control, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/stationalert, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/solar_control, "cost" = 250, "max_supply" = 4),
		// -- Engine consoles --
		list("path" = /obj/item/circuitboard/computer/turbine_computer, "cost" = 300, "max_supply" = 2, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/computer/teleporter, "cost" = 300, "max_supply" = 2),
		// -- Engineering machine boards --
		list("path" = /obj/item/circuitboard/machine/smes, "cost" = 1000, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/generator, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/power_turbine, "cost" = 600, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/power_compressor, "cost" = 600, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/rtg, "cost" = 1500, "max_supply" = 2, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/pacman, "cost" = 750, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/cell_charger, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/grounding_rod, "cost" = 200, "max_supply" = 6, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/tesla_coil, "cost" = 250, "max_supply" = 6, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/emitter, "cost" = 500, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/igniter, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/circuitboard/machine/scanner_gate, "cost" = 350, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/suit_storage_unit, "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/announcement_system, "cost" = 150, "max_supply" = 4),
		// -- Teleportation boards --
		list("path" = /obj/item/circuitboard/machine/teleporter_station, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/teleporter_hub, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/computer/launchpad_console, "cost" = 400, "max_supply" = 2, "access_budget" = ACCESS_RESEARCH),
		list("path" = /obj/item/circuitboard/machine/launchpad, "cost" = 350, "max_supply" = 3, "access_budget" = ACCESS_RESEARCH),
	)

// =============================================================================
// ATMOSPHERIC BOARDS
// =============================================================================

/datum/cargo_list/boards_atmos
	access_budget = ACCESS_ATMOSPHERICS
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/circuitboard/computer/atmos_control, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/atmos_alert, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/thermomachine, "cost" = 400, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/portable_thermomachine, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/circulator, "cost" = 500, "max_supply" = 4, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/shieldwallgen/atmos, "cost" = 800, "max_supply" = 2),
	)

// =============================================================================
// TELECOMMUNICATIONS BOARDS
// =============================================================================

/datum/cargo_list/boards_telecomms
	access_budget = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/circuitboard/computer/comm_monitor, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/comm_server, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/message_monitor, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/broadcaster, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/bus, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/hub, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/processor, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/telecomms/receiver, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/relay, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/server, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/telecomms/message_server, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/ntnet_relay, "cost" = 400, "max_supply" = 4),
	)

// =============================================================================
// MEDICAL BOARDS
// =============================================================================

/datum/cargo_list/boards_medical
	access_budget = ACCESS_MEDICAL
	small_item = TRUE
	entries = list(
		// -- Medical computers --
		list("path" = /obj/item/circuitboard/computer/crew, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/records/medical, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/operating, "cost" = 250, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/pandemic, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/computer/scan_consolenew, "cost" = 400, "max_supply" = 2),
		// -- Cloning machines --
		list("path" = /obj/item/circuitboard/computer/cloning, "cost" = 500, "max_supply" = 2, "access_budget" = ACCESS_CMO),
		list("path" = /obj/item/circuitboard/machine/clonepod, "cost" = 1000, "max_supply" = 2, "access_budget" = ACCESS_CMO),
		list("path" = /obj/item/circuitboard/machine/clonescanner, "cost" = 600, "max_supply" = 2, "access_budget" = ACCESS_CMO),
		// -- Medical machinery --
		list("path" = /obj/item/circuitboard/machine/chem_dispenser, "cost" = 500, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/chem_heater, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/chem_master, "cost" = 350, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/cryo_tube, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/sleeper, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/stasis, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/limbgrower, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/harvester, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/smoke_machine, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/reagentgrinder, "cost" = 200, "max_supply" = 4),
	)

// =============================================================================
// SCIENCE / RESEARCH BOARDS
// =============================================================================

/datum/cargo_list/boards_science
	access_budget = ACCESS_RESEARCH
	small_item = TRUE
	entries = list(
		// -- R&D computers --
		list("path" = /obj/item/circuitboard/computer/rdconsole, "cost" = 400, "max_supply" = 3, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/computer/rdservercontrol, "cost" = 350, "max_supply" = 2, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/computer/aifixer, "cost" = 500, "max_supply" = 2, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/computer/robotics, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/mecha_control, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/mech_bay_power_console, "cost" = 250, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/research, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/xenobiology, "cost" = 300, "max_supply" = 2),
		// -- R&D machines --
		list("path" = /obj/item/circuitboard/machine/rdserver, "cost" = 500, "max_supply" = 3, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/machine/destructive_analyzer, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/protolathe, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/machine/circuit_imprinter, "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_RD),
		list("path" = /obj/item/circuitboard/machine/mechfab, "cost" = 900, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/cyborgrecharger, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/mech_recharger, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/monkey_recycler, "cost" = 250, "max_supply" = 3),
		// -- Nanite machines --
		list("path" = /obj/item/circuitboard/machine/nanite_chamber, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/nanite_programmer, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/nanite_program_hub, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/public_nanite_chamber, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/computer/nanite_chamber_control, "cost" = 350, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/nanite_cloud_controller, "cost" = 400, "max_supply" = 2),
	)

// =============================================================================
// SECURITY BOARDS
// =============================================================================

/datum/cargo_list/boards_security
	access_budget = ACCESS_SECURITY
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/circuitboard/computer/security, "cost" = 250, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/records/security, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/prisoner, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/warrant, "cost" = 250, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/recharger, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/photobooth/security, "cost" = 150, "max_supply" = 2),
	)

// =============================================================================
// SERVICE BOARDS  (Bar, Kitchen, Hydroponics, Janitorial, Library)
// =============================================================================

/datum/cargo_list/boards_service
	small_item = TRUE
	entries = list(
		// -- Bar / kitchen --
		list("path" = /obj/item/circuitboard/machine/microwave, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/deep_fryer, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/griddle, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/oven, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/chem_dispenser/drinks, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/gibber, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/dish_drive, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/processor, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/recycler, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/fat_sucker, "cost" = 250, "max_supply" = 2),
		// -- Hydroponics --
		list("path" = /obj/item/circuitboard/machine/hydroponics, "cost" = 250, "max_supply" = 4, "access_budget" = ACCESS_HYDROPONICS),
		list("path" = /obj/item/circuitboard/machine/seed_extractor, "cost" = 200, "max_supply" = 3, "access_budget" = ACCESS_HYDROPONICS),
		list("path" = /obj/item/circuitboard/machine/biogenerator, "cost" = 400, "max_supply" = 2, "access_budget" = ACCESS_HYDROPONICS),
		list("path" = /obj/item/circuitboard/machine/plantgenes, "cost" = 500, "max_supply" = 2, "access_budget" = ACCESS_HYDROPONICS),
		list("path" = /obj/item/circuitboard/machine/chem_dispenser/botany, "cost" = 300, "max_supply" = 2, "access_budget" = ACCESS_HYDROPONICS),
		// -- Misc service --
		list("path" = /obj/item/circuitboard/computer/libraryconsole, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/photobooth, "cost" = 150, "max_supply" = 2),
	)

// =============================================================================
// SUPPLY / CARGO BOARDS
// =============================================================================

/datum/cargo_list/boards_supply
	access_budget = ACCESS_CARGO
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/circuitboard/computer/cargo, "cost" = 250, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/cargo/request, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/computer/objective, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/bounty, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/mining, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/ore_redemption, "cost" = 350, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/machine/ore_silo, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/stacking_machine, "cost" = 350, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/stacking_unit_console, "cost" = 250, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/processing_unit, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/processing_unit_console, "cost" = 200, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/mining_equipment_vendor, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/exploration_equipment_vendor, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/sheetifier, "cost" = 300, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/mass_driver, "cost" = 400, "max_supply" = 2),
	)

// =============================================================================
// GENERAL-PURPOSE / MISC BOARDS
// =============================================================================

/datum/cargo_list/boards_misc
	small_item = TRUE
	entries = list(
		// -- Vendors & dispensers --
		list("path" = /obj/item/circuitboard/machine/vendor, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/vending/donksofttoyvendor, "cost" = 200, "max_supply" = 2),
		// -- Fabrication --
		list("path" = /obj/item/circuitboard/machine/autolathe, "cost" = 400, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/techfab, "cost" = 500, "max_supply" = 2),
		list("path" = /obj/item/circuitboard/machine/paystand, "cost" = 150, "max_supply" = 4),
		// -- Communications --
		list("path" = /obj/item/circuitboard/machine/fax, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/circuitboard/machine/holopad, "cost" = 150, "max_supply" = 6),
		// -- Smartfridges --
		list("path" = /obj/item/circuitboard/machine/smartfridge, "cost" = 200, "max_supply" = 4),
		// -- Arcade boards --
		list("path" = /obj/item/circuitboard/computer/arcade/battle, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/arcade/orion_trail, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/arcade/amputation, "cost" = 300, "max_supply" = 3),
		list("path" = /obj/item/circuitboard/computer/slot_machine, "cost" = 250, "max_supply" = 3),
		// -- Shuttle boards (non-researched standard) --
		list("path" = /obj/item/circuitboard/machine/shuttle/engine, "cost" = 400, "max_supply" = 3, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/circuitboard/machine/shuttle/heater, "cost" = 300, "max_supply" = 3, "access_budget" = ACCESS_ENGINE),
	)
