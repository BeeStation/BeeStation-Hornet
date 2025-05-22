//PIMP-CART
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/mybag = null
	var/floorbuffer = FALSE
	var/datum/action/cleaning_toggle/autoclean_toggle

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	update_icon()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)
	GLOB.janitor_devices += src
	if(floorbuffer)
		AddElement(/datum/element/cleaning)

/obj/vehicle/ridden/janicart/Destroy()
	GLOB.janitor_devices -= src
	if(mybag)
		qdel(mybag)
		mybag = null
	. = ..()

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/vehicle/ridden/janicart/examine(mob/user)
	. += ..()
	if(floorbuffer)
		. += "It has been upgraded with a floor buffer."

/obj/vehicle/ridden/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, span_warning("[src] already has a trashbag hooked!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, span_notice("You hook the trashbag onto [src]."))
		mybag = I
		update_icon()
	else if(istype(I, /obj/item/janiupgrade))
		if(floorbuffer)
			to_chat(user, span_warning("[src] already has a floor buffer!"))
			return
		floorbuffer = TRUE
		qdel(I)
		to_chat(user, span_notice("You upgrade [src] with the floor buffer."))
		AddElement(/datum/element/cleaning)
		update_icon()
	else
		return ..()

/obj/vehicle/ridden/janicart/update_icon()
	cut_overlays()
	if(mybag)
		add_overlay("cart_garbage")
	if(floorbuffer)
		add_overlay("cart_buffer")

/obj/vehicle/ridden/janicart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	else if(mybag)
		mybag.forceMove(get_turf(user))
		user.put_in_hands(mybag)
		mybag = null
		update_icon()

/obj/vehicle/ridden/janicart/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(floorbuffer)
		autoclean_toggle = new()
		autoclean_toggle.toggle_target = src
		autoclean_toggle.Grant(M)

/obj/vehicle/ridden/janicart/unbuckle_mob(mob/living/buckled_mob, force)
	. = ..()
	if(floorbuffer)
		autoclean_toggle.Remove(buckled_mob)
		QDEL_NULL(autoclean_toggle)

/obj/vehicle/ridden/janicart/Destroy()
	. = ..()
	if(floorbuffer)
		autoclean_toggle.toggle_target = null
		QDEL_NULL(autoclean_toggle)

/obj/vehicle/ridden/janicart/upgraded
	floorbuffer = TRUE

/obj/vehicle/ridden/janicart/upgraded/keyless
	floorbuffer = TRUE
	key_type = null
