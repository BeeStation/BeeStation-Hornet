
// see code/module/crafting/table.dm

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////


/datum/crafting_recipe/food/humanburger
	name = "Human burger"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/meat/steak/plain/human = 1
	)
	parts = list(
		/obj/item/food/meat/steak/plain/human = 1
	)
	result = /obj/item/food/burger/human
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/burger
	name = "Burger"
	reqs = list(
			/obj/item/food/meat/steak/plain = 1,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/plain
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/corgiburger
	name = "Corgi burger"
	reqs = list(
			/obj/item/food/meat/slab/corgi = 1,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/corgi
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/appendixburger
	name = "Appendix burger"
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/appendix
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/brainburger
	name = "Brain burger"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/brain
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/xenoburger
	name = "Xeno burger"
	reqs = list(
		/obj/item/food/meat/steak/xeno = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/xeno
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/bearger
	name = "Bearger"
	reqs = list(
		/obj/item/food/meat/steak/bear = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/bearger
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/fishburger
	name = "Fish burger"
	reqs = list(
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/fish
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/tofuburger
	name = "Tofu burger"
	reqs = list(
		/obj/item/food/tofu = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/tofu
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/ghostburger
	name = "Ghost burger"
	reqs = list(
		/obj/item/ectoplasm = 1,
		/datum/reagent/consumable/sodiumchloride = 2,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/ghost
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/clownburger
	name = "Clown burger"
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/clown
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/mimeburger
	name = "Mime burger"
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/mime
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/redburger
	name = "Red burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/red
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/orangeburger
	name = "Orange burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/orange
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/yellowburger
	name = "Yellow burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/yellow
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/greenburger
	name = "Green burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/green
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/blueburger
	name = "Blue burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/blue
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/purpleburger
	name = "Purple burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/purple
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/blackburger
	name = "Black burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/black = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/black
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/whiteburger
	name = "White burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/toy/crayon/white = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/white
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/spellburger
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/spell
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/bigbiteburger
	name = "Big bite burger"
	reqs = list(
		/obj/item/food/meat/steak/plain = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/bigbite
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/superbiteburger
	name = "Super bite burger"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/food/meat/steak/plain = 5,
		/obj/item/food/grown/tomato = 4,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 3,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/bun = 1

	)
	result = /obj/item/food/burger/superbite
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/slimeburger
	name = "Jelly burger"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/jelly/slime
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/jellyburger
	name = "Jelly burger"
	reqs = list(
			/datum/reagent/consumable/cherryjelly = 5,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/jelly/cherry
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/fivealarmburger
	name = "Five alarm burger"
	reqs = list(
			/obj/item/food/meat/steak/plain = 1,
			/obj/item/food/grown/ghost_chili = 2,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/fivealarm
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/ratburger
	name = "Rat burger"
	reqs = list(
			/obj/item/reagent_containers/food/snacks/deadmouse = 1,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/rat
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/baseballburger
	name = "Home run baseball burger"
	reqs = list(
			/obj/item/melee/baseball_bat = 1,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/baseball
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/baconburger
	name = "Bacon Burger"
	reqs = list(
			/obj/item/food/meat/bacon = 3,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/baconburger
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/empoweredburger
	name = "Empowered Burger"
	reqs = list(
			/obj/item/stack/sheet/mineral/plasma = 2,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/empoweredburger
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/crabburger
	name = "Crab Burger"
	reqs = list(
			/obj/item/food/meat/crab = 2,
			/obj/item/food/bun = 1
	)

	result = /obj/item/food/burger/crab
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/cheeseburger
	name = "Cheese Burger"
	reqs = list(
			/obj/item/food/meat/steak/plain = 1,
			/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/cheese
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/soylentburger
	name = "Soylent Burger"
	reqs = list(
			/obj/item/food/soylentgreen = 1, //two full meats worth.
			/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/soylent
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/ribburger
	name = "McRib"
	reqs = list(
			/obj/item/food/bbqribs = 1, //The sauce is already included in the ribs
			/obj/item/food/onion_slice = 1, //feel free to remove if too burdensome.
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/rib
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/mcguffin
	name = "McGuffin"
	reqs = list(
			/obj/item/food/friedegg = 1,
			/obj/item/food/meat/bacon = 2,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/mcguffin
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/chickenburger
	name = "Chicken Sandwich"
	reqs = list(
			/obj/item/food/meat/steak/chicken = 1,
			/datum/reagent/consumable/mayonnaise = 5,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/chicken
	subcategory = CAT_BURGER

/datum/crafting_recipe/food/crazyhamburger
	name = "Crazy Hamburger"
	reqs = list(
			/obj/item/food/meat/steak/plain = 1,   // we have no horse meat sadly
			/obj/item/food/grown/chili = 2,
			/datum/reagent/consumable/cooking_oil = 20,
			/obj/item/food/grown/nettle/death = 2, // closest thing to "grass of death"
			/obj/item/reagent_containers/food/snacks/cheesewedge = 4,
			/obj/item/food/bun = 1
	)
	result = /obj/item/food/burger/crazy
	subcategory = CAT_BURGER

