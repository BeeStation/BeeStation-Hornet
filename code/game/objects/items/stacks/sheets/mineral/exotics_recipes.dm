/* Bananium */

GLOBAL_LIST_INIT(bananium_recipes, list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = TRUE, on_floor = TRUE), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/bananium)

/* Adamantine */

GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount=25, res_amount=1),
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/adamantine)

/* Alien Alloy */

GLOBAL_LIST_INIT(abductor_recipes, list ( \
	new/datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 2, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/abductor)

/* Metal Hydrogen */
GLOBAL_LIST_INIT(metalhydrogen_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount=20, res_amount=1),
	new /datum/stack_recipe("ancient armor", /obj/item/clothing/suit/armor/elder_atmosian, req_amount = 8, res_amount = 1),
	new /datum/stack_recipe("ancient helmet", /obj/item/clothing/head/helmet/elder_atmosian, req_amount = 5, res_amount = 1),
	new /datum/stack_recipe("metallic hydrogen axe", /obj/item/fireaxe/metal_hydrogen_axe, req_amount = 15, res_amount = 1),
	))

/obj/item/stack/sheet/mineral/metal_hydrogen
	name = "Metal Hydrogen"
	icon_state = "sheet-metalhydrogen"
	item_state = "sheet-metalhydrogen"
	singular_name = "Metal Hydrogen sheet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	point_value = 100
	custom_materials = list(/datum/material/metalhydrogen = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/metal_hydrogen

/obj/item/stack/sheet/mineral/metal_hydrogen/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.metalhydrogen_recipes
	. = ..()

/obj/item/stack/sheet/mineral/zaukerite
	name = "zaukerite"
	icon_state = "zaukerite"
	item_state = "sheet-zaukerite"
	singular_name = "zaukerite crystal"
	w_class = WEIGHT_CLASS_NORMAL
	point_value = 120
	materials = list(/datum/material/zaukerite = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/zaukerite
