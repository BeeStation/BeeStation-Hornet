/obj/item/food/spaghetti
	name = "Spaghetti Parent"
	desc = "You either spawned this erroneously, or a coder did. Either way, someone messed up."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "ERROR"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtypes = GRAIN

/obj/item/food/spaghetti/Initialize()
	. = ..()
	if(!microwaved_type) // This isn't cooked, why would you put uncooked spaghetti in your pocket?
		var/list/display_message = list(
			"<span class='notice'>Something wet falls out of their pocket and hits the ground. Is that... [name]?</span>",
			"<span class='warning'>Oh shit! All your pocket [name] fell out!</span>")
		AddComponent(/datum/component/spill, display_message, 'sound/effects/splat.ogg')

/obj/item/food/spaghetti/raw
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	tastes = list("pasta" = 1)
	microwaved_type = /obj/item/food/spaghetti/boiledspaghetti

/obj/item/food/spaghetti/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon_state = "spaghettiboiled"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	microwaved_type = null

/obj/item/food/spaghetti/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash_type = /obj/item/trash/plate
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	microwaved_type = null
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/spaghetti/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash_type = /obj/item/trash/plate
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/tomatojuice = 20, /datum/reagent/consumable/nutriment/vitamin = 8)
	microwaved_type = null
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/spaghetti/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	microwaved_type = null
	tastes = list("pasta" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/spaghetti/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	microwaved_type = null
	tastes = list("pasta" = 1, "meat" = 1)

/obj/item/food/spaghetti/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon_state = "chowmein"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	microwaved_type = null
	tastes = list("noodle" = 1, "tomato" = 1)

/obj/item/food/spaghetti/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon_state = "beefnoodle"
	trash_type = /obj/item/reagent_containers/glass/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/liquidgibs = 3)
	microwaved_type = null
	tastes = list("noodle" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/spaghetti/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon_state = "butternoodles"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	microwaved_type = null
	tastes = list("noodle" = 1, "butter" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/spaghetti/kasespatzle
	name = "käsespätzle"
	desc = "A special kind of pasta made with eggs, served with tasty cheese."
	icon_state = "kasespatzle"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	microwaved_type = null
	tastes = list("pasta" = 1, "cheese" = 1, "egg" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/spaghetti/spaghettinapolitan
	name = "spaghetti napolitan"
	desc = "The only excuse to ever put ketchup into your spaghetti."
	icon_state = "spaghettinapolitan"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 6)
	microwaved_type = null
	tastes = list("pasta" = 1, "ketchup" = 1, "sausage" = 1)
	foodtypes = GRAIN | MEAT | VEGETABLES

/obj/item/food/spaghetti/lasagna
	name = "lasagna"
	desc = "Somewhere, in some different universe, a cat is smoking your pipe."
	icon_state = "lasagna"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	microwaved_type = null
	tastes = list("pasta" = 1, "tomato" = 1, "cheese" = 1, "mondays" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | MEAT

/obj/item/food/spaghetti/glassnoodles
	name = "glass noodles"
	desc = "Noodles so transparent, you can see through them!"
	icon_state = "glassnoodles"
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 6)
	microwaved_type = null
	tastes = list("noodle" = 1, "sweetness" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
