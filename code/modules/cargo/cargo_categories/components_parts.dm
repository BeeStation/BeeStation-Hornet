/**
 * # Components & Parts Cargo Items
 *
 * Electronic components, stock parts, circuit boards, and science assemblies.
 * Split into Assemblies, Electronics, Stock Parts, Subspace Parts, Power Cells, and Science Packs.
 */

// =============================================================================
// ASSEMBLIES
// =============================================================================

/datum/cargo_list/components_assemblies
	access_budget = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/assembly/prox_sensor, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/assembly/igniter, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/assembly/timer, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/assembly/signaler, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/assembly/voice, "cost" = 35, "max_supply" = 8),
		list("path" = /obj/item/assembly/infra, "cost" = 35, "max_supply" = 8),
		list("path" = /obj/item/assembly/health, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/assembly/flash, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/assembly/mousetrap, "cost" = 5, "max_supply" = 12),
	)

// =============================================================================
// ELECTRONICS
// =============================================================================

/datum/cargo_list/components_electronics
	access_budget = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/inducer/sci/with_cell, "cost" = 400, "max_supply" = 3),
		list("path" = /obj/item/storage/part_replacer/cargo, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/item/mod/core/standard, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/monkey_sentience_helmet, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/item/disk/tech_disk/research/random, "cost" = 800, "max_supply" = 3),
	)

// =============================================================================
// STOCK PARTS (Tier 1)
// =============================================================================

/datum/cargo_list/components_stock
	crate_type = /obj/structure/closet/crate/science
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/stock_parts/capacitor, "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stock_parts/scanning_module, "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stock_parts/manipulator, "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stock_parts/micro_laser, "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stock_parts/matter_bin, "cost" = 20, "max_supply" = 15),
	)

// =============================================================================
// SUBSPACE STOCK PARTS (Telecomms)
// =============================================================================

/datum/cargo_list/components_subspace
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/engineering
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/stock_parts/subspace/ansible, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/filter, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/amplifier, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/treatment, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/analyzer, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/crystal, "cost" = 60, "max_supply" = 6),
		list("path" = /obj/item/stock_parts/subspace/transmitter, "cost" = 60, "max_supply" = 6),
	)

// =============================================================================
// POWER CELLS
// =============================================================================

/datum/cargo_list/components_cells
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/engineering/electrical
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/stock_parts/cell, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/stock_parts/cell/high, "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/fuel_rod, "cost" = 125, "max_supply" = 8),
	)

// =============================================================================
// SCIENCE PACKS (Crates)
// =============================================================================

/datum/cargo_crate/components_packs
	access_budget = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science

/datum/cargo_crate/components_packs/plasma
	name = "Plasma Assembly Crate"
	cost = 1200
	max_supply = 2
	access = ACCESS_TOX_STORAGE
	access_budget = ACCESS_TOX_STORAGE
	contains = list(
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/assembly/igniter,
		/obj/item/assembly/igniter,
		/obj/item/assembly/igniter,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/timer,
		/obj/item/assembly/timer,
		/obj/item/assembly/timer,
	)
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/cargo_crate/components_packs/robotics
	name = "Robotics Assembly Crate"
	cost = 800
	max_supply = 2
	access_budget = ACCESS_ROBOTICS
	contains = list(
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/storage/firstaid,
		/obj/item/storage/firstaid,
		/obj/item/healthanalyzer,
		/obj/item/healthanalyzer,
		/obj/item/clothing/head/utility/hardhat/red,
		/obj/item/clothing/head/utility/hardhat/red,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/bot_assembly/cleanbot,
		/obj/item/bot_assembly/cleanbot,
	)
	crate_type = /obj/structure/closet/crate/science

/datum/cargo_crate/components_packs/recharging
	name = "Cyborg Recharger Kit"
	cost = 500
	max_supply = 2
	access_budget = ACCESS_ROBOTICS
	contains = list(
		/obj/item/stack/sheet/iron/five,
		/obj/item/stack/cable_coil/random/five,
		/obj/item/circuitboard/machine/cyborgrecharger,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts/manipulator,
	)
	crate_type = /obj/structure/closet/crate/science

/datum/cargo_crate/components_packs/stock_parts_bulk
	name = "Stock Parts Bulk Crate"
	cost = 400
	max_supply = 3
	contains = list(
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/matter_bin,
	)

/datum/cargo_crate/components_packs/shieldwalls
	name = "Shield Wall Generator Crate"
	cost = 2500
	max_supply = 1
	access = ACCESS_RESEARCH
	contains = list(
		/obj/machinery/power/shieldwallgen,
		/obj/machinery/power/shieldwallgen,
		/obj/machinery/power/shieldwallgen,
		/obj/machinery/power/shieldwallgen,
	)
	crate_type = /obj/structure/closet/crate/secure/science

/datum/cargo_crate/components_packs/transfer_valves
	name = "Tank Transfer Valves"
	cost = 2500
	max_supply = 1
	access = ACCESS_RD
	access_budget = ACCESS_RD
	dangerous = TRUE
	contains = list(
		/obj/item/transfer_valve,
		/obj/item/transfer_valve,
	)
	crate_type = /obj/structure/closet/crate/secure/science

/datum/cargo_crate/components_packs/xenobio
	name = "Xenobiology Startup Kit"
	cost = 1800
	max_supply = 1
	access = ACCESS_XENOBIOLOGY
	access_budget = ACCESS_XENOBIOLOGY
	contains = list(
		/obj/item/slime_extract/grey,
		/obj/item/slime_extract/grey,
		/obj/item/reagent_containers/syringe/plasma,
		/obj/item/circuitboard/computer/xenobiology,
		/obj/item/circuitboard/machine/monkey_recycler,
		/obj/item/circuitboard/machine/processor/slime,
	)
	crate_type = /obj/structure/closet/crate/secure/science

/datum/cargo_crate/components_packs/telecomms_repair
	name = "Telecommunications Repair Crate"
	cost = 1500
	max_supply = 2
	access = ACCESS_ENGINE
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/secure/engineering
	contains = list(
		/obj/item/stock_parts/subspace/ansible,
		/obj/item/stock_parts/subspace/ansible,
		/obj/item/stock_parts/subspace/filter,
		/obj/item/stock_parts/subspace/filter,
		/obj/item/stock_parts/subspace/amplifier,
		/obj/item/stock_parts/subspace/amplifier,
		/obj/item/stock_parts/subspace/treatment,
		/obj/item/stock_parts/subspace/treatment,
		/obj/item/stock_parts/subspace/analyzer,
		/obj/item/stock_parts/subspace/crystal,
		/obj/item/stock_parts/subspace/transmitter,
	)

/datum/cargo_crate/components_packs/fuel_rods
	name = "Fuel Rod Crate"
	cost = 750
	max_supply = 3
	access = ACCESS_ENGINE
	crate_type = /obj/structure/closet/crate/secure/engineering
	contains = list(
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
	)
