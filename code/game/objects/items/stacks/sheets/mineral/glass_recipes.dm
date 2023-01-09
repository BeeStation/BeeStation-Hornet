/* Glass sheets */
GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe("glass shard", /obj/item/shard, on_floor = FALSE), \
	new/datum/stack_recipe("directional window", /obj/structure/window/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/glass)

/obj/item/stack/sheet/glass/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500


/* Reinforced glass sheets */
GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe("windoor frame", /obj/structure/windoor_assembly, 5, on_floor = TRUE, window_checks = TRUE), \
	null, \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("window firelock frame", /obj/structure/firelock_frame/window, 2, one_per_turf = TRUE, on_floor = TRUE, window_checks = FALSE, time = 5 SECONDS) \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/rglass)

/* plasma glass */
GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/plasma/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/plasma/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasmaglass)


/* Reinforced plasma glass */

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/plasma/reinforced/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/plasma/reinforced/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasmarglass)

/* Titanium glass */

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe("shuttle window", /obj/structure/window/shuttle/unanchored, 2, on_floor = TRUE, window_checks = TRUE)
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/titaniumglass)

/* Plastitanium glass */

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe("plastitanium window", /obj/structure/window/plastitanium/unanchored, 2, on_floor = TRUE, window_checks = TRUE)
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/plastitaniumglass)
