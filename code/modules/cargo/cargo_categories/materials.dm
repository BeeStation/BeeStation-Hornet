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
		// Iron: Abundant, basic construction material.
		// Export check: 50 plasteel = $210×50 = $10,500; iron cost ($500) + 50 plasma
		// worth $10,000 raw = $10,500 input. Alloying breaks even; selling raw plasma better.
		list("path" = /obj/item/stack/sheet/iron/ten, "name" = "Iron Sheets (10)", "cost" = 120, "max_supply" = 15),
		list("path" = /obj/item/stack/sheet/iron/twenty, "name" = "Iron Sheets (20)", "cost" = 220, "max_supply" = 10),
		list("path" = /obj/item/stack/sheet/iron/fifty, "name" = "Iron Sheets (50)", "cost" = 500, "max_supply" = 5),
		// Copper: Uncommon, used in electronics.
		list("path" = /obj/item/stack/sheet/mineral/copper/ten, "name" = "Copper Sheets (10)", "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/mineral/copper/twenty, "name" = "Copper Sheets (20)", "cost" = 360, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/mineral/copper/fifty, "name" = "Copper Sheets (50)", "cost" = 800, "max_supply" = 3),
		// Titanium: Rare, high-value alloy input.
		// Export check: 50 plastitanium = $350×50 = $17,500; titanium ($6,500) + 50 plasma
		// worth $10,000 raw = $16,500 input → $1,000 net. Modest; raw plasma still simpler.
		list("path" = /obj/item/stack/sheet/mineral/titanium/ten, "name" = "Titanium Sheets (10)", "cost" = 1500, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/mineral/titanium/twenty, "name" = "Titanium Sheets (20)", "cost" = 2800, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/titanium/fifty, "name" = "Titanium Sheets (50)", "cost" = 6500, "max_supply" = 2),
		// -- Precious / Exotic metals --
		// Silver: Precious, moderate rarity.
		list("path" = /obj/item/stack/sheet/mineral/silver/ten, "name" = "Silver Sheets (10)", "cost" = 1000, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/mineral/silver/twenty, "name" = "Silver Sheets (20)", "cost" = 1800, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/silver/fifty, "name" = "Silver Sheets (50)", "cost" = 4000, "max_supply" = 2),
		// Gold: Precious, high rarity.
		list("path" = /obj/item/stack/sheet/mineral/gold/ten, "name" = "Gold Sheets (10)", "cost" = 1200, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/mineral/gold/twenty, "name" = "Gold Sheets (20)", "cost" = 2200, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/gold/fifty, "name" = "Gold Sheets (50)", "cost" = 5000, "max_supply" = 2),
		// Diamond: Extremely rare, endgame material. Capital expenditure.
		list("path" = /obj/item/stack/sheet/mineral/diamond/ten, "name" = "Diamond Sheets (10)", "cost" = 3000, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/diamond/twenty, "name" = "Diamond Sheets (20)", "cost" = 5500, "max_supply" = 2),
		list("path" = /obj/item/stack/sheet/mineral/diamond/fifty, "name" = "Diamond Sheets (50)", "cost" = 12500, "max_supply" = 1),
		// Uranium: Hazardous exotic. Comparable to titanium tier.
		list("path" = /obj/item/stack/sheet/mineral/uranium/ten, "name" = "Uranium Sheets (10)", "cost" = 1300, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/mineral/uranium/twenty, "name" = "Uranium Sheets (20)", "cost" = 2400, "max_supply" = 3),
		list("path" = /obj/item/stack/sheet/mineral/uranium/fifty, "name" = "Uranium Sheets (50)", "cost" = 5500, "max_supply" = 2),
	)

