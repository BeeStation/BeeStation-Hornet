/obj/item/stack/ammonia_crystals
	name = "ammonia crystals"
	singular_name = "ammonia crystal"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "ammonia_crystal"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_amount = 50
	grind_results = list(/datum/reagent/ammonia = 10)
	merge_type = /obj/item/stack/ammonia_crystals

/obj/item/stack/ammonia_crystals/ten
	amount = 10

/obj/item/stack/ammonia_crystals/thirty
	amount = 30
