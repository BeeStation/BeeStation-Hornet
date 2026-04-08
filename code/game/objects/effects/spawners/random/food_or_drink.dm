/obj/effect/spawner/random/food_or_drink
	name = "food or drink loot spawner"
	desc = "Nom nom nom"

/obj/effect/spawner/random/food_or_drink/donkpockets
	name = "donk pocket box spawner"
	icon_state = "donkpocket"
	loot = list(
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk,
	)

/obj/effect/spawner/random/food_or_drink/donkpocketsfinlandia
	name = "5% gondola pocket spawner"
	icon_state = "donkpocket"
	loot = list(
		/obj/item/storage/box/donkpockets = 19,
		/obj/item/storage/box/donkpockets/donkpocketgondolafinlandia = 1
	)

/obj/effect/spawner/random/food_or_drink/seed
	name = "seed spawner"
	icon_state = "seed"
	loot = list( // The same seeds in the Supply "Seeds Crate"
		/obj/item/plant_seeds/preset/chili,
		/obj/item/plant_seeds/preset/cotton,
		/obj/item/plant_seeds/preset/berry,
		/obj/item/plant_seeds/preset/corn,
		/obj/item/plant_seeds/preset/eggplant,
		/obj/item/plant_seeds/preset/tomato,
		/obj/item/plant_seeds/preset/soybean,
		/obj/item/plant_seeds/preset/wheat,
		/obj/item/plant_seeds/preset/rice,
		/obj/item/plant_seeds/preset/carrot,
		/obj/item/plant_seeds/preset/sunflower,
		/obj/item/plant_seeds/preset/chanterelle,
		/obj/item/plant_seeds/preset/potato,
		/obj/item/plant_seeds/preset/sugarcane,
	)

/obj/effect/spawner/random/food_or_drink/seed_rare
	spawn_loot_count = 5
	icon_state = "seed"
	loot = list( // /obj/item/plant_seeds/random is not a random seed, but an exotic seed.
		/obj/item/plant_seeds/random = 30,
		/obj/item/plant_seeds/preset/liberty = 5,
		/obj/item/plant_seeds/preset/diona_pod = 5,
		/obj/item/plant_seeds/preset/reishi = 5,
		/obj/item/plant_seeds/preset/death_nettle = 1,
		/obj/item/plant_seeds/preset/walking = 1,
		/obj/item/plant_seeds/preset/rainbow_cannabis = 1,
		/obj/item/plant_seeds/preset/omega_cannabis = 1,
		/obj/item/plant_seeds/preset/kudzu = 1,
		/obj/item/plant_seeds/preset/angel = 1,
		/obj/item/plant_seeds/preset/glowcap = 1,
		/obj/item/plant_seeds/preset/shadowshroom = 1,
	)

/obj/effect/spawner/random/food_or_drink/soup
	name = "soup spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/food/soup/beet,
		/obj/item/food/soup/sweetpotato,
		/obj/item/food/soup/stew,
		/obj/item/food/soup/hotchili,
		/obj/item/food/soup/nettle,
		/obj/item/food/soup/meatball,
	)

/obj/effect/spawner/random/food_or_drink/salad
	name = "salad spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/food/salad/herbsalad,
		/obj/item/food/salad/validsalad,
		/obj/item/food/salad/fruit,
		/obj/item/food/salad/jungle,
		/obj/item/food/salad/aesirsalad,
	)

/obj/effect/spawner/random/food_or_drink/dinner
	name = "dinner spawner"
	icon_state = "soup"
	loot = list(
		/obj/item/food/bearsteak,
		/obj/item/food/enchiladas,
		/obj/item/food/stewedsoymeat,
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/superbite,
		/obj/item/food/burger/fivealarm,
	)

/obj/effect/spawner/random/food_or_drink/three_course_meal
	name = "three course meal spawner"
	icon_state = "soup"
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/spawner/random/food_or_drink/soup,
		/obj/effect/spawner/random/food_or_drink/salad,
		/obj/effect/spawner/random/food_or_drink/dinner,
	)

/obj/effect/spawner/random/food_or_drink/refreshing_beverage
	name = "good soda spawner"
	icon_state = "can"
	loot = list(
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola = 3,
		/obj/item/reagent_containers/cup/soda_cans/grey_bull = 3,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy = 2,
		/obj/item/reagent_containers/cup/soda_cans/thirteenloko = 2,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 2,
		/obj/item/reagent_containers/cup/soda_cans/shamblers = 1,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game = 1,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb = 1,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 1,
		/obj/item/reagent_containers/cup/soda_cans/starkist = 1,
		/obj/item/reagent_containers/cup/soda_cans/space_up = 1,
		/obj/item/reagent_containers/cup/soda_cans/sol_dry = 1,
		/obj/item/reagent_containers/cup/soda_cans/cola = 1,
	)

