GLOBAL_LIST_INIT(rod_recipes, list (
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1 SECONDS, category = CAT_STRUCTURE),
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1 SECONDS, category = CAT_FURNITURE),
	new/datum/stack_recipe("scooter frame", /obj/item/scooter_frame, 10, crafting_flags = CRAFT_CHECK_DENSITY, time = 2.5 SECONDS, category = CAT_ENTERTAINMENT),
	new/datum/stack_recipe("linen bin", /obj/structure/bedsheetbin/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY, time = 0.5 SECONDS, category = CAT_CONTAINERS),
	new/datum/stack_recipe("railing", /obj/structure/railing, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION, time = 1.8 SECONDS, category = CAT_STRUCTURE),
	new/datum/stack_recipe("ladder", /obj/structure/ladder, 10, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 6 SECONDS, category = CAT_STRUCTURE),
	new/datum/stack_recipe("catwalk floor tile", /obj/item/stack/tile/catwalk_tile, 1, 4, 20, category = CAT_TILES),
))

/obj/item/stack/rods/cyborg
	merge_type = /obj/item/stack/rods

/obj/item/stack/rods/cyborg/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

STACKSIZE_MACRO(/obj/item/stack/rods)
