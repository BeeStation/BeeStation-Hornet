// Carrot
/obj/item/food/grown/carrot
	seed = /obj/item/plant_seeds/preset/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/carrotjuice
	wine_power = 30

/obj/item/food/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(I.get_sharpness())
		to_chat(user, span_notice("You sharpen the carrot into a shiv with [I]."))
		var/obj/item/knife/shiv/carrot/Shiv = new /obj/item/knife/shiv/carrot
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Shiv)
	else
		return ..()

// Parsnip
/obj/item/food/grown/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/parsnipjuice
	wine_power = 35
	discovery_points = 300


// White-Beet
/obj/item/food/grown/whitebeet
	seed = /obj/item/plant_seeds/preset/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	wine_power = 40

// Red Beet
/obj/item/food/grown/redbeet
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 60
	discovery_points = 300