// Organic, craft, and soft materials, plain crate, not engineering-specific
/datum/cargo_list/materials_sheets_misc
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Organic / Misc sheets --
		// Wood: Common organic.
		list("path" = /obj/item/stack/sheet/wood/ten, "name" = "Wood Planks (10)", "cost" = 75, "max_supply" = 12),
		list("path" = /obj/item/stack/sheet/wood/twenty, "name" = "Wood Planks (20)", "cost" = 140, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/wood/fifty, "name" = "Wood Planks (50)", "cost" = 300, "max_supply" = 4),
		// Bamboo: Same tier as wood.
		list("path" = /obj/item/stack/sheet/bamboo/ten, "name" = "Bamboo Cuttings (10)", "cost" = 75, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/bamboo/twenty, "name" = "Bamboo Cuttings (20)", "cost" = 140, "max_supply" = 5),
		list("path" = /obj/item/stack/sheet/bamboo/fifty, "name" = "Bamboo Cuttings (50)", "cost" = 300, "max_supply" = 3),
		// Cardboard: Dirt cheap.
		list("path" = /obj/item/stack/sheet/cardboard/ten, "name" = "Cardboard Sheets (10)", "cost" = 40, "max_supply" = 12),
		list("path" = /obj/item/stack/sheet/cardboard/twenty, "name" = "Cardboard Sheets (20)", "cost" = 70, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/cardboard/fifty, "name" = "Cardboard Sheets (50)", "cost" = 150, "max_supply" = 4),
		// Plastic: Slightly more useful than cardboard.
		list("path" = /obj/item/stack/sheet/plastic/ten, "name" = "Plastic Sheets (10)", "cost" = 85, "max_supply" = 12),
		list("path" = /obj/item/stack/sheet/plastic/twenty, "name" = "Plastic Sheets (20)", "cost" = 160, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/plastic/fifty, "name" = "Plastic Sheets (50)", "cost" = 350, "max_supply" = 4),
		// Sandstone: Same tier as cardboard.
		list("path" = /obj/item/stack/sheet/mineral/sandstone/ten, "name" = "Sandstone Blocks (10)", "cost" = 40, "max_supply" = 12),
		list("path" = /obj/item/stack/sheet/mineral/sandstone/twenty, "name" = "Sandstone Blocks (20)", "cost" = 70, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/mineral/sandstone/fifty, "name" = "Sandstone Blocks (50)", "cost" = 150, "max_supply" = 4),
		// Leather/Cloth: Single sheets only (no stack macro for leather), impulse buy.
		list("path" = /obj/item/stack/sheet/leather, "name" = "Leather Sheet", "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/stack/sheet/cotton/cloth/five, "name" = "Cloth Rolls (5)", "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/stack/sheet/cotton/cloth/ten, "name" = "Cloth Rolls (10)", "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/stack/sheet/cotton/cloth/twenty, "name" = "Cloth Rolls (20)", "cost" = 90, "max_supply" = 4),
	)

// =============================================================================
// ORES
// =============================================================================

