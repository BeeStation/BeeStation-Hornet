/* Bananium */

GLOBAL_LIST_INIT(bananium_recipes, list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = TRUE, on_floor = TRUE), \
	))

/obj/item/stack/sheet/mineral/bananium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/bananium/twenty
	amount = 20

/obj/item/stack/sheet/mineral/bananium/five
	amount = 5

/* Adamantine */

GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount=25, res_amount=1),
	))

/obj/item/stack/sheet/mineral/adamantine/fifty
	amount = 50

/obj/item/stack/sheet/mineral/adamantine/twenty
	amount = 20

/obj/item/stack/sheet/mineral/adamantine/five
	amount = 5

/* Alien Alloy */

GLOBAL_LIST_INIT(abductor_recipes, list ( \
	new/datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 2, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/abductor/fifty
	amount = 50

/obj/item/stack/sheet/mineral/abductor/twenty
	amount = 20

/obj/item/stack/sheet/mineral/abductor/five
	amount = 5

/* Coal */
