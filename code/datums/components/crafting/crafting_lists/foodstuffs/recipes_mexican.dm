
/// Mexican Foodstuff crafting

/datum/crafting_recipe/food/burrito
	name ="Burrito"
	result = /obj/item/food/burrito
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 2
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/cheesyburrito
	name ="Cheesy burrito"
	result = /obj/item/food/cheesyburrito
	reqs = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/carneburrito
	name ="Carne de asada burrito"
	result = /obj/item/food/carneburrito
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/soybeans = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/fuegoburrito
	name ="Fuego plasma burrito"
	result = /obj/item/food/fuegoburrito
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/ghost_chili = 2,
		/obj/item/food/grown/soybeans = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/nachos
	name ="Nachos"
	result = /obj/item/food/nachos
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/tortilla = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/cheesynachos
	name ="Cheesy nachos"
	result = /obj/item/food/cheesynachos
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/tortilla = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/cubannachos
	name ="Cuban nachos"
	result = /obj/item/food/cubannachos
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 1
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/taco
	name ="Classic Taco"
	result = /obj/item/food/taco
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/tacoplain
	name ="Plain Taco"
	result = /obj/item/food/taco/plain
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/enchiladas
	name = "Enchiladas"
	result = /obj/item/food/enchiladas
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 2
	)
	category = CAT_MEXICAN

/datum/crafting_recipe/food/stuffedlegion
	name = "Stuffed legion"
	time = 4 SECONDS
	result = /obj/item/food/stuffedlegion
	reqs = list(
		/obj/item/food/meat/steak/goliath = 1,
		/obj/item/organ/regenerative_core/legion = 1,
		/datum/reagent/consumable/ketchup = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	category = CAT_MEXICAN
