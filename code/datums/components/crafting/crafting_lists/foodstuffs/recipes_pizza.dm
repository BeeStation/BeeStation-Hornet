
/// Pizza Crafting

/datum/crafting_recipe/food/margheritapizza
	name = "Margherita pizza"
	result = /obj/item/food/pizza/margherita
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/cheese/wedge = 4,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	name = "Meat pizza"
	result = /obj/item/food/pizza/meat
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 4,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/arnold
	name = "Arnold pizza"
	result = /obj/item/food/pizza/arnold
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	name = "Mushroom pizza"
	result = /obj/item/food/pizza/mushroom
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/mushroom = 5
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	name = "Vegetable pizza"
	result = /obj/item/food/pizza/vegetable
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	name = "Donkpocket pizza"
	result = /obj/item/food/pizza/donkpocket
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/donkpocket/warm = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	name = "Dank pizza"
	result = /obj/item/food/pizza/dank
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/grown/ambrosia/vulgaris = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	name = "Sassysage pizza"
	result = /obj/item/food/pizza/sassysage
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meatball = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/pineapplepizza ///AGAINST my will, i say that this recipe is missing ham to be the prime of the culinary horrors from canada...
	name = "Hawaiian pizza"
	result = /obj/item/food/pizza/pineapple
	reqs = list(
		/obj/item/food/pizzabread = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/pineappleslice = 3,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PIZZA
