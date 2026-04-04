/**
 * # Materials Cargo Items
 *
 * Bulk materials, sheet metals, gas canisters, and raw resources.
 * Split into Sheets, Glass, Floor Tiles, Canisters, and Dispensers.
 */

// =============================================================================
// METAL SHEETS
// =============================================================================

/datum/cargo_list/materials_sheets
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Common metals --
		list("path" = /obj/item/stack/sheet/iron/fifty, "name" = "Iron Sheets (50)", "cost" = 500, "max_supply" = 10),
		list("path" = /obj/item/stack/sheet/mineral/copper/fifty, "name" = "Copper Sheets (50)", "cost" = 900, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/titanium/fifty, "name" = "Titanium Sheets (50)", "cost" = 5000, "max_supply" = 3),
		// -- Precious / Exotic metals --
		list("path" = /obj/item/stack/sheet/mineral/silver/fifty, "name" = "Silver Sheets (50)", "cost" = 4000, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/gold/fifty, "name" = "Gold Sheets (50)", "cost" = 5000, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/diamond/fifty, "name" = "Diamond Sheets (50)", "cost" = 10000, "max_supply" = 2),
		list("path" = /obj/item/stack/sheet/mineral/uranium/fifty, "name" = "Uranium Sheets (50)", "cost" = 5000, "max_supply" = 3),
		// -- Organic / Misc sheets --
		list("path" = /obj/item/stack/sheet/wood/fifty, "name" = "Wood Planks (50)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/bamboo/fifty, "name" = "Bamboo Cuttings (50)", "cost" = 400, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/cardboard/fifty, "name" = "Cardboard Sheets (50)", "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/plastic/fifty, "name" = "Plastic Sheets (50)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/mineral/sandstone/fifty, "name" = "Sandstone Blocks (50)", "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/leather, "name" = "Leather Sheet", "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/stack/sheet/cotton/cloth, "name" = "Cloth Roll", "cost" = 80, "max_supply" = 6),
	)

// =============================================================================
// ORES
// =============================================================================

/datum/cargo_list/materials_ores
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Common ores --
		list("path" = /obj/item/stack/ore/iron, "name" = "Iron Ore", "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/glass, "name" = "Sand", "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/glass/basalt, "name" = "Volcanic Ash", "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/copper, "name" = "Copper Ore", "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/titanium, "name" = "Titanium Ore", "cost" = 300, "max_supply" = 5),
		// -- Precious ores --
		list("path" = /obj/item/stack/ore/silver, "name" = "Silver Ore", "cost" = 200, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/gold, "name" = "Gold Ore", "cost" = 250, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/diamond, "name" = "Diamond Ore", "cost" = 500, "max_supply" = 3),
		// -- Hazardous / Exotic ores --
		list("path" = /obj/item/stack/ore/uranium, "name" = "Uranium Ore", "cost" = 300, "max_supply" = 5),
	)

// =============================================================================
// GLASS SHEETS
// =============================================================================

/datum/cargo_list/materials_glass
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		list("path" = /obj/item/stack/sheet/glass/fifty, "name" = "Glass Sheets (50)", "cost" = 500, "max_supply" = 10),
		list("path" = /obj/item/stack/sheet/rglass, "name" = "Reinforced Glass Sheet", "cost" = 50, "max_supply" = 8),
	)

// =============================================================================
// FLOOR TILES
// =============================================================================

/datum/cargo_list/materials_tiles
	entries = list(
		// -- Carpet tiles --
		list("path" = /obj/item/stack/tile/carpet/fifty, "name" = "Standard Carpet Tiles (50)", "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/carpet/black/fifty, "name" = "Black Carpet Tiles (50)", "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/carpet/blue/fifty, "name" = "Blue Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/cyan/fifty, "name" = "Cyan Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/green/fifty, "name" = "Green Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/orange/fifty, "name" = "Orange Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/purple/fifty, "name" = "Purple Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/red/fifty, "name" = "Red Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/olive/fifty, "name" = "Olive Carpet Tiles (50)", "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/royalblack/fifty, "name" = "Royal Black Carpet Tiles (50)", "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/royalblue/fifty, "name" = "Royal Blue Carpet Tiles (50)", "cost" = 300, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/grimy/fifty, "name" = "Grimy Carpet Tiles (50)", "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/eighties/fifty, "name" = "Retro Tiles (50)", "cost" = 200, "max_supply" = 4),
		// -- Specialty floor tiles --
		list("path" = /obj/item/stack/tile/grass, "name" = "Grass Tile", "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/wood, "name" = "Wood Floor Tile", "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/stack/tile/bamboo, "name" = "Bamboo Mat Piece", "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/fakespace, "name" = "Astral Carpet Tile", "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/noslip/thirty, "name" = "High-Traction Floor Tiles (30)", "cost" = 400, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		// -- Structural floor tiles --
		list("path" = /obj/item/stack/tile/catwalk_tile/sixty, "name" = "Catwalk Floor Tiles (60)", "cost" = 400, "max_supply" = 4, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/tile/glass/sixty, "name" = "Glass Floor Tiles (60)", "cost" = 500, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/tile/rglass/sixty, "name" = "Reinforced Glass Floor Tiles (60)", "cost" = 700, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
	)

// =============================================================================
// GAS CANISTERS
// =============================================================================

// Safe canisters - no access restrictions, available as list entries
/datum/cargo_list/materials_canisters
	access_budget = ACCESS_ATMOSPHERICS
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		list("path" = /obj/machinery/portable_atmospherics/canister/oxygen, "name" = "Oxygen Canister", "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/machinery/portable_atmospherics/canister/nitrogen, "name" = "Nitrogen Canister", "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/machinery/portable_atmospherics/canister/air, "name" = "Air Canister", "cost" = 1500, "max_supply" = 3),
		list("path" = /obj/machinery/portable_atmospherics/canister/water_vapor, "name" = "Water Vapor Canister", "cost" = 1500, "max_supply" = 2),
	)

// Dangerous / restricted canisters - access-locked crates
/datum/cargo_crate/materials_canisters
	access_budget = ACCESS_ATMOSPHERICS

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

// =============================================================================
// DISPENSERS
// =============================================================================

/datum/cargo_list/materials_dispensers
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		list("path" = /obj/structure/reagent_dispensers/foamtank, "name" = "Firefighting Foam Tank", "cost" = 1000, "max_supply" = 2),
		list("path" = /obj/structure/reagent_dispensers/fueltank, "name" = "Welding Fuel Tank", "cost" = 800, "max_supply" = 3),
		list("path" = /obj/structure/reagent_dispensers/watertank, "name" = "Water Tank", "cost" = 600, "max_supply" = 3),
		list("path" = /obj/structure/reagent_dispensers/watertank/high, "name" = "High-Capacity Water Tank", "cost" = 1200, "max_supply" = 2),
		list("path" = /obj/structure/reagent_dispensers/peppertank, "name" = "Pepper Spray Refiller", "cost" = 1000, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
	)
