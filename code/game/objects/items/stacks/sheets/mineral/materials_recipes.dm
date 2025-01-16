/* sandstone */

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/stack/ore/glass, 1, one_per_turf = FALSE, on_floor = TRUE) \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/sandstone)

/* diamond */

GLOBAL_LIST_INIT(diamond_recipes, list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/diamond)

/* uranium */

GLOBAL_LIST_INIT(uranium_recipes, list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("depleted uranium directional window", /obj/structure/window/depleteduranium/unanchored, 1, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("depleted uranium fulltile window", /obj/structure/window/depleteduranium/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE) \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/uranium)

/* Plasma */

GLOBAL_LIST_INIT(plasma_recipes, list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/plasma)

/* Gold */

GLOBAL_LIST_INIT(gold_recipes, list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("Simple Crown", /obj/item/clothing/head/costume/crown, 5), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/gold)

/* Silver */

GLOBAL_LIST_INIT(silver_recipes, list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/silver)

/* Copper */

GLOBAL_LIST_INIT(copper_recipes, list ( \
	new/datum/stack_recipe("Copper Door", /obj/structure/mineral_door/copper, 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("Copper Tile", /obj/item/stack/tile/mineral/copper, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/copper)

/* Titanium */

GLOBAL_LIST_INIT(titanium_recipes, list ( \
	new/datum/stack_recipe("titanium tile", /obj/item/stack/tile/mineral/titanium, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/titanium)

/* Plastitanium */

GLOBAL_LIST_INIT(plastitanium_recipes, list ( \
	new/datum/stack_recipe("plastitanium tile", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/plastitanium)

/* Coal - no recipes sorry!*/

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/coal)
