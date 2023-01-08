/* Glass sheets */
GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe("glass shard", /obj/item/shard, on_floor = FALSE), \
	new/datum/stack_recipe("directional window", /obj/structure/window/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/twenty
	amount = 20

/obj/item/stack/sheet/glass/ten
	amount = 10

/obj/item/stack/sheet/glass/five
	amount = 5

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

/obj/item/stack/sheet/rglass/fifty
	amount = 50

/obj/item/stack/sheet/rglass/twenty
	amount = 20

/obj/item/stack/sheet/rglass/ten
	amount = 10

/obj/item/stack/sheet/rglass/five
	amount = 5

/* plasma glass */
GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/plasma/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/plasma/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))


/obj/item/stack/sheet/plasmaglass/fifty
	amount = 50

/obj/item/stack/sheet/plasmaglass/twenty
	amount = 20

/obj/item/stack/sheet/plasmaglass/ten
	amount = 10

/obj/item/stack/sheet/plasmaglass/five
	amount = 5


/* Reinforced plasma glass */

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/plasma/reinforced/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/plasma/reinforced/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/plasmarglass/fifty
	amount = 50

/obj/item/stack/sheet/plasmarglass/twenty
	amount = 20

/obj/item/stack/sheet/plasmarglass/ten
	amount = 10

/obj/item/stack/sheet/plasmarglass/five
	amount = 5

/* Titanium glass */

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe("shuttle window", /obj/structure/window/shuttle/unanchored, 2, on_floor = TRUE, window_checks = TRUE)
	))

/obj/item/stack/sheet/titaniumglass/fifty
	amount = 50

/obj/item/stack/sheet/titaniumglass/twenty
	amount = 20

/obj/item/stack/sheet/titaniumglass/ten
	amount = 10

/obj/item/stack/sheet/titaniumglass/five
	amount = 5


/* Plastitanium glass */

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe("plastitanium window", /obj/structure/window/plastitanium/unanchored, 2, on_floor = TRUE, window_checks = TRUE)
	))

/obj/item/stack/sheet/plastitaniumglass/fifty
	amount = 50

/obj/item/stack/sheet/plastitaniumglass/twenty
	amount = 20

/obj/item/stack/sheet/plastitaniumglass/ten
	amount = 10

/obj/item/stack/sheet/plastitaniumglass/five
	amount = 5
