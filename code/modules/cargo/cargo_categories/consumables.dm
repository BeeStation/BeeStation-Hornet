/**
 * # Consumables Cargo Items
 *
 * Food, drinks, cooking supplies, hydroponics seeds, and other perishables.
 * Split into: Cooking Ingredients & Condiments, Snack Foods, Alcoholic Drinks,
 * Non-Alcoholic Drinks, Dinnerware & Barware, Seeds, Hydroponics Supplies,
 * and Food & Cooking Crates for bundles.
 */

// =============================================================================
// COOKING INGREDIENTS & CONDIMENTS  (Dinnerware vendor, kitchen staples)
// =============================================================================

/datum/cargo_list/consumables_ingredients
	small_item = TRUE
	entries = list(
		// -- Staple ingredients (Dinnerware vendor / kitchen essentials) --
		list("path" = /obj/item/reagent_containers/condiment/flour, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/rice, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/sugar, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/milk, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/soymilk, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/cream, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/storage/fancy/egg_box, "cost" = 40, "max_supply" = 6),
		list("path" = /obj/item/food/meat/slab/monkey, "cost" = 50, "max_supply" = 6),
		// -- Condiments (Dinnerware vendor condiment shelf) --
		list("path" = /obj/item/reagent_containers/condiment/saltshaker, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/peppermill, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/condiment/enzyme, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/soysauce, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/bbqsauce, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/ketchup, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/hotsauce, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/mayonnaise, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/honey, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/condiment/cherryjelly, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/vanilla, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/vegetable_oil, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/condiment/olive_oil, "cost" = 25, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/caramel, "cost" = 25, "max_supply" = 4),
		// -- Condiment packets --
		list("path" = /obj/item/reagent_containers/condiment/pack/ketchup, "cost" = 5, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/condiment/pack/hotsauce, "cost" = 5, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/condiment/pack/astrotame, "cost" = 5, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/condiment/pack/bbqsauce, "cost" = 5, "max_supply" = 12),
	)

// =============================================================================
// SNACK FOODS  (Getmore vendor, vending machine snacks, donk pockets)
// =============================================================================

/datum/cargo_list/consumables_snacks
	small_item = TRUE
	entries = list(
		// -- Getmore Chocolate Corp vendor snacks --
		list("path" = /obj/item/food/spacetwinkie, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/food/cheesiehonkers, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/food/candy, "cost" = 15, "max_supply" = 10),
		list("path" = /obj/item/food/chips, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/food/sosjerky, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/food/no_raisin, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/food/energybar, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/glass/dry_ramen, "cost" = 30, "max_supply" = 8),
		// -- Donk Pocket boxes --
		list("path" = /obj/item/storage/box/donkpockets, "cost" = 80, "max_supply" = 6),
		list("path" = /obj/item/storage/box/donkpockets/donkpocketspicy, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/storage/box/donkpockets/donkpocketteriyaki, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/storage/box/donkpockets/donkpocketpizza, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/storage/box/donkpockets/donkpocketberry, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/storage/box/donkpockets/donkpockethonk, "cost" = 100, "max_supply" = 4),
		// -- Canned goods --
		list("path" = /obj/item/food/canned/beans, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/food/canned/peaches, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/food/canned/beefbroth, "cost" = 25, "max_supply" = 10),
		// -- Pizza boxes --
		list("path" = /obj/item/pizzabox/margherita, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/pizzabox/mushroom, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/pizzabox/meat, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/pizzabox/vegetable, "cost" = 200, "max_supply" = 4),
		list("path" = /obj/item/pizzabox/pineapple, "cost" = 200, "max_supply" = 4),
		// -- Exotic meats --
		list("path" = /obj/item/food/meat/slab/human/mutant/slime, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/food/meat/slab/killertomato, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/food/meat/slab/bear, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/food/meat/slab/xeno, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/food/meat/slab/spider, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/food/meat/rawbacon, "cost" = 60, "max_supply" = 4),
		list("path" = /obj/item/food/meat/slab/penguin, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/food/spiderleg, "cost" = 80, "max_supply" = 3),
		list("path" = /obj/item/food/fishmeat/carp, "cost" = 80, "max_supply" = 4),
		list("path" = /obj/item/food/meat/slab/human, "cost" = 150, "max_supply" = 2),
		// -- Cream pies --
		list("path" = /obj/item/storage/backpack/duffelbag/clown/cream_pie, "cost" = 600, "max_supply" = 3),
	)

// =============================================================================
// ALCOHOLIC DRINKS  (Booze-O-Mat vendor)
// =============================================================================

