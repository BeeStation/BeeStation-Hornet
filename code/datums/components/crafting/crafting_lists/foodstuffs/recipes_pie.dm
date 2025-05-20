
/// Pies Crafting

/datum/crafting_recipe/food/bananacreampie
	name = "Banana cream pie"
	result = /obj/item/food/pie/cream
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/banana = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/meatpie
	name = "Meat pie"
	result = /obj/item/food/pie/meatpie
	reqs = list(
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/meat/steak/plain = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/tofupie
	name = "Tofu pie"
	result = /obj/item/food/pie/tofupie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/tofu = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/xenopie
	name = "Xeno pie"
	result = /obj/item/food/pie/xemeatpie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/cherrypie
	name = "Cherry pie"
	result = /obj/item/food/pie/cherrypie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/cherries = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/berryclafoutis
	name = "Berry clafoutis"
	result = /obj/item/food/pie/berryclafoutis
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/berries = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/bearypie
	name = "Beary Pie"
	result = /obj/item/food/pie/bearypie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/meat/steak/bear = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/amanitapie
	name = "Amanita pie"
	result = /obj/item/food/pie/amanita_pie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/mushroom/amanita = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/plumppie
	name = "Plump pie"
	result = /obj/item/food/pie/plump_pie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/applepie
	name = "Apple pie"
	result = /obj/item/food/pie/applepie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/apple = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/pumpkinpie
	name = "Pumpkin pie"
	result = /obj/item/food/pie/pumpkinpie
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/pumpkin = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/goldenappletart
	name = "Golden apple tart"
	result = /obj/item/food/pie/appletart
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/apple/gold = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/grapetart
	name = "Grape tart"
	reqs = list(
			/datum/reagent/consumable/milk = 5,
			/datum/reagent/consumable/sugar = 5,
			/obj/item/food/pie/plain = 1,
			/obj/item/food/grown/grapes = 3
			)
	result = /obj/item/food/pie/grapetart
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/grapes = 3
	)
	category = CAT_PIE

/datum/crafting_recipe/food/mimetart
	name = "Mime tart"
	reqs = list(
			/datum/reagent/consumable/milk = 5,
			/datum/reagent/consumable/sugar = 5,
			/obj/item/food/pie/plain = 1,
			/datum/reagent/consumable/nothing = 5
			)
	result = /obj/item/food/pie/mimetart
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/datum/reagent/consumable/nothing = 5
	)
	category = CAT_PIE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/berrytart
	name = "Berry tart"
	reqs = list(
			/datum/reagent/consumable/milk = 5,
			/datum/reagent/consumable/sugar = 5,
			/obj/item/food/pie/plain = 1,
			/obj/item/food/grown/berries = 3
			)
	result = /obj/item/food/pie/berrytart
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/berries = 3
		)
	category = CAT_PIE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/cocoalavatart
	name = "Chocolate Lava tart"
	reqs = list(
			/datum/reagent/consumable/milk = 5,
			/datum/reagent/consumable/sugar = 5,
			/obj/item/food/pie/plain = 1,
			/obj/item/food/chocolatebar = 3,
			/obj/item/slime_extract = 1 //The reason you dont know how to make it!
			)
	result = /obj/item/food/pie/cocoalavatart
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/chocolatebar = 3,
		/obj/item/slime_extract = 1 //The reason you dont know how to make it!
	)
	category = CAT_PIE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/blumpkinpie
	name = "Blumpkin pie"
	result = /obj/item/food/pie/blumpkinpie
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/blumpkin = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/dulcedebatata
	name = "Dulce de batata"
	result = /obj/item/food/pie/dulcedebatata
	reqs = list(
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/water = 5,
		/obj/item/food/grown/potato/sweet = 2
	)
	category = CAT_PIE

/datum/crafting_recipe/food/frostypie
	name = "Frosty pie"
	result = /obj/item/food/pie/frostypie
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	category = CAT_PIE

/datum/crafting_recipe/food/baklava
	name = "Baklava pie"
	result = /obj/item/food/pie/baklava
	reqs = list(
		/obj/item/food/butter = 2,
		/obj/item/food/tortilla = 4,	//Layers
		/obj/item/seeds/wheat/oat = 4
	)
	category = CAT_PIE
