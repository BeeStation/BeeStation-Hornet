/**
 * # Machinery Cargo Items
 *
 * Large machinery, generators, vehicles, atmospheric machinery, engine construction kits, and mechs.
 * Circuit boards are handled in boards.dm.
 * Split into Generators & Power, Atmospheric Machinery, Vehicles, Engine Construction, and Mech & Robotics.
 */

// =============================================================================
// GENERATORS & POWER
// =============================================================================

/datum/cargo_list/machines_power
	access_budget = ACCESS_ENGINE_EQUIP
	entries = list(
		// -- Portable generators --
		list("path" = /obj/machinery/power/port_gen/pacman, "cost" = 2000, "max_supply" = 2, "crate_type" = /obj/structure/closet/crate/engineering/electrical),
		list("path" = /obj/machinery/shieldgen, "cost" = 1500, "max_supply" = 4),
		// -- Large stationary power machines --
		list("path" = /obj/machinery/power/smes, "cost" = 2500, "max_supply" = 4),
		list("path" = /obj/machinery/power/rtg, "cost" = 3000, "max_supply" = 2, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/machinery/power/floodlight, "cost" = 400, "max_supply" = 4, "crate_type" = /obj/structure/closet/crate/engineering/electrical),
		// -- Power cells & charging --
		list("path" = /obj/machinery/recharger, "cost" = 300, "max_supply" = 4),
		// -- Substations & APCs --
		list("path" = /obj/item/stock_parts/cell/upgraded, "cost" = 450, "max_supply" = 4, "small_item" = TRUE),
	)

// =============================================================================
// ATMOSPHERIC MACHINERY
// =============================================================================

/datum/cargo_list/machines_atmos
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		// -- Portable atmospheric machines --
		list("path" = /obj/machinery/portable_atmospherics/pump, "cost" = 1000, "max_supply" = 4),
		list("path" = /obj/machinery/portable_atmospherics/scrubber, "cost" = 1000, "max_supply" = 4),
		list("path" = /obj/machinery/portable_thermomachine, "cost" = 800, "max_supply" = 4),
		// -- Gas canisters (non-hazardous) --
		list("path" = /obj/machinery/portable_atmospherics/canister/air, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/machinery/portable_atmospherics/canister/oxygen, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/machinery/portable_atmospherics/canister/nitrogen, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide, "cost" = 350, "max_supply" = 4),
		list("path" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide, "cost" = 600, "max_supply" = 2),
		list("path" = /obj/machinery/portable_atmospherics/canister/water_vapor, "cost" = 400, "max_supply" = 3),
		// -- Plasma & tritium canisters (hazardous, access-gated) --
		list("path" = /obj/machinery/portable_atmospherics/canister/plasma, "cost" = 2500, "max_supply" = 2, "access_budget" = ACCESS_ENGINE, "crate_type" = /obj/structure/closet/crate/secure/engineering),
		list("path" = /obj/machinery/portable_atmospherics/canister/tritium, "cost" = 3000, "max_supply" = 1, "access_budget" = ACCESS_ENGINE, "crate_type" = /obj/structure/closet/crate/secure/engineering),
		// -- Gas miners --
		list("path" = /obj/machinery/atmospherics/miner/oxygen, "cost" = 1500, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/machinery/atmospherics/miner/nitrogen, "cost" = 1500, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/machinery/atmospherics/miner/n2o, "cost" = 2000, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/machinery/atmospherics/miner/carbon_dioxide, "cost" = 1500, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
	)

// =============================================================================
// VEHICLES
// =============================================================================

