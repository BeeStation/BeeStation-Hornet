
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/crafting_recipe/food/tomatopasta
	name = "Tomato pasta"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2
	)
	result = /obj/item/food/spaghetti/pastatomato
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/food/spaghetti/pastatomato = 2
	)
	result = /obj/item/food/spaghetti/copypasta
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettimeatball
	name = "Spaghetti meatball"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 2
	)
	result = /obj/item/food/spaghetti/meatballspaghetti
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 4
	)
	result = /obj/item/food/spaghetti/spesslaw
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/beefnoodle
	name = "Beef noodle"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1
	)
	result = /obj/item/food/spaghetti/beefnoodle
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/chowmein
	name = "Chowmein"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 2,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1
	)
	result = /obj/item/food/spaghetti/chowmein
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/butternoodles
	name = "Butter Noodles"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/butter = 1
	)
	result = /obj/item/food/spaghetti/butternoodles
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/kasespatzle
	name = "Käsespätzle"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/eggyolk = 10,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/food/spaghetti/kasespatzle
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettinapolitan
	name = "Spaghetti Napolitan"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/ketchup = 10,
		/obj/item/reagent_containers/food/snacks/sausage = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1
	)
	result = /obj/item/food/spaghetti/spaghettinapolitan
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/lasagna
	name = "Lasagna"
	reqs = list(
		/obj/item/food/spaghetti = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/food/spaghetti/lasagna
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/glassnoodles
	name = "Glass Noodles"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 1,
		/obj/item/stack/sheet/glass = 1
	)
	result = /obj/item/food/spaghetti/glassnoodles
	subcategory = CAT_SPAGHETTI
