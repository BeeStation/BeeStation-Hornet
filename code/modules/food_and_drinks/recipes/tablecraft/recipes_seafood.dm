
//SEAFOOD

/datum/crafting_recipe/food/cubancarp
	name = "Cuban carp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/cubancarp
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/fishandchips
	name = "Fish and chips"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishandchips
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/fishfingers
	name = "Fish fingers"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishfingers
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/sashimi
	name = "Sashimi"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/sashimi
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/vegetariansushiroll
	name ="Vegetarian sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/salad/boiledrice = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1
	)
	result = /obj/item/food/sushi_roll/vegetarian
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/spicyfiletsushiroll
	name ="Spicy filet sushi roll"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/salad/boiledrice = 1,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/onion = 1
	)
	result = /obj/item/food/sushi_roll/spicyfilet
	subcategory = CAT_SEAFOOD