/datum/cargo_list/machines_vehicles
	entries = list(
		// -- On-station vehicles --
		list("path" = /obj/vehicle/ridden/lawnmower, "cost" = 800, "max_supply" = 2),
		list("path" = /obj/vehicle/ridden/bicycle, "cost" = 1000, "max_supply" = 2, "crate_type" = /obj/structure/closet/crate/large),
		list("path" = /mob/living/simple_animal/bot/mulebot, "cost" = 2000, "max_supply" = 2, "crate_type" = /obj/structure/closet/crate/large),
		list("path" = /mob/living/simple_animal/bot/cleanbot, "cost" = 1200, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/bot/medbot, "cost" = 1500, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/bot/secbot, "cost" = 1500, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /mob/living/simple_animal/bot/firebot, "cost" = 1000, "max_supply" = 2),
		list("path" = /obj/vehicle/ridden/secway, "cost" = 1200, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
		list("path" = /obj/vehicle/ridden/scooter, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/vehicle/ridden/wheelchair, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/vehicle/ridden/wheelchair/motorized, "cost" = 600, "max_supply" = 2),
	)

/datum/cargo_crate/machines_vehicles

/datum/cargo_crate/machines_vehicles/atv
	name = "ATV Crate"
	cost = 2400
	max_supply = 2
	contains = list(
		/obj/vehicle/ridden/atv,
		/obj/item/key/atv,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/head/soft/cargo,
		/obj/item/clothing/mask/bandana/skull/black,
	)
	crate_type = /obj/structure/closet/crate/large

// =============================================================================
// ENGINE CONSTRUCTION
// =============================================================================

/datum/cargo_list/machines_engine
	access_budget = ACCESS_ENGINE
	entries = list(
		// -- Emitters & containment --
		list("path" = /obj/machinery/power/emitter, "cost" = 1500, "max_supply" = 4, "crate_type" = /obj/structure/closet/crate/secure/engineering),
		list("path" = /obj/machinery/field/generator, "cost" = 1500, "max_supply" = 4),
		list("path" = /obj/machinery/power/energy_accumulator/grounding_rod, "cost" = 600, "max_supply" = 8, "crate_type" = /obj/structure/closet/crate/engineering/electrical),
		list("path" = /obj/machinery/power/energy_accumulator/tesla_coil, "cost" = 750, "max_supply" = 8, "crate_type" = /obj/structure/closet/crate/engineering/electrical),
		// -- Solar assemblies --
		list("path" = /obj/item/solar_assembly, "cost" = 100, "max_supply" = 30, "small_item" = TRUE, "crate_type" = /obj/structure/closet/crate/engineering/electrical),
		list("path" = /obj/item/electronics/tracker, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		// -- Individual engine machines (not kit-dependent) --
		list("path" = /obj/machinery/the_singularitygen, "cost" = 5000, "max_supply" = 1, "crate_type" = /obj/structure/closet/crate/secure/engineering),
		list("path" = /obj/machinery/the_singularitygen/tesla, "cost" = 5000, "max_supply" = 1, "crate_type" = /obj/structure/closet/crate/secure/engineering),
	)

/datum/cargo_crate/machines_engine
	access_budget = ACCESS_ENGINE
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_crate/machines_engine/particle_accelerator
	name = "Particle Accelerator Crate"
	cost = 5000
	max_supply = 1
	access = ACCESS_ENGINE
	contains = list(
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/machinery/particle_accelerator/control_box,
		/obj/structure/particle_accelerator/particle_emitter/center,
		/obj/structure/particle_accelerator/particle_emitter/left,
		/obj/structure/particle_accelerator/particle_emitter/right,
		/obj/structure/particle_accelerator/power_box,
		/obj/structure/particle_accelerator/end_cap,
	)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/nuclear_reactor
	name = "Nuclear Reactor Crate"
	cost = 8000
	max_supply = 1
	access = ACCESS_ENGINE
	contains = list(
		/obj/item/RBMK_box/core,
		/obj/item/RBMK_box/body/coolant_input,
		/obj/item/RBMK_box/body/moderator_input,
		/obj/item/RBMK_box/body/waste_output,
		/obj/item/RBMK_box/body,
		/obj/item/RBMK_box/body,
		/obj/item/RBMK_box/body,
		/obj/item/RBMK_box/body,
		/obj/item/RBMK_box/body,
		/obj/item/circuitboard/computer/control_rods,
		/obj/item/book/manual/wiki/rbmk,
	)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/thermo_electric_generator
	name = "Thermoelectric Generator Crate"
	cost = 6000
	max_supply = 1
	access = ACCESS_ENGINE
	contains = list(
		/obj/machinery/power/generator,
		/obj/machinery/atmospherics/components/binary/circulator,
		/obj/machinery/atmospherics/components/binary/circulator,
	)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/supermatter_shard
	name = "Supermatter Shard Crate"
	cost = 10000
	max_supply = 1
	access = ACCESS_CE
	access_budget = ACCESS_CE
	dangerous = TRUE
	contains = list(/obj/machinery/power/supermatter_crystal/shard)
	crate_type = /obj/structure/closet/crate/secure/engineering

// =============================================================================
// MECH & ROBOTICS
// =============================================================================

/datum/cargo_list/machines_mech
	access_budget = ACCESS_ENGINE_EQUIP
	entries = list(
		// -- Exosuit tools & equipment --
		list("path" = /obj/item/mecha_parts/mecha_equipment/drill, "cost" = 500, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp, "cost" = 500, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/extinguisher, "cost" = 400, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/mining_scanner, "cost" = 300, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/rcd, "cost" = 2500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/repair_droid, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/thrusters/ion, "cost" = 1000, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/air_tank, "cost" = 300, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/generator, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/radio, "cost" = 200, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mecha_parts/mecha_equipment/ripleyupgrade, "cost" = 2000, "max_supply" = 2, "small_item" = TRUE),
		// -- Conveyor system --
		list("path" = /obj/item/stack/conveyor/thirty, "cost" = 300, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/conveyor_switch_construct, "cost" = 50, "max_supply" = 8, "small_item" = TRUE),
		// -- MODsuit pre-equipped units --
		list("path" = /obj/item/mod/control/pre_equipped/standard, "cost" = 2000, "max_supply" = 4),
		list("path" = /obj/item/mod/control/pre_equipped/engineering, "cost" = 3500, "max_supply" = 2, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/mod/control/pre_equipped/atmospheric, "cost" = 3500, "max_supply" = 2, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/item/mod/control/pre_equipped/advanced, "cost" = 6000, "max_supply" = 1, "access_budget" = ACCESS_CE),
		// -- MODsuit modules (engineering) --
		list("path" = /obj/item/mod/module/welding, "cost" = 200, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/t_ray, "cost" = 300, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ATMOSPHERICS),
		list("path" = /obj/item/mod/module/magboot, "cost" = 400, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/tether, "cost" = 350, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/rad_protection, "cost" = 500, "max_supply" = 4, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		list("path" = /obj/item/mod/module/jetpack, "cost" = 1500, "max_supply" = 2, "small_item" = TRUE, "access_budget" = ACCESS_ENGINE),
		// -- MODsuit modules (general) --
		list("path" = /obj/item/mod/module/storage, "cost" = 300, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/flashlight, "cost" = 150, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/status_readout, "cost" = 200, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/thermal_regulator, "cost" = 400, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/longfall, "cost" = 300, "max_supply" = 4, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/emp_shield, "cost" = 600, "max_supply" = 2, "small_item" = TRUE),
		list("path" = /obj/item/mod/module/mouthhole, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
	)

/datum/cargo_crate/machines_mech
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_crate/machines_mech/ripley
	name = "Ripley APLU Parts Crate"
	cost = 5000
	max_supply = 1
	contains = list(
		/obj/item/mecha_parts/chassis/ripley,
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_leg,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/scanning_module,
		/obj/item/circuitboard/mecha/ripley/main,
		/obj/item/circuitboard/mecha/ripley/peripherals,
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
	)

/datum/cargo_crate/machines_mech/clarke
	name = "Clarke Parts Crate"
	cost = 8000
	max_supply = 1
	contains = list(
		/obj/item/mecha_parts/chassis/clarke,
		/obj/item/mecha_parts/part/clarke_torso,
		/obj/item/mecha_parts/part/clarke_right_arm,
		/obj/item/mecha_parts/part/clarke_left_arm,
		/obj/item/mecha_parts/part/clarke_head,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/scanning_module,
		/obj/item/circuitboard/mecha/clarke/main,
		/obj/item/circuitboard/mecha/clarke/peripherals,
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
	)

/datum/cargo_crate/machines_mech/shuttle_construction
	name = "Shuttle Construction Crate"
	cost = 15000
	max_supply = 1
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(
		/obj/machinery/portable_atmospherics/canister/plasma,
		/obj/item/construction/rcd/loaded,
		/obj/item/rcd_ammo/large,
		/obj/item/rcd_ammo/large,
		/obj/item/shuttle_creator,
		/obj/item/pipe_dispenser,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/electrical,
		/obj/item/circuitboard/computer/shuttle/flight_control,
		/obj/item/circuitboard/machine/shuttle/engine/plasma,
		/obj/item/circuitboard/machine/shuttle/engine/plasma,
		/obj/item/circuitboard/machine/shuttle/heater,
		/obj/item/circuitboard/machine/shuttle/heater,
		/obj/item/survivalcapsule/shuttle_husk,
	)
	crate_type = /obj/structure/closet/crate/large
