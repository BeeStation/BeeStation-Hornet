/* Glass sheets */
GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("directional window corner", /obj/structure/window/corner/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/fulltile/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("glass shard", /obj/item/shard, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND, category = CAT_MISC), \
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass, 1, 4, 20, category = CAT_TILES), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/glass)

/* Reinforced glass sheets */
GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe("windoor frame", /obj/structure/windoor_assembly, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	null, \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("directional reinforced window corner", /obj/structure/window/reinforced/corner/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/fulltile/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("reinforced glass tile", /obj/item/stack/tile/rglass, 1, 4, 20, category = CAT_TILES), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/rglass)

/* plasma glass */
GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/plasma/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("directional window corner", /obj/structure/window/plasma/corner/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/plasma/fulltile/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("plasma glass tile", /obj/item/stack/tile/glass/plasma, 1, 4, 20, category = CAT_TILES), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasmaglass)


/* Reinforced plasma glass */

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/plasma/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("directional reinforced window corner", /obj/structure/window/reinforced/plasma/corner/unanchored, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/plasma/fulltile/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("reinforced plasma glass tile", /obj/item/stack/tile/rglass/plasma, 1, 4, 20, category = CAT_TILES) \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasmarglass)

/* Titanium glass */

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe("shuttle window", /obj/structure/window/reinforced/shuttle/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION | CRAFT_IS_FULLTILE, category = CAT_WINDOWS) \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/titaniumglass)

/* Plastitanium glass */

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe("plastitanium window", /obj/structure/window/reinforced/plasma/plastitanium/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS) \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/plastitaniumglass)
