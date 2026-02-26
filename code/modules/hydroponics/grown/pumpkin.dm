// Pumpkin
/obj/item/food/grown/pumpkin
	seed = /obj/item/plant_seeds/preset/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/pumpkinjuice
	wine_power = 20

/obj/item/food/grown/pumpkin/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.get_sharpness())
		user.show_message(span_notice("You carve a face into [src]!"), MSG_VISUAL)
		new /obj/item/clothing/head/utility/hardhat/pumpkinhead(user.loc)
		qdel(src)
		return
	else
		return ..()

// Blumpkin
/obj/item/food/grown/blumpkin
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/blumpkinjuice
	wine_power = 50
	discovery_points = 300
