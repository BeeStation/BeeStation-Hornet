/* Wood */

GLOBAL_LIST_INIT(wood_recipes, list ( \
	new/datum/stack_recipe("wooden sandals",						/obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile",						/obj/item/stack/tile/wood, 1, 4, 20), \
	new/datum/stack_recipe("wood table frame",						/obj/structure/table_frame/wood, 2, time = 1 SECONDS), \
	new/datum/stack_recipe("rifle stock",							/obj/item/weaponcrafting/stock, 10, time = 4 SECONDS), \
	new/datum/stack_recipe("rolling pin", 							/obj/item/kitchen/rollingpin, 2, time = 3 SECONDS), \
	new/datum/stack_recipe("wooden chair",							/obj/structure/chair/wood/, 3, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	new/datum/stack_recipe("winged wooden chair",					/obj/structure/chair/wood/wings, 3, one_per_turf = TRUE, on_floor = TRUE, time = 3 SECONDS), \
	new/datum/stack_recipe("wooden barricade",						/obj/structure/barricade/wooden, 5, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("wooden door",							/obj/structure/mineral_door/wood, 10, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	new/datum/stack_recipe("coffin",								/obj/structure/closet/crate/coffin, 5, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("book case",								/obj/structure/bookcase, 4, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("drying rack",							/obj/machinery/smartfridge/drying_rack, 10, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("dog bed",								/obj/structure/bed/dogbed, 10, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("dresser",								/obj/structure/dresser, 10, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("picture frame",							/obj/item/wallframe/picture, 1, time = 1 SECONDS),\
	new/datum/stack_recipe("painting frame",						/obj/item/wallframe/painting, 1, time = 1 SECONDS),\
	new/datum/stack_recipe("display case chassis",					/obj/structure/displaycase_chassis, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("easel",									/obj/structure/easel, 5, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("wooden buckler",						/obj/item/shield/riot/buckler, 20, time = 4 SECONDS), \
	new/datum/stack_recipe("apiary",								/obj/structure/beebox, 40, time = 5 SECONDS),\
	new/datum/stack_recipe("tiki mask",								/obj/item/clothing/mask/gas/tiki_mask, 2), \
	new/datum/stack_recipe("honey frame",							/obj/item/honey_frame, 5, time = 1 SECONDS),\
	new/datum/stack_recipe("ore box",								/obj/structure/ore_box, 4, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS),\
	new/datum/stack_recipe("wooden crate",							/obj/structure/closet/crate/wooden, 6, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS),\
	new/datum/stack_recipe("baseball bat",							/obj/item/melee/baseball_bat, 5, time = 1.5 SECONDS),\
	new/datum/stack_recipe("loom",									/obj/structure/loom, 10, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("mortar",								/obj/item/reagent_containers/glass/mortar, 3), \
	new/datum/stack_recipe("firebrand",								/obj/item/match/firebrand, 2, time = 10 SECONDS), \
	null, \
	new/datum/stack_recipe_list("pews", list(
		new /datum/stack_recipe("pew (middle)",						/obj/structure/chair/fancy/bench/pew, 3, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS),
		new /datum/stack_recipe("pew (left)",						/obj/structure/chair/fancy/bench/pew/left, 3, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS),
		new /datum/stack_recipe("pew (right)",						/obj/structure/chair/fancy/bench/pew/right, 3, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS)
		)),
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/wood)

/* Bamboo */

GLOBAL_LIST_INIT(bamboo_recipes, list ( \
	new/datum/stack_recipe("punji sticks trap",						/obj/structure/punji_sticks, 5, one_per_turf = TRUE, on_floor = TRUE, time = 3 SECONDS), \
	new/datum/stack_recipe("bamboo spear",							/obj/item/spear/bamboospear, 25, time = 9 SECONDS), \
	new/datum/stack_recipe("blow gun",								/obj/item/gun/syringe/blowgun, 10, time = 7 SECONDS), \
	new/datum/stack_recipe("crude syringe",							/obj/item/reagent_containers/syringe/crude, 5, time = 1 SECONDS), \
	null, \
	new/datum/stack_recipe("bamboo stool",							/obj/structure/chair/stool/bamboo, 2, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("bamboo mat piece",						/obj/item/stack/tile/bamboo, 1, 4, 20), \
	null, \
	new/datum/stack_recipe_list("bamboo benches", list(
		new /datum/stack_recipe("bamboo bench (middle)",			/obj/structure/chair/fancy/bench/bamboo, 3, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS),
		new /datum/stack_recipe("bamboo bench (left)",				/obj/structure/chair/fancy/bench/bamboo/left, 3, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS),
		new /datum/stack_recipe("bamboo bench (right)",				/obj/structure/chair/fancy/bench/bamboo/right, 3, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS)
		)),	\
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/bamboo)

/* Paper frames */

GLOBAL_LIST_INIT(paperframe_recipes, list(
	new /datum/stack_recipe("paper frame separator", /obj/structure/window/paperframe, 2, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new /datum/stack_recipe("paper frame door", /obj/structure/mineral_door/paperframe, 3, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS),	\
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/paperframes)
