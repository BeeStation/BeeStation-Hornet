/**
 * # Components & Parts Cargo Items
 *
 * Electronic components, stock parts, circuit boards, and science assemblies.
 * Split into Electronics, Stock Parts, and Science Packs.
 */

// =============================================================================
// ELECTRONICS
// =============================================================================

/datum/cargo_list/components_electronics
	access_budget = ACCESS_RESEARCH
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/assembly/prox_sensor, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/assembly/igniter, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/assembly/timer, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/inducer/sci/with_cell, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/item/storage/part_replacer/cargo, "cost" = 1500, "max_supply" = 2),
		list("path" = /obj/item/mod/core/standard, "cost" = 1000, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/helmet/monkey_sentience_helmet, "cost" = 1000, "max_supply" = 4),
		list("path" = /obj/item/disk/tech_disk/research/random, "cost" = 2000, "max_supply" = 3),
	)

// =============================================================================
// STOCK PARTS
// =============================================================================

/datum/cargo_list/components_stock
	access_budget = ACCESS_ENGINE_EQUIP
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/stock_parts/cell/high, "cost" = 400, "max_supply" = 5),
		list("path" = /obj/item/fuel_rod, "cost" = 350, "max_supply" = 8),
	)

// =============================================================================
// SCIENCE PACKS (Crates)
// =============================================================================

/datum/cargo_crate/components_packs
	access_budget = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science

/datum/cargo_crate/components_packs/plasma
	name = "Plasma Assembly Crate"
	cost = 2500
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
	cost = 2500
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
	crate_type = /obj/structure/closet/crate/secure/science

/datum/cargo_crate/components_packs/recharging
	name = "Cyborg Recharger Kit"
	cost = 1500
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
	crate_type = /obj/structure/closet/crate/secure/science

/datum/cargo_crate/components_packs/shieldwalls
	name = "Shield Wall Generator Crate"
	cost = 4000
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
	cost = 4000
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
	cost = 4000
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

/datum/cargo_crate/components_packs/fuel_rods
	name = "Fuel Rod Crate"
	cost = 2000
	max_supply = 3
	access = ACCESS_ENGINE
	contains = list(
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
		/obj/item/fuel_rod,
	)
	crate_type = /obj/structure/closet/crate/secure/engineering
