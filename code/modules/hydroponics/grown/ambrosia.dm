// Ambrosia - base type
/obj/item/food/grown/ambrosia
	seed = /obj/item/plant_seeds/preset/ambrosia
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = ITEM_SLOT_HEAD
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	tastes = list("ambrosia" = 1)

/obj/item/food/grown/ambrosia/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_worn", /datum/mood_event/flower_worn, src)

/obj/item/food/grown/ambrosia/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_worn")

/obj/item/food/grown/ambrosia/vulgaris
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	wine_power = 30

// Ambrosia Deus
/obj/item/food/grown/ambrosia/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	wine_power = 50
	discovery_points = 300

//Ambrosia Gaia
/obj/item/food/grown/ambrosia/gaia
	name = "ambrosia gaia branch"
	desc = "Eating this <i>makes</i> you immortal."
	icon_state = "ambrosia_gaia"
	light_system = MOVABLE_LIGHT
	light_range = 3
	wine_power = 70
	wine_flavor = "the earthmother's blessing"
	discovery_points = 300
