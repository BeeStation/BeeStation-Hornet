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
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/food/sushi_slice/slice_type /// type is spawned 4 at a time and replaces this cake when processed by cutting tool
	var/yield = 4 /// yield of sliced sushi, default is 4

/obj/item/food/sushi_roll/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

/obj/item/food/sushi_slice
	name = "Sushi Slice Parent"
	desc = "You either spawned this erroneously, or a coder did. Either way, someone messed up."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	tastes = list("sushi" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweed_sheet
	name = "seaweed sheet"
	desc = "A dried sheet of seaweed used for making sushi. Use an ingredient on it to start making custom sushi!"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "seaweed_sheet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweed_sheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/sushi_roll/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

/obj/item/food/sushi_roll/empty //for custom sushi creation
	name = "sushi"
	desc = "A roll of customized sushi."
	icon_state = "vegetariansushiroll"
	tastes = list()
	foodtypes = NONE
	slice_type = /obj/item/food/sushi_slice/empty

/obj/item/food/sushi_slice/empty
	name = "sushi slice"
	desc = "A slice of customized sushi."
	icon_state = "vegetariansushislice"
	tastes = list()
	foodtypes = NONE

/obj/item/food/sushi_roll/vegetarian
	name = "vegetarian sushi roll"
	desc = "A roll of simple vegetarian sushi with rice, carrots, and cabbage. Sliceable into pieces!"
	icon_state = "vegetariansushiroll"
	tastes = list("boiled rice" = 4, "carrots" = 2, "cabbage" = 2)
	foodtypes = VEGETABLES
	slice_type = /obj/item/food/sushi_slice/vegetarian

/obj/item/food/sushi_slice/vegetarian
	name = "vegetarian sushi slice"
	desc = "A roll of simple vegetarian sushi with rice, carrots, and cabbage."
	icon_state = "vegetariansushislice"
	foodtypes = VEGETABLES
	tastes = list("boiled rice" = 4, "carrots" = 2, "cabbage" = 2)

/obj/item/food/sushi_roll/spicyfilet
	name = "spicy filet sushi roll"
	desc = "A roll of tasty, spicy sushi made with fish and vegetables. Sliceable into pieces!"
	icon_state = "spicyfiletroll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = MEAT
	slice_type = /obj/item/food/sushi_slice/spicyfilet

/obj/item/food/sushi_slice/spicyfilet
	name = "spicy filet sushi slice"
	desc = "A roll of tasty, spicy sushi made with fish and vegetables."
	icon_state = "spicyfiletslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	tastes = list("boiled rice" = 4, "fish" = 2, "spicyness" = 2)
	foodtypes = MEAT

/obj/item/food/sushi_roll/futomaki
	name = "futomaki sushi roll"
	desc = "A roll of futomaki sushi, made of boiled egg, fish, and cabbage. Sliceable"
	icon_state = "futomaki_sushi_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("boiled rice" = 4, "fish" = 5, "egg" = 3, "dried seaweed" = 2)
	foodtypes = MEAT
	slice_type = /obj/item/food/sushi_slice/futomaki

/obj/item/food/sushi_slice/futomaki
	name = "futomaki sushi slice"
	desc = "A slice of futomaki sushi, made of boiled egg, fish, and cabbage."
	icon_state = "futomaki_sushi_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("boiled rice" = 4, "fish" = 5, "egg" = 3, "dried seaweed" = 2, "cabbage" = 2)
	foodtypes = MEAT

/obj/item/food/sushi_roll/philadelphia
	name = "Philadelphia sushi roll"
	desc = "A roll of Philadelphia sushi, made of cheese, fish, and cabbage. Sliceable"
	icon_state = "philadelphia_sushi_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("boiled rice" = 4, "fish" = 5, "creamy cheese" = 3, "dried seaweed" = 2, "cabbage" = 2)
	foodtypes = MEAT | DAIRY
	slice_type = /obj/item/food/sushi_slice/philadelphia

/obj/item/food/sushi_slice/philadelphia
	name = "Philadelphia sushi slice"
	desc = "A roll of Philadelphia sushi, made of cheese, fish, and cabbage."
	icon_state = "philadelphia_sushi_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("boiled rice" = 4, "fish" = 5, "creamy cheese" = 3, "dried seaweed" = 2, "cabbage" = 2)
	foodtypes = MEAT | DAIRY

/obj/item/food/nigiri_sushi
	name = "nigiri sushi"
	desc = "A simple nigiri of fish atop a packed rice ball with a seaweed wrapping and a side of soy sauce."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "nigiri_sushi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
		)
	tastes = list("boiled rice" = 4, "fish filet" = 2, "soy sauce" = 2)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL

