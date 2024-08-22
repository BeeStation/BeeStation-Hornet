/obj/item/food/sushi_roll
	name = "Sushi Parent"
	desc = "You either spawned this erroneously, or a coder did. Either way, someone messed up."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	tastes = list("sushi" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/food/sushi_slice/slice_type /// type is spawned 4 at a time and replaces this cake when processed by cutting tool
	var/yield = 4 /// yield of sliced sushi, default is 4

/obj/item/food/sushi_roll/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE)

/obj/item/food/sushi_slice
	name = "Sushi Slice Parent"
	desc = "You either spawned this erroneously, or a coder did. Either way, someone messed up."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	tastes = list("sushi" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweed_sheet
	name = "seaweed sheet"
	desc = "A dried sheet of seaweed used for making sushi."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "seaweed_sheet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/sushi_roll/vegetarian
	name = "vegetarian sushi roll"
	desc = "A roll of simple vegetarian sushi with rice, carrots, and potatoes. Sliceable into pieces!"
	icon_state = "vegetariansushiroll"
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)
	slice_type = /obj/item/food/sushi_slice/vegetarian

/obj/item/food/sushi_slice/vegetarian
	name = "vegetarian sushi slice"
	desc = "A roll of simple vegetarian sushi with rice, carrots, and potatoes."
	icon_state = "vegetariansushislice"
	tastes = list("boiled rice" = 4, "carrots" = 2, "potato" = 2)

/obj/item/food/sushi_roll/spicyfilet
	name = "spicy filet sushi roll"
	desc = "A roll of tasty, spicy sushi made with fish and vegetables. Sliceable into pieces!"
	icon_state = "spicyfiletroll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = VEGETABLES | MEAT | GRAIN
	slice_type = /obj/item/food/sushi_slice/spicyfilet

/obj/item/food/sushi_slice/spicyfilet
	name = "spicy filet sushi slice"
	desc = "A roll of tasty, spicy sushi made with fish and vegetables."
	icon_state = "spicyfiletslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = VEGETABLES | MEAT | GRAIN
