/**
 * # Materials Cargo Items
 *
 * Bulk materials, sheet metals, gas canisters, and raw resources.
 * Split into Sheets, Bulk Packs, Canisters, and Dispensers.
 */

// =============================================================================
// SHEETS (Individual)
// =============================================================================

/datum/cargo_list/materials_sheets
	entries = list(
		list("path" = /obj/item/stack/sheet/iron/fifty, "name" = "Iron Sheets (50)", "cost" = 500, "max_supply" = 10, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/glass/fifty, "name" = "Glass Sheets (50)", "cost" = 500, "max_supply" = 10, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/plasteel/twenty, "name" = "Plasteel Sheets (20)", "cost" = 1500, "max_supply" = 5, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/plasteel/fifty, "name" = "Plasteel Sheets (50)", "cost" = 3500, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/wood/fifty, "name" = "Wood Planks (50)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/cardboard/fifty, "name" = "Cardboard Sheets (50)", "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/mineral/copper/twenty, "name" = "Copper Sheets (20)", "cost" = 400, "max_supply" = 5, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/mineral/copper/fifty, "name" = "Copper Sheets (50)", "cost" = 900, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/sheet/plastic/fifty, "name" = "Plastic Sheets (50)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/mineral/sandstone/fifty, "name" = "Sandstone Blocks (50)", "cost" = 200, "max_supply" = 8),
	)

// =============================================================================
// FLOOR TILES
// =============================================================================

/datum/cargo_list/materials_tiles
	entries = list(
		list("path" = /obj/item/stack/tile/carpet/fifty, "name" = "Standard Carpet Tiles (50)", "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/carpet/black/fifty, "name" = "Black Carpet Tiles (50)", "cost" = 200, "max_supply" = 6),
	)

/datum/cargo_crate/materials_tiles

/datum/cargo_crate/materials_tiles/carpet_exotic
	name = "Exotic Carpet Crate"
	cost = 2000
	max_supply = 2
	contains = list(
		/obj/item/stack/tile/carpet/blue/fifty,
		/obj/item/stack/tile/carpet/blue/fifty,
		/obj/item/stack/tile/carpet/cyan/fifty,
		/obj/item/stack/tile/carpet/cyan/fifty,
		/obj/item/stack/tile/carpet/green/fifty,
		/obj/item/stack/tile/carpet/green/fifty,
		/obj/item/stack/tile/carpet/orange/fifty,
		/obj/item/stack/tile/carpet/orange/fifty,
		/obj/item/stack/tile/carpet/purple/fifty,
		/obj/item/stack/tile/carpet/purple/fifty,
		/obj/item/stack/tile/carpet/red/fifty,
		/obj/item/stack/tile/carpet/red/fifty,
		/obj/item/stack/tile/carpet/olive/fifty,
		/obj/item/stack/tile/carpet/olive/fifty,
		/obj/item/stack/tile/carpet/royalblue/fifty,
		/obj/item/stack/tile/carpet/royalblue/fifty,
		/obj/item/stack/tile/eighties/fifty,
		/obj/item/stack/tile/eighties/fifty,
		/obj/item/stack/tile/carpet/royalblack/fifty,
		/obj/item/stack/tile/carpet/royalblack/fifty,
	)

// =============================================================================
// BULK MATERIAL PACKS
// =============================================================================

/datum/cargo_crate/materials_bulk

/datum/cargo_crate/materials_bulk/iron250
	name = "Bulk Iron Crate (250)"
	cost = 2000
	max_supply = 4
	contains = list(
		/obj/item/stack/sheet/iron/fifty,
		/obj/item/stack/sheet/iron/fifty,
		/obj/item/stack/sheet/iron/fifty,
		/obj/item/stack/sheet/iron/fifty,
		/obj/item/stack/sheet/iron/fifty,
	)

/datum/cargo_crate/materials_bulk/glass250
	name = "Bulk Glass Crate (250)"
	cost = 2000
	max_supply = 4
	contains = list(
		/obj/item/stack/sheet/glass/fifty,
		/obj/item/stack/sheet/glass/fifty,
		/obj/item/stack/sheet/glass/fifty,
		/obj/item/stack/sheet/glass/fifty,
		/obj/item/stack/sheet/glass/fifty,
	)

// =============================================================================
// GAS CANISTERS
// =============================================================================

/datum/cargo_crate/materials_canisters
	access_budget = ACCESS_ATMOSPHERICS

/datum/cargo_crate/materials_canisters/oxygen
	name = "Oxygen Canister"
	cost = 1500
	max_supply = 3
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_crate/materials_canisters/nitrogen
	name = "Nitrogen Canister"
	cost = 1500
	max_supply = 3
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_crate/materials_canisters/carbon_dioxide
	name = "Carbon Dioxide Canister"
	cost = 2000
	max_supply = 2
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/materials_canisters/nitrous_oxide
	name = "Nitrous Oxide Canister"
	cost = 2500
	max_supply = 2
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrous_oxide)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/materials_canisters/bz
	name = "BZ Canister"
	cost = 5000
	max_supply = 1
	access = ACCESS_ATMOSPHERICS
	dangerous = TRUE
	contains = list(/obj/machinery/portable_atmospherics/canister/bz)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/materials_canisters/water_vapor
	name = "Water Vapor Canister"
	cost = 1500
	max_supply = 2
	contains = list(/obj/machinery/portable_atmospherics/canister/water_vapor)
	crate_type = /obj/structure/closet/crate/large

// =============================================================================
// DISPENSERS
// =============================================================================

/datum/cargo_list/materials_dispensers
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		list("path" = /obj/structure/reagent_dispensers/foamtank, "cost" = 1000, "max_supply" = 2),
		list("path" = /obj/structure/reagent_dispensers/fueltank, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/structure/reagent_dispensers/watertank, "cost" = 600, "max_supply" = 3),
		list("path" = /obj/structure/reagent_dispensers/watertank/high, "cost" = 1200, "max_supply" = 2),
	)
