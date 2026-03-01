/* Human hide */

GLOBAL_LIST_INIT(human_recipes, list( \
	new/datum/stack_recipe("bloated human costume", /obj/item/clothing/suit/hooded/bloated_human, 5, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/* Corgi hide */

GLOBAL_LIST_INIT(corgi_recipes, list ( \
	new/datum/stack_recipe("corgi costume", /obj/item/clothing/suit/hooded/ian_costume, 3, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/* Gondola hide */

GLOBAL_LIST_INIT(gondola_recipes, list ( \
	new/datum/stack_recipe("gondola mask", /obj/item/clothing/mask/gondola, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("gondola suit", /obj/item/clothing/under/costume/gondola, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/* Monkey hide */

GLOBAL_LIST_INIT(monkey_recipes, list ( \
	new/datum/stack_recipe("monkey mask", /obj/item/clothing/mask/gas/monkeymask, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("monkey suit", /obj/item/clothing/suit/costume/monkeysuit, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))

/* Xeno hide */

GLOBAL_LIST_INIT(xeno_recipes, list ( \
	new/datum/stack_recipe("alien helmet", /obj/item/clothing/head/costume/xenos, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("alien suit", /obj/item/clothing/suit/costume/xenos, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	))
