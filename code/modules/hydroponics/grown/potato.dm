// Potato
/obj/item/food/grown/potato
	seed = /obj/item/plant_seeds/preset/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	bite_consumption_mod = 100
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/potato_juice
	distill_reagent = /datum/reagent/consumable/ethanol/vodka

/obj/item/food/grown/potato/wedges
	name = "potato wedges"
	desc = "Slices of neatly cut potato."
	icon_state = "potato_wedges"
	bite_consumption_mod = 100

/obj/item/food/grown/potato/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		to_chat(user, span_notice("You cut the potato into wedges with [W]."))
		var/obj/item/food/grown/potato/wedges/Wedges = new /obj/item/food/grown/potato/wedges
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Wedges)
	else
		return ..()


// Sweet Potato
/obj/item/food/grown/potato/sweet
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"
	distill_reagent = /datum/reagent/consumable/ethanol/sbiten
	discovery_points = 300
