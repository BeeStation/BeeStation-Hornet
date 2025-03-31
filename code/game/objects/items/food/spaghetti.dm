/obj/item/food/spaghetti
	name = "Spaghetti Parent"
	desc = "You either spawned this erroneously, or a coder did. Either way, someone messed up."
	icon = 'icons/obj/food/spaghetti.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/Initialize(mapload)
	. = ..()
	if(!microwaved_type) // This isn't cooked, why would you put uncooked spaghetti in your pocket?
		var/list/display_message = list(
			span_notice("Something wet falls out of their pocket and hits the ground. Is that... [name]?"),
			span_warning("Oh shit! All your pocket [name] fell out!"))
		AddComponent(/datum/component/spill, display_message, 'sound/effects/splat.ogg')

/obj/item/food/spaghetti/raw
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	tastes = list("pasta" = 1)
	microwaved_type = /obj/item/food/spaghetti/boiledspaghetti
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/spaghetti/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/spaghetti/boiledspaghetti, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/spaghetti/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon_state = "spaghettiboiled"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/spaghetti/boiledspaghetti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_SCATTER, max_ingredients = 6)

/obj/item/food/spaghetti/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/tomatojuice = 20, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pasta" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pasta" = 1, "meat" = 1)
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon_state = "chowmein"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("noodle" = 1, "tomato" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/spaghetti/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon_state = "beefnoodle"
	trash_type = /obj/item/reagent_containers/cup/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/liquidgibs = 3)
	tastes = list("noodle" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/spaghetti/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon_state = "butternoodles"
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("noodle" = 1, "butter" = 1)
	foodtypes = GRAIN | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/kasespatzle
	name = "käsespätzle"
	desc = "A special kind of pasta made with eggs, served with tasty cheese."
	icon_state = "kasespatzle"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "cheese" = 1, "egg" = 1)
	foodtypes = GRAIN | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/spaghetti/spaghettinapolitan
	name = "spaghetti napolitan"
	desc = "The only excuse to ever put ketchup into your spaghetti."
	icon_state = "spaghettinapolitan"
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pasta" = 1, "ketchup" = 1, "sausage" = 1)
	foodtypes = GRAIN | MEAT | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spaghetti/lasagna
	name = "lasagna"
	desc = "Somewhere, in some different universe, a cat is smoking your pipe."
	icon_state = "lasagna"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1, "cheese" = 1, "mondays" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/spaghetti/glassnoodles
	name = "glass noodles"
	desc = "Noodles so transparent, you can see through them!"
	icon_state = "glassnoodles"
	food_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("noodle" = 1, "sweetness" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/spaghetti/carbonara
	name = "spaghetti carbonara"
	desc = "Silky eggs, crispy pork, cheesy bliss. Mamma mia!"
	icon_state = "carbonara"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("spaghetti" = 1, "parmigiano reggiano" = 1,  "guanciale" = 1)
	foodtypes = GRAIN | MEAT | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_4
	crafted_food_buff = /datum/status_effect/food/speech/italian
