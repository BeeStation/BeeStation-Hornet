/**
 * # Consumables Cargo Items
 *
 * Food, drinks, cooking supplies, hydroponics seeds, and other perishables.
 * Split into Food & Cooking, Alcoholic Drinks, Non-Alcoholic Drinks,
 * Seeds, and Hydroponics Supplies.
 */

// =============================================================================
// FOOD & COOKING
// =============================================================================

/datum/cargo_crate/consumables_food
	category = "Consumables"
	subcategory = "Food & Cooking"
	crate_type = /obj/structure/closet/crate/freezer

/datum/cargo_crate/consumables_food/food
	name = "Food Supplies Crate"
	desc = "Contains basic cooking ingredients: flour, rice, milk, soy milk, salt, pepper, eggs, enzyme, sugar, meat, and bananas."
	cost = 1500
	max_supply = 3
	contains = list(
		/obj/item/reagent_containers/condiment/flour,
		/obj/item/reagent_containers/condiment/rice,
		/obj/item/reagent_containers/condiment/milk,
		/obj/item/reagent_containers/condiment/soymilk,
		/obj/item/reagent_containers/condiment/saltshaker,
		/obj/item/reagent_containers/condiment/peppermill,
		/obj/item/storage/fancy/egg_box,
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/reagent_containers/condiment/sugar,
		/obj/item/food/meat/slab/monkey,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
	)

/datum/cargo_crate/consumables_food/pizza
	name = "Pizza Crate"
	desc = "Contains five assorted pizzas."
	cost = 1500
	max_supply = 3
	contains = list(
		/obj/item/pizzabox/margherita,
		/obj/item/pizzabox/mushroom,
		/obj/item/pizzabox/meat,
		/obj/item/pizzabox/vegetable,
		/obj/item/pizzabox/pineapple,
	)

/datum/cargo_crate/consumables_food/pizza/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/consumables_food/pizza/proc/anomalous_pizza_report()

/datum/cargo_crate/consumables_food/chef_exotic
	name = "Exotic Meats Crate"
	desc = "Contains an assortment of exotic meats for the discerning chef."
	cost = 2000
	max_supply = 2
	contains = list(
		/obj/item/food/meat/slab/human/mutant/slime,
		/obj/item/food/meat/slab/killertomato,
		/obj/item/food/meat/slab/bear,
		/obj/item/food/meat/slab/xeno,
		/obj/item/food/meat/slab/spider,
		/obj/item/food/meat/rawbacon,
		/obj/item/food/meat/slab/penguin,
		/obj/item/food/spiderleg,
		/obj/item/food/fishmeat/carp,
		/obj/item/food/meat/slab/human,
	)

/datum/cargo_crate/consumables_food/chef_exotic/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/consumables_food/fruits
	name = "Fresh Fruit Crate"
	desc = "Contains an assortment of fresh fruits."
	cost = 1000
	max_supply = 3
	contains = list(
		/obj/item/food/grown/citrus/lime,
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/grown/watermelon,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/berries,
		/obj/item/food/grown/citrus/lemon,
	)

/datum/cargo_crate/consumables_food/vegetables
	name = "Fresh Vegetable Crate"
	desc = "Contains an assortment of fresh vegetables."
	cost = 1000
	max_supply = 3
	contains = list(
		/obj/item/food/grown/chili,
		/obj/item/food/grown/corn,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/potato,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/mushroom/chanterelle,
		/obj/item/food/grown/onion,
		/obj/item/food/grown/pumpkin,
	)

/datum/cargo_crate/consumables_food/cream_pie
	name = "Cream Pie Crate"
	desc = "Contains a duffelbag full of cream pies."
	cost = 800
	max_supply = 3
	contains = list(/obj/item/storage/backpack/duffelbag/clown/cream_pie)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/consumables_food/grill
	name = "Grill Crate"
	desc = "Contains a grill, coal, and a Monkey Energy soda."
	cost = 1000
	max_supply = 2
	contains = list(
		/obj/item/stack/sheet/mineral/coal/five,
		/obj/machinery/grill/unwrenched,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy,
	)
	crate_type = /obj/structure/closet/crate

