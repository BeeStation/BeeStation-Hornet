
//Boat

/obj/vehicle/ridden/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	icon_state = "goliath_boat"
	icon_preview = 'icons/obj/previews.dmi'
	icon_state_preview = "boat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	can_buckle = TRUE
	key_type = /obj/item/oar

/obj/vehicle/ridden/lavaboat/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat)

/obj/item/oar
	name = "oar"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	inhand_icon_state = "oar"
	lefthand_file = 'icons/mob/inhands/misc/lavaland_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/lavaland_righthand.dmi'
	desc = "Not to be confused with the kind Research hassles you for."
	force = 12

	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF

//Dragon Boat

/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"
	custom_price = 10000
	max_demand = 10

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	new /obj/vehicle/ridden/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/ridden/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	icon_state = "dragon_boat"

/obj/vehicle/ridden/lavaboat/dragon/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat/dragonboat)