/datum/cargo_list/consumables_alcohol
	small_item = TRUE
	access_budget = ACCESS_BAR
	entries = list(
		// -- Standard spirits & wines --
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/beer, "cost" = 50, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/ale, "cost" = 60, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/wine, "cost" = 120, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/whiskey, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/vodka, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/rum, "cost" = 120, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/gin, "cost" = 100, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/tequila, "cost" = 120, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/cognac, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/vermouth, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/kahlua, "cost" = 120, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/sake, "cost" = 120, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/applejack, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/hcider, "cost" = 80, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/grappa, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/fernet, "cost" = 150, "max_supply" = 4),
		// -- Premium spirits --
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/patron, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/goldschlager, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/absinthe, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/champagne, "cost" = 250, "max_supply" = 3),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/trappist, "cost" = 200, "max_supply" = 3),
	)

// =============================================================================
// NON-ALCOHOLIC DRINKS  (Robust Softdrinks, Solar's Best, Booze-O-Mat mixers)
// =============================================================================

/datum/cargo_list/consumables_softdrinks
	small_item = TRUE
	entries = list(
		// -- Soda cans (Robust Softdrinks vendor) --
		list("path" = /obj/item/reagent_containers/cup/soda_cans/cola, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/lemon_lime, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/dr_gibb, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/space_up, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/starkist, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/space_mountain_wind, "cost" = 25, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/pwr_game, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/shamblers, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/sol_dry, "cost" = 25, "max_supply" = 12),
		// -- Mixers & carbonated water (Booze-O-Mat) --
		list("path" = /obj/item/reagent_containers/cup/soda_cans/sodawater, "cost" = 15, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/tonic, "cost" = 15, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/grenadine, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/bottleofnothing, "cost" = 50, "max_supply" = 3),
		// -- Energy drinks --
		list("path" = /obj/item/reagent_containers/cup/soda_cans/grey_bull, "cost" = 40, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/soda_cans/monkey_energy, "cost" = 40, "max_supply" = 8),
		// -- Juice bottles (Booze-O-Mat non-alcoholic shelf) --
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/limejuice, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/cream, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice, "cost" = 30, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/juice/menthol, "cost" = 30, "max_supply" = 4),
		// -- Water --
		list("path" = /obj/item/reagent_containers/cup/glass/waterbottle, "cost" = 10, "max_supply" = 15),
		list("path" = /obj/item/reagent_containers/cup/glass/waterbottle/large, "cost" = 20, "max_supply" = 10),
		// -- Hot drinks (Solar's Best vendor) --
		list("path" = /obj/item/reagent_containers/cup/glass/coffee, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/glass/mug/tea, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/glass/mug/cocoa, "cost" = 25, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/glass/bubble_tea, "cost" = 25, "max_supply" = 8),
	)

// =============================================================================
// DINNERWARE & BARWARE  (Dinnerware vendor, Booze-O-Mat glassware)
// =============================================================================

/datum/cargo_list/consumables_dinnerware
	small_item = TRUE
	entries = list(
		// -- Kitchen equipment (Dinnerware vendor) --
		list("path" = /obj/item/storage/bag/tray, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bowl, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/kitchen/fork, "cost" = 5, "max_supply" = 8),
		list("path" = /obj/item/knife/kitchen, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/kitchen/rollingpin, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/clothing/suit/apron/chef, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/sharpener, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/item/plate/small, "cost" = 10, "max_supply" = 8),
		list("path" = /obj/item/plate, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/plate/large, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/book/granter/crafting_recipe/cooking_sweets_101, "cost" = 200, "max_supply" = 2),
		// -- Cooking appliances --
		list("path" = /obj/machinery/grill/unwrenched, "cost" = 500, "max_supply" = 2, "small_item" = FALSE),
		list("path" = /obj/item/stack/sheet/mineral/coal/five, "cost" = 50, "max_supply" = 6),
		list("path" = /obj/item/stack/sheet/mineral/coal/ten, "cost" = 90, "max_supply" = 4),
		// -- Glassware & barware (Booze-O-Mat) --
		list("path" = /obj/item/reagent_containers/cup/glass/drinkingglass, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass, "cost" = 5, "max_supply" = 12),
		list("path" = /obj/item/reagent_containers/cup/glass/ice, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/glass/flask, "cost" = 60, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/reagent_containers/cup/glass/bottle/small, "cost" = 5, "max_supply" = 15),
		list("path" = /obj/item/storage/box/drinkingglasses, "cost" = 80, "max_supply" = 4),
		list("path" = /obj/item/reagent_containers/cup/glass/shaker, "cost" = 60, "max_supply" = 4),
	)

// =============================================================================
// SEEDS  (MegaSeed Servitor - all standard & contraband seeds)
// =============================================================================

