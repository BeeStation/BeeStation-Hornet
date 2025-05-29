
//SEAFOOD

/datum/crafting_recipe/food/cubancarp
	name = "Cuban carp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/cubancarp
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/fishandchips
	name = "Fish and chips"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishandchips
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/fishfingers
	name = "Fish fingers"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishfingers
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/sashimi
	name = "Sashimi"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/sashimi
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/vegetarian_sushi_roll
	name ="Vegetarian sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/sushi_roll/vegetarian
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/spicy_filet_sushi_roll
	name ="Spicy filet sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/onion = 1
	)
	result = /obj/item/food/sushi_roll/spicyfilet
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/futomaki_sushi_roll
	name ="Futomaki sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/sushi_roll/futomaki
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/philadelphia_sushi_roll
	name ="Philadelphia sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/sushi_roll/philadelphia
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/nigiri_sushi
	name ="Nigiri sushi"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fishmeat/carp = 1,
		/datum/reagent/consumable/soysauce = 2
	)
	result = /obj/item/food/nigiri_sushi
	category = CAT_SEAFOOD