/datum/cargo_crate/consumables_food/grillfuel
	name = "Grill Fuel Crate"
	desc = "Contains coal and a Monkey Energy soda."
	cost = 400
	max_supply = 4
	contains = list(
		/obj/item/stack/sheet/mineral/coal/ten,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy,
	)
	crate_type = /obj/structure/closet/crate

/datum/cargo_crate/consumables_food/beefbroth
	name = "Beef Broth Crate"
	desc = "Contains ten cans of beef broth."
	cost = 500
	max_supply = 4
	contains = list(
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
	)
	crate_type = /obj/structure/closet/crate

/datum/cargo_crate/consumables_food/donkpockets
	name = "Deluxe Donk Pocket Crate"
	desc = "Contains an assortment of specialty Donk Pockets."
	cost = 1000
	max_supply = 3
	contains = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)

// =============================================================================
// ALCOHOLIC DRINKS
// =============================================================================

/datum/cargo_item/consumables_alcohol
	category = "Consumables"
	subcategory = "Alcoholic Drinks"
	small_item = TRUE

/datum/cargo_item/consumables_alcohol/beer
	name = "Bottle of Beer"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/beer
	cost = 50
	max_supply = 12

/datum/cargo_item/consumables_alcohol/ale
	name = "Bottle of Ale"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/ale
	cost = 60
	max_supply = 10

/datum/cargo_item/consumables_alcohol/wine
	name = "Bottle of Wine"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/wine
	cost = 120
	max_supply = 6

/datum/cargo_item/consumables_alcohol/whiskey
	name = "Bottle of Whiskey"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/whiskey
	cost = 150
	max_supply = 4

/datum/cargo_item/consumables_alcohol/vodka
	name = "Bottle of Vodka"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/vodka
	cost = 100
	max_supply = 6

/datum/cargo_item/consumables_alcohol/rum
	name = "Bottle of Rum"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/rum
	cost = 120
	max_supply = 6

/datum/cargo_item/consumables_alcohol/gin
	name = "Bottle of Gin"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/gin
	cost = 100
	max_supply = 6

/datum/cargo_item/consumables_alcohol/tequila
	name = "Bottle of Tequila"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/tequila
	cost = 120
	max_supply = 4

/datum/cargo_item/consumables_alcohol/cognac
	name = "Bottle of Cognac"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/cognac
	cost = 150
	max_supply = 4

/datum/cargo_item/consumables_alcohol/vermouth
	name = "Bottle of Vermouth"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/vermouth
	cost = 100
	max_supply = 4

/datum/cargo_item/consumables_alcohol/kahlua
	name = "Bottle of Kahlua"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/kahlua
	cost = 120
	max_supply = 4

/datum/cargo_item/consumables_alcohol/patron
	name = "Bottle of Patron"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/patron
	cost = 200
	max_supply = 3

/datum/cargo_item/consumables_alcohol/goldschlager
	name = "Bottle of Goldschlager"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/goldschlager
	cost = 200
	max_supply = 3

/datum/cargo_item/consumables_alcohol/absinthe
	name = "Bottle of Absinthe"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/absinthe
	cost = 200
	max_supply = 3

/datum/cargo_item/consumables_alcohol/champagne
	name = "Bottle of Champagne"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/champagne
	cost = 250
	max_supply = 3

/datum/cargo_item/consumables_alcohol/sake
	name = "Bottle of Sake"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/sake
	cost = 120
	max_supply = 4

/datum/cargo_item/consumables_alcohol/applejack
	name = "Bottle of Applejack"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/applejack
	cost = 100
	max_supply = 4

