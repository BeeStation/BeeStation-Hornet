/**
 * # Consumables Cargo Items
 *
 * Food, drinks, cooking supplies, hydroponics seeds, and other perishables.
 * Split into Food & Cooking, Drinks, Seeds, and Hydroponics Supplies.
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
// DRINKS & PARTY
// =============================================================================

/datum/cargo_crate/consumables_drinks
	category = "Consumables"
	subcategory = "Drinks & Party"

/datum/cargo_crate/consumables_drinks/party
	name = "Party Supplies Crate"
	desc = "Contains drinks, glasses, a shaker, glowsticks, and a party capsule."
	cost = 2000
	max_supply = 2
	contains = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/reagent_containers/cup/glass/shaker,
		/obj/item/reagent_containers/cup/glass/bottle/patron,
		/obj/item/reagent_containers/cup/glass/bottle/goldschlager,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/flashlight/glowstick,
		/obj/item/flashlight/glowstick/red,
		/obj/item/flashlight/glowstick/blue,
		/obj/item/flashlight/glowstick/cyan,
		/obj/item/flashlight/glowstick/orange,
		/obj/item/flashlight/glowstick/yellow,
		/obj/item/flashlight/glowstick/pink,
		/obj/item/survivalcapsule/party,
	)

/datum/cargo_item/consumables_drinks/bottle_nothing
	name = "Bottle of Nothing"
	category = "Consumables"
	subcategory = "Drinks & Party"
	item_path = /obj/item/reagent_containers/cup/glass/bottle/bottleofnothing
	cost = 50
	max_supply = 3
	small_item = TRUE

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
