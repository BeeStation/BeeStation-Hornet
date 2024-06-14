GLOBAL_LIST_INIT(rod_recipes, list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, one_per_turf = TRUE, on_floor = FALSE, time = 1 SECONDS), \
	new/datum/stack_recipe("ladder", /obj/structure/ladder, 10, one_per_turf = TRUE, on_floor = TRUE, time = 6 SECONDS), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, one_per_turf = TRUE, on_floor = TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("scooter frame", /obj/item/scooter_frame, 10, one_per_turf = FALSE, time = 2.5 SECONDS), \
	new/datum/stack_recipe("linen bin", /obj/structure/bedsheetbin/empty, 2, one_per_turf = FALSE, time = 0.5 SECONDS), \
	new/datum/stack_recipe("railing", /obj/structure/railing, 3, window_checks = TRUE, time = 1.8 SECONDS), \
	))

/obj/item/stack/rods/cyborg
	merge_type = /obj/item/stack/rods

/obj/item/stack/rods/cyborg/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

STACKSIZE_MACRO(/obj/item/stack/rods)
