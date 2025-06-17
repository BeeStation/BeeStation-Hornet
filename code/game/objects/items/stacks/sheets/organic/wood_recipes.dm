/* Wood */

GLOBAL_LIST_INIT(wood_recipes, list ( \
	new/datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES), \
	new/datum/stack_recipe("wood table frame", /obj/structure/table_frame/wood, 2, time = 1 SECONDS, crafting_flags = NONE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("rifle stock", /obj/item/weaponcrafting/stock, 10, time = 4 SECONDS, crafting_flags = NONE, category = CAT_TOOLS), \
	new/datum/stack_recipe("rolling pin", /obj/item/kitchen/rollingpin, 2, time = 3 SECONDS, crafting_flags = NONE, category = CAT_TOOLS), \
	new/datum/stack_recipe("wooden chair", /obj/structure/chair/wood/, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("winged wooden chair", /obj/structure/chair/wood/wings, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_DOORS), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/crate/coffin, 5, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("book case", /obj/structure/bookcase, 4, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("drying rack", /obj/machinery/smartfridge/drying_rack, 10, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS), \
	new/datum/stack_recipe("wooden barrel", /obj/structure/fermenting_barrel, 8, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("dog bed", /obj/structure/bed/dogbed, 10, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("dresser", /obj/structure/dresser, 10, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("picture frame", /obj/item/wallframe/picture, 1, time = 1 SECONDS, crafting_flags = NONE, category = CAT_ENTERTAINMENT),\
	new/datum/stack_recipe("painting frame", /obj/item/wallframe/painting, 1, time = 1 SECONDS, crafting_flags = NONE, category = CAT_ENTERTAINMENT),\
	new/datum/stack_recipe("display case chassis", /obj/structure/displaycase_chassis, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("wooden buckler", /obj/item/shield/riot/buckler, 20, time = 4 SECONDS, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("apiary", /obj/structure/beebox, 40, time = 5 SECONDS, crafting_flags = NONE, category = CAT_TOOLS),\
	new/datum/stack_recipe("tiki mask", /obj/item/clothing/mask/gas/tiki_mask, 2, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("honey frame", /obj/item/honey_frame, 5, time = 1 SECONDS, crafting_flags = NONE, category = CAT_TOOLS),\
	new/datum/stack_recipe("ore box", /obj/structure/ore_box, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_CONTAINERS),\
	new/datum/stack_recipe("wooden crate", /obj/structure/closet/crate/wooden, 6, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),\
	new/datum/stack_recipe("baseball bat", /obj/item/melee/baseball_bat, 5, time = 1.5 SECONDS, crafting_flags = NONE, category = CAT_WEAPON_MELEE),\
	new/datum/stack_recipe("loom", /obj/structure/loom, 10, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS), \
	new/datum/stack_recipe("mortar", /obj/item/reagent_containers/cup/mortar, 3, crafting_flags = NONE, category = CAT_CHEMISTRY), \
	new/datum/stack_recipe("firebrand", /obj/item/match/firebrand, 2, time = 10 SECONDS, crafting_flags = NONE, category = CAT_TOOLS), \
	new/datum/stack_recipe("bonfire", /obj/structure/bonfire, 10, time = 6 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS), \
	new/datum/stack_recipe("easel", /obj/structure/easel, 5, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_ENTERTAINMENT), \
	null, \
	new/datum/stack_recipe_list("pews", list(
		new /datum/stack_recipe("pew (middle)", /obj/structure/chair/fancy/bench/pew, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
		new /datum/stack_recipe("pew (left)", /obj/structure/chair/fancy/bench/pew/left, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
		new /datum/stack_recipe("pew (right)", /obj/structure/chair/fancy/bench/pew/right, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE)
		)),
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/wood)

/* Bamboo */

GLOBAL_LIST_INIT(bamboo_recipes, list ( \
	new/datum/stack_recipe("punji sticks trap", /obj/structure/punji_sticks, 5, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("bamboo spear", /obj/item/spear/bamboospear, 25, time = 9 SECONDS, crafting_flags = NONE, category = CAT_WEAPON_MELEE), \
	new/datum/stack_recipe("blow gun", /obj/item/gun/syringe/blowgun, 10, time = 7 SECONDS, crafting_flags = NONE, category = CAT_WEAPON_RANGED), \
	new/datum/stack_recipe("crude syringe", /obj/item/reagent_containers/syringe/crude, 5, time = 1 SECONDS, crafting_flags = NONE, category = CAT_CHEMISTRY), \
	new/datum/stack_recipe("rice hat", /obj/item/clothing/head/costume/rice_hat, 10, time = 7 SECONDS, crafting_flags = NONE, category = CAT_CLOTHING), \
	null, \
	new/datum/stack_recipe("bamboo stool", /obj/structure/chair/stool/bamboo, 2, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE), \
	new/datum/stack_recipe("bamboo mat piece", /obj/item/stack/tile/bamboo, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES), \
	null, \
	new/datum/stack_recipe_list("bamboo benches", list(
		new /datum/stack_recipe("bamboo bench (middle)", /obj/structure/chair/fancy/bench/bamboo, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
		new /datum/stack_recipe("bamboo bench (left)", /obj/structure/chair/fancy/bench/bamboo/left, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
		new /datum/stack_recipe("bamboo bench (right)", /obj/structure/chair/fancy/bench/bamboo/right, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE)
		)),	\
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/bamboo)

/* Paper frames */

GLOBAL_LIST_INIT(paperframe_recipes, list(
	new /datum/stack_recipe("paper frame separator", /obj/structure/window/paperframe, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, time = 1 SECONDS), \
	new /datum/stack_recipe("paper frame door", /obj/structure/mineral_door/paperframe, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1 SECONDS )
))

STACKSIZE_MACRO(/obj/item/stack/sheet/paperframes)