/datum/cargo_list/materials_ores
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// -- Common ores --
		// Single ores are pocket change. Bulk (20) lets you skip a mining trip.
		// Iron ore:
		list("path" = /obj/item/stack/ore/iron/five, "name" = "Iron Ore (5)", "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stack/ore/iron/ten, "name" = "Iron Ore (10)", "cost" = 35, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/iron/twenty, "name" = "Iron Ore (20)", "cost" = 60, "max_supply" = 5),
		// Sand:
		list("path" = /obj/item/stack/ore/glass/five, "name" = "Sand (5)", "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stack/ore/glass/ten, "name" = "Sand (10)", "cost" = 35, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/glass/twenty, "name" = "Sand (20)", "cost" = 60, "max_supply" = 5),
		// Volcanic Ash:
		list("path" = /obj/item/stack/ore/glass/basalt/five, "name" = "Volcanic Ash (5)", "cost" = 20, "max_supply" = 15),
		list("path" = /obj/item/stack/ore/glass/basalt/ten, "name" = "Volcanic Ash (10)", "cost" = 35, "max_supply" = 10),
		list("path" = /obj/item/stack/ore/glass/basalt/twenty, "name" = "Volcanic Ash (20)", "cost" = 60, "max_supply" = 5),
		// Copper ore:
		list("path" = /obj/item/stack/ore/copper/five, "name" = "Copper Ore (5)", "cost" = 40, "max_supply" = 12),
		list("path" = /obj/item/stack/ore/copper/ten, "name" = "Copper Ore (10)", "cost" = 70, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/copper/twenty, "name" = "Copper Ore (20)", "cost" = 120, "max_supply" = 4),
		// Titanium ore: Alloy input for plastitanium.
		// Export check: buy at $120 + plasma ($200 export) → plastitanium ($350 export)
		// = $30 net gain/sheet. Marginal; raw plasma still better.
		list("path" = /obj/item/stack/ore/titanium/five, "name" = "Titanium Ore (5)", "cost" = 500, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/titanium/ten, "name" = "Titanium Ore (10)", "cost" = 900, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/titanium/twenty, "name" = "Titanium Ore (20)", "cost" = 1600, "max_supply" = 3),
		// -- Precious ores --
		list("path" = /obj/item/stack/ore/silver/five, "name" = "Silver Ore (5)", "cost" = 300, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/silver/ten, "name" = "Silver Ore (10)", "cost" = 550, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/silver/twenty, "name" = "Silver Ore (20)", "cost" = 1000, "max_supply" = 3),
		list("path" = /obj/item/stack/ore/gold/five, "name" = "Gold Ore (5)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/gold/ten, "name" = "Gold Ore (10)", "cost" = 750, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/gold/twenty, "name" = "Gold Ore (20)", "cost" = 1400, "max_supply" = 3),
		list("path" = /obj/item/stack/ore/diamond/five, "name" = "Diamond Ore (5)", "cost" = 1000, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/diamond/ten, "name" = "Diamond Ore (10)", "cost" = 1800, "max_supply" = 3),
		list("path" = /obj/item/stack/ore/diamond/twenty, "name" = "Diamond Ore (20)", "cost" = 3200, "max_supply" = 2),
		// -- Hazardous / Exotic ores --
		list("path" = /obj/item/stack/ore/uranium/five, "name" = "Uranium Ore (5)", "cost" = 400, "max_supply" = 8),
		list("path" = /obj/item/stack/ore/uranium/ten, "name" = "Uranium Ore (10)", "cost" = 750, "max_supply" = 5),
		list("path" = /obj/item/stack/ore/uranium/twenty, "name" = "Uranium Ore (20)", "cost" = 1400, "max_supply" = 3),
	)

// =============================================================================
// GLASS SHEETS
// =============================================================================

/datum/cargo_list/materials_glass
	crate_type = /obj/structure/closet/crate/engineering
	entries = list(
		// Glass: Same tier as iron — common construction material.
		list("path" = /obj/item/stack/sheet/glass/ten, "name" = "Glass Sheets (10)", "cost" = 120, "max_supply" = 15),
		list("path" = /obj/item/stack/sheet/glass/twenty, "name" = "Glass Sheets (20)", "cost" = 220, "max_supply" = 10),
		list("path" = /obj/item/stack/sheet/glass/fifty, "name" = "Glass Sheets (50)", "cost" = 500, "max_supply" = 5),
		// Reinforced glass: iron + glass composite. Impulse buy per sheet.
		list("path" = /obj/item/stack/sheet/rglass/ten, "name" = "Reinforced Glass (10)", "cost" = 180, "max_supply" = 10),
		list("path" = /obj/item/stack/sheet/rglass/twenty, "name" = "Reinforced Glass (20)", "cost" = 320, "max_supply" = 6),
		list("path" = /obj/item/stack/sheet/rglass/fifty, "name" = "Reinforced Glass (50)", "cost" = 700, "max_supply" = 3),
	)

// =============================================================================
// FLOOR TILES
// =============================================================================

/datum/cargo_list/materials_tiles
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Carpet tiles --
		// Carpet: Decorative, non-essential. Considered purchase for a stack of 50.
		// Standard/common colors: $100 for 50 ($2/tile). Cheap cosmetic.
		list("path" = /obj/item/stack/tile/carpet/fifty, "name" = "Standard Carpet Tiles (50)", "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/carpet/black/fifty, "name" = "Black Carpet Tiles (50)", "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/carpet/blue/fifty, "name" = "Blue Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/cyan/fifty, "name" = "Cyan Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/green/fifty, "name" = "Green Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/orange/fifty, "name" = "Orange Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/purple/fifty, "name" = "Purple Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/red/fifty, "name" = "Red Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/olive/fifty, "name" = "Olive Carpet Tiles (50)", "cost" = 100, "max_supply" = 4),
		// Royal carpets: Premium cosmetic, $150 for 50.
		list("path" = /obj/item/stack/tile/carpet/royalblack/fifty, "name" = "Royal Black Carpet Tiles (50)", "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/carpet/royalblue/fifty, "name" = "Royal Blue Carpet Tiles (50)", "cost" = 150, "max_supply" = 4),
		// Grimy: Novelty, cheaper than standard.
		list("path" = /obj/item/stack/tile/carpet/grimy/fifty, "name" = "Grimy Carpet Tiles (50)", "cost" = 60, "max_supply" = 4),
		list("path" = /obj/item/stack/tile/eighties/fifty, "name" = "Retro Tiles (50)", "cost" = 100, "max_supply" = 4),
		// -- Specialty floor tiles --
		// Single tiles: Pocket change, $5-15 each.
		list("path" = /obj/item/stack/tile/grass, "name" = "Grass Tile", "cost" = 10, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/wood, "name" = "Wood Floor Tile", "cost" = 5, "max_supply" = 8),
		list("path" = /obj/item/stack/tile/bamboo, "name" = "Bamboo Mat Piece", "cost" = 5, "max_supply" = 6),
		list("path" = /obj/item/stack/tile/fakespace, "name" = "Astral Carpet Tile", "cost" = 15, "max_supply" = 4),
		// No-slip: Functional upgrade, significant investment for 30 tiles.
		list("path" = /obj/item/stack/tile/noslip/thirty, "name" = "High-Traction Floor Tiles (30)", "cost" = 300, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		// -- Structural floor tiles --
		// Structural: Engineering materials, considered purchase to significant investment.
		list("path" = /obj/item/stack/tile/catwalk_tile/sixty, "name" = "Catwalk Floor Tiles (60)", "cost" = 250, "max_supply" = 4, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/tile/glass/sixty, "name" = "Glass Floor Tiles (60)", "cost" = 350, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
		list("path" = /obj/item/stack/tile/rglass/sixty, "name" = "Reinforced Glass Floor Tiles (60)", "cost" = 500, "max_supply" = 3, "crate_type" = /obj/structure/closet/crate/engineering),
	)

// =============================================================================
// GAS CANISTERS
// =============================================================================

// Dangerous / restricted canisters - access-locked crates
/datum/cargo_crate/materials_canisters
	access_budget = ACCESS_ATMOSPHERICS

/datum/cargo_crate/materials_canisters/carbon_dioxide
	name = "Carbon Dioxide Canister"
	cost = 1500
	max_supply = 2
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/materials_canisters/nitrous_oxide
	name = "Nitrous Oxide Canister"
	cost = 2000
	max_supply = 2
	access = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrous_oxide)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/materials_canisters/bz
	name = "BZ Canister"
	cost = 4000
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
		// Dispensers: Large equipment, capital expenditure tier ($500+).
		// Foam: Specialized safety equipment, premium.
		list("path" = /obj/structure/reagent_dispensers/foamtank, "name" = "Firefighting Foam Tank", "cost" = 800, "max_supply" = 2),
		// Fuel: Common consumable refill, moderate.
		list("path" = /obj/structure/reagent_dispensers/fueltank, "name" = "Welding Fuel Tank", "cost" = 600, "max_supply" = 3),
		// Water: Basic, cheapest dispenser.
		list("path" = /obj/structure/reagent_dispensers/watertank, "name" = "Water Tank", "cost" = 400, "max_supply" = 3),
		// High-cap water: Premium upgrade, significant investment.
		list("path" = /obj/structure/reagent_dispensers/watertank/high, "name" = "High-Capacity Water Tank", "cost" = 900, "max_supply" = 2),
	)

// Security-restricted dispensers, needs a secure crate for access to function
/datum/cargo_list/materials_dispensers_sec
	crate_type = /obj/structure/closet/crate/secure
	entries = list(
		// Pepper tank: Security equipment, major purchase. Weapons-adjacent pricing.
		list("path" = /obj/structure/reagent_dispensers/peppertank, "name" = "Pepper Spray Refiller", "cost" = 800, "max_supply" = 2, "access_budget" = ACCESS_SECURITY),
	)
