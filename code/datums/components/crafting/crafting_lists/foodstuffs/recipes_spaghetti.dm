
/// Noodles Crafting

/datum/crafting_recipe/food/tomatopasta
	name = "Tomato pasta"
	result = /obj/item/food/spaghetti/pastatomato
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/grown/tomato = 2
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/copypasta
	name = "Copypasta"
	result = /obj/item/food/spaghetti/copypasta
	reqs = list(
		/obj/item/food/spaghetti/pastatomato = 2
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettimeatball
	name = "Spaghetti meatball"
	result = /obj/item/food/spaghetti/meatballspaghetti
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 2
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spesslaw
	name = "Spesslaw"
	result = /obj/item/food/spaghetti/spesslaw
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 4
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/beefnoodle
	name = "Beef noodle"
	result = /obj/item/food/spaghetti/beefnoodle
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/cabbage = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/chowmein
	name = "Chowmein"
	result = /obj/item/food/spaghetti/chowmein
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 2,
		/obj/item/food/grown/carrot = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/butternoodles
	name = "Butter Noodles"
	result = /obj/item/food/spaghetti/butternoodles
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/butter = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/kasespatzle
	name = "Käsespätzle"
	result = /obj/item/food/spaghetti/kasespatzle
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/eggyolk = 10,
		/obj/item/food/cheese/wedge = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettinapolitan
	name = "Spaghetti Napolitan"
	result = /obj/item/food/spaghetti/spaghettinapolitan
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/ketchup = 10, // >:(
		/obj/item/food/sausage = 1,
		/obj/item/food/grown/chili = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/lasagna
	name = "Lasagna"
	result = /obj/item/food/spaghetti/lasagna
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/spaghetti/raw = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/glassnoodles
	name = "Glass Noodles"
	result = /obj/item/food/spaghetti/glassnoodles
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/tofu = 1,
		/obj/item/stack/sheet/glass = 1
	)
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/carbonara
	name = "Spaghetti Carbonara"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/food/spaghetti/carbonara
	category = CAT_SPAGHETTI
