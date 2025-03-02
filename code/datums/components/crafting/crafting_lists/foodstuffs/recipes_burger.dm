
/// Burgers crafting

/datum/crafting_recipe/food/humanburger
	name = "Human burger"
	result = /obj/item/food/burger/human
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/patty/human = 1
	)
	parts = list(/obj/item/food/patty = 1)
	category = CAT_BURGER

/datum/crafting_recipe/food/burger
	name = "Burger"
	result = /obj/item/food/burger/plain
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/corgiburger
	name = "Corgi burger"
	result = /obj/item/food/burger/corgi
	reqs = list(
		/obj/item/food/patty/corgi = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/appendixburger
	name = "Appendix burger"
	result = /obj/item/food/burger/appendix
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/brainburger
	name = "Brain burger"
	result = /obj/item/food/burger/brain
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/xenoburger
	name = "Xeno burger"
	result = /obj/item/food/burger/xeno
	reqs = list(
		/obj/item/food/patty/xeno = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/bearger
	name = "Bearger"
	result = /obj/item/food/burger/bearger
	reqs = list(
		/obj/item/food/patty/bear = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/fishburger
	name = "Fish burger"
	result = /obj/item/food/burger/fish
	reqs = list(
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/tofuburger
	name = "Tofu burger"
	result = /obj/item/food/burger/tofu
	reqs = list(
		/obj/item/food/tofu = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/ghostburger
	name = "Ghost burger"
	result = /obj/item/food/burger/ghost
	reqs = list(
		/obj/item/ectoplasm = 1,
		/datum/reagent/consumable/sodiumchloride = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/clownburger
	name = "Clown burger"
	result = /obj/item/food/burger/clown
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/mimeburger
	name = "Mime burger"
	result = /obj/item/food/burger/mime
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/redburger
	name = "Red burger"
	result = /obj/item/food/burger/red
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/orangeburger
	name = "Orange burger"
	result = /obj/item/food/burger/orange
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/yellowburger
	name = "Yellow burger"
	result = /obj/item/food/burger/yellow
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/greenburger
	name = "Green burger"
	result = /obj/item/food/burger/green
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/blueburger
	name = "Blue burger"
	result = /obj/item/food/burger/blue
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/purpleburger
	name = "Purple burger"
	result = /obj/item/food/burger/purple
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/blackburger
	name = "Black burger"
	result = /obj/item/food/burger/black
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/black = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/whiteburger
	name = "White burger"
	result = /obj/item/food/burger/white
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/toy/crayon/white = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/spellburger
	name = "Spell burger"
	result = /obj/item/food/burger/spell
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/bigbiteburger
	name = "Big bite burger"
	result = /obj/item/food/burger/bigbite
	reqs = list(
		/obj/item/food/patty/plain = 3,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/superbiteburger
	name = "Super bite burger"
	result = /obj/item/food/burger/superbite
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/food/patty/plain = 5,
		/obj/item/food/grown/tomato = 4,
		/obj/item/food/cheese/wedge = 3,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/slimeburger
	name = "Jelly burger"
	result = /obj/item/food/burger/jelly/slime
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/jellyburger
	name = "Jelly burger"
	result = /obj/item/food/burger/jelly/cherry
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/fivealarmburger
	name = "Five alarm burger"
	result = /obj/item/food/burger/fivealarm
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/food/grown/ghost_chili = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/ratburger
	name = "Rat burger"
	result = /obj/item/food/burger/rat
	reqs = list(
		/obj/item/food/deadmouse = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/baseballburger
	name = "Home run baseball burger"
	result = /obj/item/food/burger/baseball
	reqs = list(
		/obj/item/melee/baseball_bat = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/baconburger
	name = "Bacon Burger"
	result = /obj/item/food/burger/baconburger
	reqs = list(
		/obj/item/food/meat/bacon = 3,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/empoweredburger
	name = "Empowered Burger"
	result = /obj/item/food/burger/empoweredburger
	reqs = list(
		/obj/item/stack/sheet/mineral/plasma = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/crabburger
	name = "Crab Burger"
	result = /obj/item/food/burger/crab
	reqs = list(
		/obj/item/food/meat/crab = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/cheeseburger
	name = "Cheese Burger"
	result = /obj/item/food/burger/cheese
	reqs = list(
		/obj/item/food/patty/plain = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/soylentburger
	name = "Soylent Burger"
	result = /obj/item/food/burger/soylent
	reqs = list(
		/obj/item/food/soylentgreen = 1, //two full meats worth.
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/ribburger
	name = "McRib"
	result = /obj/item/food/burger/rib
	reqs = list(
		/obj/item/food/bbqribs = 1, //The sauce is already included in the ribs
		/obj/item/food/onion_slice = 1, //feel free to remove if too burdensome.
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/mcguffin
	name = "McGuffin"
	result = /obj/item/food/burger/mcguffin
	reqs = list(
		/obj/item/food/friedegg = 1,
		/obj/item/food/meat/bacon = 2,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/chickenburger
	name = "Chicken Sandwich"
	result = /obj/item/food/burger/chicken
	reqs = list(
		/obj/item/food/patty/chicken = 1,
		/datum/reagent/consumable/mayonnaise = 5,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

/datum/crafting_recipe/food/crazyhamburger
	name = "Crazy Hamburger"
	result = /obj/item/food/burger/crazy
	reqs = list(
		/obj/item/food/patty/plain = 1, // we have no horse meat sadly
		/obj/item/food/grown/chili = 2,
		/datum/reagent/consumable/nutriment/fat/oil = 20,
		/obj/item/food/grown/nettle/death = 2, // closest thing to "grass of death"
		/obj/item/food/cheese/wedge = 4,
		/obj/item/food/bun = 1
	)
	category = CAT_BURGER

