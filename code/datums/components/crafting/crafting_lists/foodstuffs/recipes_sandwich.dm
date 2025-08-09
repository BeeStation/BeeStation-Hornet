
/// Sandwiches Crafting

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	result = /obj/item/food/sandwich
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/steak = 1, //that's one hell of a sandwich if it needs a whole steak
		/obj/item/food/cheese/wedge = 1
	)
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cheese_sandwich
	name = "Cheese sandwich"
	result = /obj/item/food/cheese_sandwich
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/cheese/wedge = 2
	)
	category = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly sandwich"
	result = /obj/item/food/jellysandwich/slime
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly sandwich"
	result = /obj/item/food/jellysandwich/cherry
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	category = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a sandwich"
	result = /obj/item/food/notasandwich
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	category = CAT_SANDWICH

/datum/crafting_recipe/food/hotdog
	name = "Hot dog"
	result = /obj/item/food/hotdog
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1
	)
	category = CAT_SANDWICH
