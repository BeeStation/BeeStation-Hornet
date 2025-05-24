GLOBAL_LIST_INIT(metalhydrogen_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount = 20, res_amount = 1),
	new /datum/stack_recipe("ancient armor", /obj/item/clothing/suit/armor/elder_atmosian, req_amount = 5, res_amount = 1),
	new /datum/stack_recipe("ancient helmet", /obj/item/clothing/head/helmet/elder_atmosian, req_amount = 3, res_amount = 1),
	new /datum/stack_recipe("metallic hydrogen axe", /obj/item/fireaxe/metal_h2_axe, req_amount = 15, res_amount = 1),
	new /datum/stack_recipe("metallic hydrogen bolts", /obj/item/ammo_casing/rebar/hydrogen, req_amount = 1, res_amount = 1),
))

/obj/item/stack/sheet/mineral/metal_hydrogen
	name = "metal hydrogen"
	icon_state = "sheet-metalhydrogen"
	item_state = null
	singular_name = "metal hydrogen sheet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	point_value = 75
	mats_per_unit = list(/datum/material/metalhydrogen = MINERAL_MATERIAL_AMOUNT)
	material_type = /datum/material/metalhydrogen
	merge_type = /obj/item/stack/sheet/mineral/metal_hydrogen

/obj/item/stack/sheet/mineral/bananium/get_recipes()
	return GLOB.metalhydrogen_recipes

GLOBAL_LIST_INIT(zaukerite_recipes, list(
	new /datum/stack_recipe("zaukerite shard", /obj/item/ammo_casing/rebar/zaukerite, req_amount = 1, res_amount=  1),
))

/obj/item/stack/sheet/mineral/zaukerite
	name = "zaukerite"
	icon_state = "zaukerite"
	item_state = "sheet-zaukerite"
	singular_name = "zaukerite crystal"
	w_class = WEIGHT_CLASS_NORMAL
	point_value = 100
	mats_per_unit = list(/datum/material/zaukerite = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/zaukerite
	material_type = /datum/material/zaukerite

/obj/item/stack/sheet/mineral/zaukerite/get_recipes()
	return GLOB.zaukerite_recipes

/obj/item/stack/ammonia_crystals
	name = "ammonia crystals"
	singular_name = "ammonia crystal"
	icon_state = "ammonia-crystal"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_amount = 25
	grind_results = list(/datum/reagent/ammonia = 10)
	merge_type = /obj/item/stack/ammonia_crystals

/obj/item/stack/sheet/hot_ice
	name = "hot ice"
	singular_name = "hot ice piece"
	icon_state = "hot-ice"
	item_state = null
	mats_per_unit = list(/datum/material/hot_ice = MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/toxin/hot_ice = 25)
	material_type = /datum/material/hot_ice
	merge_type = /obj/item/stack/sheet/hot_ice

/obj/item/stack/sheet/hot_ice/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS //dont you kids know that stuff is toxic?