/datum/cargo_list/consumables_seeds
	access_budget = ACCESS_HYDROPONICS
	small_item = TRUE
	entries = list(
		// -- Fruits --
		list("path" = /obj/item/seeds/apple, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/banana, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/berry, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/cherry, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/grape, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/coconut, "cost" = 25, "max_supply" = 4),
		list("path" = /obj/item/seeds/pineapple, "cost" = 25, "max_supply" = 4),
		list("path" = /obj/item/seeds/watermelon, "cost" = 20, "max_supply" = 6),
		// -- Citrus --
		list("path" = /obj/item/seeds/lime, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/orange, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/lemon, "cost" = 20, "max_supply" = 6),
		// -- Vegetables --
		list("path" = /obj/item/seeds/cabbage, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/carrot, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/chili, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/corn, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/eggplant, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/garlic, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/onion, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/potato, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/pumpkin, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/tomato, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/soya, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/whitebeet, "cost" = 15, "max_supply" = 6),
		// -- Grains & staples --
		list("path" = /obj/item/seeds/wheat, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/wheat/rice, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/wheat/oat, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/sugarcane, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/cotton, "cost" = 15, "max_supply" = 6),
		// -- Herbs & stimulants --
		list("path" = /obj/item/seeds/ambrosia, "cost" = 25, "max_supply" = 4),
		list("path" = /obj/item/seeds/tea, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/coffee, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/tobacco, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/cocoapod, "cost" = 20, "max_supply" = 6),
		// -- Mushrooms --
		list("path" = /obj/item/seeds/chanter, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/plump, "cost" = 25, "max_supply" = 4),
		list("path" = /obj/item/seeds/reishi, "cost" = 30, "max_supply" = 3),
		list("path" = /obj/item/seeds/glowshroom, "cost" = 30, "max_supply" = 3),
		// -- Flowers & decorative --
		list("path" = /obj/item/seeds/sunflower, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/flower/poppy, "cost" = 15, "max_supply" = 6),
		list("path" = /obj/item/seeds/flower/lily, "cost" = 20, "max_supply" = 4),
		list("path" = /obj/item/seeds/flower/geranium, "cost" = 20, "max_supply" = 4),
		list("path" = /obj/item/seeds/flower/harebell, "cost" = 15, "max_supply" = 4),
		list("path" = /obj/item/seeds/flower/rainbow_bunch, "cost" = 30, "max_supply" = 3),
		list("path" = /obj/item/seeds/grass, "cost" = 10, "max_supply" = 6),
		// -- Trees & structural --
		list("path" = /obj/item/seeds/tower, "cost" = 20, "max_supply" = 6),
		list("path" = /obj/item/seeds/bamboo, "cost" = 25, "max_supply" = 4),
		// -- Exotic (MegaSeed contraband) --
		list("path" = /obj/item/seeds/nettle, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/seeds/dionapod, "cost" = 30, "max_supply" = 4),
		list("path" = /obj/item/seeds/liberty, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/seeds/amanita, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/seeds/eggplant/eggy, "cost" = 35, "max_supply" = 3),
		list("path" = /obj/item/seeds/random, "cost" = 50, "max_supply" = 4),
	)

// =============================================================================
// HYDROPONICS SUPPLIES  (NutriMax vendor chemicals & gear)
// =============================================================================

/datum/cargo_list/consumables_hydro
	access_budget = ACCESS_HYDROPONICS
	small_item = TRUE
	entries = list(
		// -- Plant nutrients (NutriMax vendor) --
		list("path" = /obj/item/reagent_containers/cup/bottle/nutrient/ez, "cost" = 20, "max_supply" = 10),
		list("path" = /obj/item/reagent_containers/cup/bottle/nutrient/l4z, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/nutrient/rh, "cost" = 50, "max_supply" = 6),
		// -- Pest & weed control --
		list("path" = /obj/item/reagent_containers/spray/pestspray, "cost" = 40, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/killer/weedkiller, "cost" = 40, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/killer/pestkiller, "cost" = 40, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/cup/bottle/ammonia, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/reagent_containers/cup/bottle/diethylamine, "cost" = 50, "max_supply" = 4),
		// -- Tools & accessories (NutriMax / general hydro gear) --
		list("path" = /obj/item/storage/bag/plants, "cost" = 100, "max_supply" = 4),
		list("path" = /obj/item/shovel/spade, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/item/honey_frame, "cost" = 80, "max_supply" = 6),
		list("path" = /obj/item/melee/flyswatter, "cost" = 30, "max_supply" = 4, "access_budget" = FALSE),
		// -- Beekeeper protective gear --
		list("path" = /obj/item/clothing/suit/utility/beekeeper_suit, "cost" = 150, "max_supply" = 4),
		list("path" = /obj/item/clothing/head/utility/beekeeper_head, "cost" = 100, "max_supply" = 4),
		// -- Decorative --
		list("path" = /obj/item/kirbyplants/random, "cost" = 120, "max_supply" = 8, "access_budget" = FALSE),
	)

// =============================================================================
// CRATES  (Starter kits only)
// =============================================================================

/datum/cargo_crate/consumables_hydro
	access_budget = ACCESS_HYDROPONICS
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/cargo_crate/consumables_hydro/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	cost = 2500
	max_supply = 1
	contains = list(
		/obj/structure/beebox/unwrenched,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/queen_bee/bought,
		/obj/item/clothing/head/utility/beekeeper_head,
		/obj/item/clothing/suit/utility/beekeeper_suit,
		/obj/item/melee/flyswatter,
	)
