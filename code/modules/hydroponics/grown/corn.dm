// Corn
/obj/item/food/grown/corn
	seed = /obj/item/plant_seeds/preset/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	microwaved_type = /obj/item/food/popcorn
	trash_type = /obj/item/grown/corncob
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/corn_starch
	tastes = list("corn" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/whiskey
	discovery_points = 300

/*
/obj/item/food/grown/corn/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/popcorn)
*/

/obj/item/grown/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon_state = "corncob"
	inhand_icon_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/corncob/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		to_chat(user, span_notice("You use [W] to fashion a pipe out of the corn cob!"))
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
	else
		return ..()

// Snapcorn
/obj/item/grown/snapcorn
	name = "snap corn"
	desc = "A cob with snap pops."
	icon_state = "snapcorn"
	inhand_icon_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/snap_pops = 1
	discovery_points = 300

/obj/item/grown/snapcorn/Initialize(mapload)
	. = ..()
	snap_pops = get_fruit_trait_power(src) * 3

/obj/item/grown/snapcorn/attack_self(mob/user)
	..()
	to_chat(user, span_notice("You pick a snap pop from the cob."))
	var/obj/item/toy/snappop/S = new /obj/item/toy/snappop(user.loc)
	if(ishuman(user))
		user.put_in_hands(S)
	snap_pops -= 1
	if(!snap_pops)
		new /obj/item/grown/corncob(user.loc)
		qdel(src)
