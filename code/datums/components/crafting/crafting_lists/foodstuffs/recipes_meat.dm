
/// Meat stuff crafting

/datum/crafting_recipe/food/humankebab
	name = "Human kebab"
	result = /obj/item/food/kebab/human
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak/plain/human = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/kebab
	name = "Kebab"
	result = /obj/item/food/kebab/monkey
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/tofukebab
	name = "Tofu kebab"
	result = /obj/item/food/kebab/tofu
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/tofu = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/tailkebab
	name = "Lizard tail kebab"
	result = /obj/item/food/kebab/tail
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/organ/tail/lizard = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/fiestaskewer
	name = "Fiesta Skewer"
	result = /obj/item/food/kebab/fiesta
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_MEAT

////////////////////////////////////////////////MR SPIDER////////////////////////////////////////////////

/// Misc. Meats crafting

/datum/crafting_recipe/food/spidereggsham
	name = "Spider eggs ham"
	result = /obj/item/food/spidereggsham
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/meat/cutlet/spider = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/cornedbeef
	name = "Corned beef"
	result = /obj/item/food/cornedbeef
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/grown/cabbage = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/bearsteak
	name = "Filet migrawr"
	result = /obj/item/food/bearsteak
	tool_paths = list(/obj/item/lighter)
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/food/meat/steak/bear = 1,
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/stewedsoymeat
	name = "Stewed soymeat"
	result = /obj/item/food/stewedsoymeat
	reqs = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/sausage
	name = "Sausage"
	result = /obj/item/food/raw_sausage
	reqs = list(
		/obj/item/food/raw_meatball = 1,
		/obj/item/food/meat/rawcutlet = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/nugget
	name = "Chicken nugget"
	result = /obj/item/food/nugget
	reqs = list(
		/obj/item/food/meat/cutlet = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/rawkhinkali
	name = "Raw Khinkali"
	result =  /obj/item/food/rawkhinkali
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/meatball = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/meatbun
	name = "Meat bun"
	result = /obj/item/food/meatbun
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/cabbage = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/pigblanket
	name = "Pig in a Blanket"
	result = /obj/item/food/pigblanket
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/meat/cutlet = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/meatbun
	name = "Meat bun"
	result = /obj/item/food/meatbun
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/cabbage = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/ratkebab
	name = "Rat Kebab"
	result = /obj/item/food/kebab/rat
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 1
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/doubleratkebab
	name = "Double Rat Kebab"
	result = /obj/item/food/kebab/rat/double
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/ricepork
	name = "Rice and Pork"
	result = /obj/item/food/salad/ricepork
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/meat/cutlet = 2
	)
	category = CAT_MEAT


/datum/crafting_recipe/food/ashsteak
	name = "Ashflaked Steak"
	result = /obj/item/food/meat/steak/ashflake
	reqs = list(
		/obj/item/food/meat/steak/goliath = 1,
		/obj/item/food/grown/ash_flora/cactus_fruit = 1,
		/obj/item/food/grown/ash_flora/mushroom_leaf = 1
	)
	category = CAT_MEAT


/datum/crafting_recipe/food/ribs
	name = "BBQ Ribs"
	result = /obj/item/food/bbqribs
	reqs = list(
		/datum/reagent/consumable/bbqsauce = 5,
		/obj/item/food/meat/steak/plain = 2,
		/obj/item/stack/rods = 2
	)
	category = CAT_MEAT

/datum/crafting_recipe/food/meatclown
	name = "Meat Clown"
	result = /obj/item/food/meatclown
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/food/grown/banana = 1
	)
	category = CAT_MEAT