/datum/cargo_item/consumables_alcohol/cider
	name = "Bottle of Hard Cider"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/hcider
	cost = 80
	max_supply = 6

/datum/cargo_item/consumables_alcohol/grappa
	name = "Bottle of Grappa"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/grappa
	cost = 150
	max_supply = 4

// =============================================================================
// NON-ALCOHOLIC DRINKS
// =============================================================================

/datum/cargo_item/consumables_softdrinks
	category = "Consumables"
	subcategory = "Non-Alcoholic Drinks"
	small_item = TRUE

/datum/cargo_item/consumables_softdrinks/bottle_nothing
	name = "Bottle of Nothing"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/bottleofnothing
	cost = 50
	max_supply = 3

/datum/cargo_item/consumables_softdrinks/cola
	name = "Can of Space Cola"
	item_path = /obj/item/reagent_containers/cup/soda_cans/cola
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/lemon_lime
	name = "Can of Lemon-Lime"
	item_path = /obj/item/reagent_containers/cup/soda_cans/lemon_lime
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/dr_gibb
	name = "Can of Dr. Gibb"
	item_path = /obj/item/reagent_containers/cup/soda_cans/dr_gibb
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/space_up
	name = "Can of Space-Up"
	item_path = /obj/item/reagent_containers/cup/soda_cans/space_up
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/starkist
	name = "Can of Star-kist"
	item_path = /obj/item/reagent_containers/cup/soda_cans/starkist
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/space_mountain_wind
	name = "Can of Space Mountain Wind"
	item_path = /obj/item/reagent_containers/cup/soda_cans/space_mountain_wind
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/sodawater
	name = "Can of Soda Water"
	item_path = /obj/item/reagent_containers/cup/soda_cans/sodawater
	cost = 15
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/tonic
	name = "Can of Tonic Water"
	item_path = /obj/item/reagent_containers/cup/soda_cans/tonic
	cost = 15
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/sol_dry
	name = "Can of Sol Dry"
	item_path = /obj/item/reagent_containers/cup/soda_cans/sol_dry
	cost = 25
	max_supply = 12

/datum/cargo_item/consumables_softdrinks/grey_bull
	name = "Can of Grey Bull"
	item_path = /obj/item/reagent_containers/cup/soda_cans/grey_bull
	cost = 40
	max_supply = 8

/datum/cargo_item/consumables_softdrinks/monkey_energy
	name = "Can of Monkey Energy"
	item_path = /obj/item/reagent_containers/cup/soda_cans/monkey_energy
	cost = 40
	max_supply = 8

/datum/cargo_item/consumables_softdrinks/pwr_game
	name = "Can of Pwr Game"
	item_path = /obj/item/reagent_containers/cup/soda_cans/pwr_game
	cost = 30
	max_supply = 10

/datum/cargo_item/consumables_softdrinks/shamblers
	name = "Can of Shambler's Juice"
	item_path = /obj/item/reagent_containers/cup/soda_cans/shamblers
	cost = 30
	max_supply = 10

/datum/cargo_item/consumables_softdrinks/grenadine
	name = "Bottle of Grenadine"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/grenadine
	cost = 50
	max_supply = 6

/datum/cargo_item/consumables_softdrinks/drinking_glasses
	name = "Box of Drinking Glasses"
	item_path = /obj/item/storage/box/drinkingglasses
	cost = 80
	max_supply = 4

/datum/cargo_item/consumables_softdrinks/shaker
	name = "Cocktail Shaker"
	item_path = /obj/item/reagent_containers/cup/glass/shaker
	cost = 60
	max_supply = 4

/datum/cargo_crate/consumables_softdrinks
	category = "Consumables"
	subcategory = "Non-Alcoholic Drinks"

