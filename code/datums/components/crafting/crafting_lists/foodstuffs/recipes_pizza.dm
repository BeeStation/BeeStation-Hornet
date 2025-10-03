
/// Pizza Crafting

/datum/crafting_recipe/food/margheritapizza
	result = /obj/item/food/pizza/margherita/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/cheese/wedge = 4,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	result = /obj/item/food/pizza/meat/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 4,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/arnold
	result = /obj/item/food/pizza/arnold/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	result = /obj/item/food/pizza/mushroom/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/mushroom = 5
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	result = /obj/item/food/pizza/vegetable/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	result = /obj/item/food/pizza/donkpocket/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/donkpocket = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	result = /obj/item/food/pizza/dank/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	result = /obj/item/food/pizza/sassysage/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/raw_meatball = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/pineapplepizza ///AGAINST my will, i say that this recipe is missing ham to be the prime of the culinary horrors from Soviet Canuckistan...
	result = /obj/item/food/pizza/pineapple/raw
	reqs = list(
		/obj/item/food/flatdough = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/pineappleslice = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_PIZZA

/datum/crafting_recipe/food/antspizza
	reqs = list(
		/obj/item/food/pizzaslice/margherita = 1,
		/datum/reagent/ants = 4
	)
	result = /obj/item/food/pizzaslice/ants
	category = CAT_PIZZA