/obj/effect/spawner/random/food_or_drink/booze
	name = "booze spawner"
	icon_state = "beer"
	loot = list(
		/obj/item/reagent_containers/cup/glass/bottle/beer = 75,
		/obj/item/reagent_containers/cup/glass/bottle/ale = 25,
		/obj/item/reagent_containers/cup/glass/bottle/beer/light = 5,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey = 5,
		/obj/item/reagent_containers/cup/glass/bottle/gin = 5,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 5,
		/obj/item/reagent_containers/cup/glass/bottle/tequila = 5,
		/obj/item/reagent_containers/cup/glass/bottle/rum = 5,
		/obj/item/reagent_containers/cup/glass/bottle/vermouth = 5,
		/obj/item/reagent_containers/cup/glass/bottle/cognac = 5,
		/obj/item/reagent_containers/cup/glass/bottle/wine = 5,
		/obj/item/reagent_containers/cup/glass/bottle/kahlua = 5,
		/obj/item/reagent_containers/cup/glass/bottle/hcider = 5,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe = 5,
		/obj/item/reagent_containers/cup/glass/bottle/sake = 5,
		/obj/item/reagent_containers/cup/glass/bottle/grappa = 5,
		/obj/item/reagent_containers/cup/glass/bottle/applejack = 5,
		/obj/item/reagent_containers/cup/bottle/ethanol = 2,
		/obj/item/reagent_containers/cup/glass/bottle/fernet = 2,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 2,
		/obj/item/reagent_containers/cup/glass/bottle/goldschlager = 2,
		/obj/item/reagent_containers/cup/glass/bottle/patron = 1,
		/obj/item/reagent_containers/cup/glass/bottle/lizardwine = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka/badminka = 1,
		/obj/item/reagent_containers/cup/glass/bottle/trappist = 1,
	)

/obj/effect/spawner/random/food_or_drink/pizzaparty
	name = "pizza bomb spawner"
	icon_state = "pizzabox"
	loot = list(
		/obj/item/pizzabox/margherita = 2,
		/obj/item/pizzabox/meat = 2,
		/obj/item/pizzabox/mushroom = 2,
		/obj/item/pizzabox/pineapple = 2,
		/obj/item/pizzabox/vegetable = 2,
		/obj/item/pizzabox/bomb/armed = 1,

	)

/obj/effect/spawner/random/food_or_drink/seed_vault
	name = "seed vault seeds"
	icon_state = "seed"
	loot = list(
		/obj/item/plant_seeds/preset/gat = 10,
		/obj/item/plant_seeds/preset/cherry_bomb = 10,
		/obj/item/plant_seeds/preset/glow_berry = 10,
		/obj/item/plant_seeds/preset/moonflower = 8,
	)

/obj/effect/spawner/random/food_or_drink/snack
	name = "snack spawner"
	icon_state = "chips"
	loot = list(
		/obj/item/food/spacetwinkie = 5,
		/obj/item/food/cheesiehonkers = 5,
		/obj/item/food/candy = 5,
		/obj/item/food/chips = 5,
		/obj/item/food/sosjerky = 5,
		/obj/item/food/no_raisin = 5,
		/obj/item/food/energybar = 5,
		/obj/item/reagent_containers/cup/glass/dry_ramen = 5,
		/obj/item/food/syndicake = 1,
	)

/obj/effect/spawner/random/food_or_drink/condiment
	name = "condiment spawner"
	icon_state = "condiment"
	loot = list(
		/obj/item/reagent_containers/condiment/saltshaker = 3,
		/obj/item/reagent_containers/condiment/peppermill = 3,
		/obj/item/reagent_containers/condiment/pack/ketchup = 3,
		/obj/item/reagent_containers/condiment/pack/hotsauce = 3,
		/obj/item/reagent_containers/condiment/pack/astrotame = 3,
		/obj/item/reagent_containers/condiment/pack/bbqsauce = 3,
		/obj/item/reagent_containers/condiment/bbqsauce = 1,
		/obj/item/reagent_containers/condiment/soysauce = 1,
		/obj/item/reagent_containers/condiment/olive_oil = 1,
		/obj/item/reagent_containers/condiment/cherryjelly = 1,
	)

/obj/effect/spawner/random/food_or_drink/cups
	name = "cup spawner"
	icon_state = "box_small"
	loot = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/storage/box/cups,
		/obj/item/storage/box/condimentbottles,
	)