/datum/cargo_crate/consumables_softdrinks/soda
	name = "Soda Crate"
	desc = "Contains an assortment of refreshing soft drinks."
	cost = 500
	max_supply = 4
	contains = list(
		/obj/item/reagent_containers/cup/soda_cans/cola,
		/obj/item/reagent_containers/cup/soda_cans/cola,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb,
		/obj/item/reagent_containers/cup/soda_cans/space_up,
		/obj/item/reagent_containers/cup/soda_cans/starkist,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind,
	)

// =============================================================================
// SEEDS
// =============================================================================

/datum/cargo_crate/consumables_seeds
	category = "Consumables"
	subcategory = "Seeds"
	access_budget = ACCESS_HYDROPONICS
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/cargo_crate/consumables_seeds/seeds
	name = "Seed Crate"
	desc = "Contains an assortment of basic crop seeds."
	cost = 1000
	max_supply = 3
	contains = list(
		/obj/item/seeds/chili,
		/obj/item/seeds/cotton,
		/obj/item/seeds/berry,
		/obj/item/seeds/corn,
		/obj/item/seeds/eggplant,
		/obj/item/seeds/tomato,
		/obj/item/seeds/soya,
		/obj/item/seeds/wheat,
		/obj/item/seeds/wheat/rice,
		/obj/item/seeds/carrot,
		/obj/item/seeds/sunflower,
		/obj/item/seeds/chanter,
		/obj/item/seeds/potato,
		/obj/item/seeds/sugarcane,
	)

/datum/cargo_crate/consumables_seeds/exoticseeds
	name = "Exotic Seed Crate"
	desc = "Contains exotic and rare seeds including nettles, dionaea, mushrooms, and random varieties."
	cost = 2000
	max_supply = 2
	contains = list(
		/obj/item/seeds/nettle,
		/obj/item/seeds/dionapod,
		/obj/item/seeds/dionapod,
		/obj/item/seeds/dionapod,
		/obj/item/seeds/plump,
		/obj/item/seeds/liberty,
		/obj/item/seeds/amanita,
		/obj/item/seeds/reishi,
		/obj/item/seeds/banana,
		/obj/item/seeds/bamboo,
		/obj/item/seeds/eggplant/eggy,
		/obj/item/seeds/flower/rainbow_bunch,
		/obj/item/seeds/flower/rainbow_bunch,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
	)

// =============================================================================
// HYDROPONICS SUPPLIES
// =============================================================================

/datum/cargo_item/consumables_hydro
	category = "Consumables"
	subcategory = "Hydroponics Supplies"
	access_budget = ACCESS_HYDROPONICS

/datum/cargo_item/consumables_hydro/potted_plant
	name = "Random Potted Plant"
	item_path = /obj/item/kirbyplants/random
	cost = 120
	max_supply = 8
	small_item = TRUE

/datum/cargo_item/consumables_hydro/dog_bone
	name = "Dog Bone"
	item_path = /obj/item/dog_bone
	cost = 100
	max_supply = 5
	small_item = TRUE
	access_budget = FALSE

/datum/cargo_item/consumables_hydro/monkey_cubes
	name = "Monkey Cube Box"
	item_path = /obj/item/storage/box/monkeycubes
	cost = 800
	max_supply = 3
	small_item = TRUE
	access_budget = FALSE

/datum/cargo_crate/consumables_hydro
	category = "Consumables"
	subcategory = "Hydroponics Packs"
	access_budget = ACCESS_HYDROPONICS
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/cargo_crate/consumables_hydro/beekeeping_suits
	name = "Beekeeper Suits Crate"
	desc = "Contains two sets of beekeeper suits and hoods."
	cost = 800
	max_supply = 2
	contains = list(
		/obj/item/clothing/head/utility/beekeeper_head,
		/obj/item/clothing/suit/utility/beekeeper_suit,
		/obj/item/clothing/head/utility/beekeeper_head,
		/obj/item/clothing/suit/utility/beekeeper_suit,
	)

/datum/cargo_crate/consumables_hydro/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	desc = "Contains a bee box, honey frames, a queen bee, beekeeper suit, and a flyswatter."
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
