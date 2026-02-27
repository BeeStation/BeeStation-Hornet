/**
 * # Machines & Equipment Cargo Items
 *
 * Large machinery, generators, vehicles, atmospheric equipment, and engine construction kits.
 * Split into Generators & Power, Atmospheric Equipment, Vehicles, Engine Construction, and Mech & Robotics.
 */

// =============================================================================
// GENERATORS & POWER
// =============================================================================

/datum/cargo_item/machines_power
	category = "Machines & Equipment"
	subcategory = "Generators & Power"
	access_budget = ACCESS_ENGINE_EQUIP

/datum/cargo_item/machines_power/pacman
	name = "P.A.C.M.A.N. Generator"
	desc = "A portable generator that runs on plasma sheets."
	item_path = /obj/machinery/power/port_gen/pacman
	cost = 2000
	max_supply = 2
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/cargo_item/machines_power/shield_generator
	name = "Portable Shield Generator"
	item_path = /obj/machinery/shieldgen
	cost = 1500
	max_supply = 4

// =============================================================================
// ATMOSPHERIC EQUIPMENT
// =============================================================================

/datum/cargo_item/machines_atmos
	category = "Machines & Equipment"
	subcategory = "Atmospheric Equipment"
	access_budget = ACCESS_ENGINE_EQUIP

/datum/cargo_item/machines_atmos/portable_pump
	name = "Portable Air Pump"
	item_path = /obj/machinery/portable_atmospherics/pump
	cost = 1000
	max_supply = 4
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_item/machines_atmos/portable_scrubber
	name = "Portable Air Scrubber"
	item_path = /obj/machinery/portable_atmospherics/scrubber
	cost = 1000
	max_supply = 4
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_item/machines_atmos/jetpack
	name = "CO2 Jetpack"
	item_path = /obj/item/tank/jetpack/carbondioxide
	cost = 1500
	max_supply = 3

/datum/cargo_item/machines_atmos/jetpack_combustion
	name = "Combustion Jetpack"
	item_path = /obj/item/tank/jetpack/combustion
	cost = 2000
	max_supply = 2

// =============================================================================
// VEHICLES
// =============================================================================

/datum/cargo_item/machines_vehicles
	category = "Machines & Equipment"
	subcategory = "Vehicles"

/datum/cargo_item/machines_vehicles/lawnmower
	name = "Lawnmower"
	desc = "A riding lawnmower for keeping the station grounds tidy."
	item_path = /obj/vehicle/ridden/lawnmower
	cost = 800
	max_supply = 2

/datum/cargo_crate/machines_vehicles
	category = "Machines & Equipment"
	subcategory = "Vehicles"

/datum/cargo_crate/machines_vehicles/atv
	name = "ATV Crate"
	desc = "An all-terrain vehicle for rapid traversal, complete with biker gear."
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

/datum/cargo_crate/machines_vehicles/bicycle
	name = "Bicycle Crate"
	desc = "Contains one bicycle."
	cost = 1000
	max_supply = 2
	contains = list(/obj/vehicle/ridden/bicycle)
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_crate/machines_vehicles/bicycle/generate(atom/A, datum/bank_account/paying_account)

/datum/cargo_crate/machines_vehicles/mule
	name = "MULEbot Crate"
	desc = "Contains a MULEbot delivery robot."
	cost = 2000
	max_supply = 2
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_type = /obj/structure/closet/crate/large

// =============================================================================
// ENGINE CONSTRUCTION
// =============================================================================

/datum/cargo_crate/machines_engine
	category = "Machines & Equipment"
	subcategory = "Engine Construction"
	access_budget = ACCESS_ENGINE
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_crate/machines_engine/emitter
	name = "Emitter Crate"
	desc = "Contains two emitters for singularity engine construction."
	cost = 3000
	max_supply = 2
	access = ACCESS_ENGINE
	contains = list(
		/obj/machinery/power/emitter,
		/obj/machinery/power/emitter,
	)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/field_gen
	name = "Field Generator Crate"
	desc = "Contains two field generators."
	cost = 3000
	max_supply = 2
	contains = list(
		/obj/machinery/field/generator,
		/obj/machinery/field/generator,
	)

/datum/cargo_crate/machines_engine/grounding_rods
	name = "Grounding Rod Crate"
	desc = "Contains four grounding rods for tesla engine setups."
	cost = 2500
	max_supply = 2
	contains = list(
		/obj/machinery/power/energy_accumulator/grounding_rod,
		/obj/machinery/power/energy_accumulator/grounding_rod,
		/obj/machinery/power/energy_accumulator/grounding_rod,
		/obj/machinery/power/energy_accumulator/grounding_rod,
	)
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/cargo_crate/machines_engine/particle_accelerator
	name = "Particle Accelerator Crate"
	desc = "Contains all parts to construct a particle accelerator."
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
	desc = "Contains all parts and boards to construct an RBMK reactor."
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

/datum/cargo_crate/machines_engine/singularity_gen
	name = "Singularity Generator Crate"
	desc = "Contains a singularity generator."
	cost = 5000
	max_supply = 1
	access = ACCESS_ENGINE
	contains = list(/obj/machinery/the_singularitygen)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/solar
	name = "Solar Panel Crate"
	desc = "Contains 21 solar assemblies, a solar control board, a tracker, and instructions."
	cost = 3000
	max_supply = 3
	contains = list(
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/circuitboard/computer/solar_control,
		/obj/item/electronics/tracker,
		/obj/item/paper/guides/jobs/engi/solars,
	)
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/cargo_crate/machines_engine/supermatter_shard
	name = "Supermatter Shard Crate"
	desc = "Contains a supermatter crystal shard. Handle with extreme caution."
	cost = 10000
	max_supply = 1
	access = ACCESS_CE
	access_budget = ACCESS_CE
	dangerous = TRUE
	contains = list(/obj/machinery/power/supermatter_crystal/shard)
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/cargo_crate/machines_engine/tesla_coils
	name = "Tesla Coil Crate"
	desc = "Contains four tesla coils."
	cost = 3000
	max_supply = 2
	contains = list(
		/obj/machinery/power/energy_accumulator/tesla_coil,
		/obj/machinery/power/energy_accumulator/tesla_coil,
		/obj/machinery/power/energy_accumulator/tesla_coil,
		/obj/machinery/power/energy_accumulator/tesla_coil,
	)
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/cargo_crate/machines_engine/tesla_gen
	name = "Tesla Generator Crate"
	desc = "Contains a tesla generator."
	cost = 5000
	max_supply = 1
	access = ACCESS_ENGINE
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_type = /obj/structure/closet/crate/secure/engineering

// =============================================================================
// MECH & ROBOTICS
// =============================================================================

/datum/cargo_crate/machines_mech
	category = "Machines & Equipment"
	subcategory = "Mech & Robotics"
	access_budget = ACCESS_ENGINE_EQUIP
	crate_type = /obj/structure/closet/crate/engineering

/datum/cargo_crate/machines_mech/ripley
	name = "Ripley APLU Parts Crate"
	desc = "Contains all parts needed to construct a Ripley APLU mech."
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

/datum/cargo_crate/machines_mech/conveyor
	name = "Conveyor Belt Crate"
	desc = "Contains a stack of conveyor belts, a switch construct, and an instruction manual."
	cost = 1000
	max_supply = 3
	contains = list(
		/obj/item/stack/conveyor/thirty,
		/obj/item/conveyor_switch_construct,
		/obj/item/paper/guides/conveyor,
	)

/datum/cargo_crate/machines_mech/shuttle_construction
	name = "Shuttle Construction Crate"
	desc = "Contains everything needed to construct a custom shuttle."
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
