/obj/item/glove_box
	name = "box of latex gloves"
	desc = "A box of latex gloves, useful for quick cleanup after surgery."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "latex_glove_box"
	inhand_icon_state = "deliverypackage"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	var/glove_type = /obj/item/clothing/gloves/color/latex
	var/total_gloves = 50

/obj/item/glove_box/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	update_icon()

/obj/item/glove_box/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)

/obj/item/glove_box/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/glove_box/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	if(total_gloves >= 1)
		total_gloves--
		var/obj/item/clothing/gloves/G
		G = new glove_type(src)
		G.add_fingerprint(user)
		G.forceMove(user.loc)
		user.put_in_hands(G)
		to_chat(user, span_notice("You take [G] out of \the [src]."))
	else
		to_chat(user, span_warning("[src] is empty!"))
	update_icon()
	add_fingerprint(user)
	return ..()

/obj/item/glove_box/examine(mob/user)
	. = ..()
	if(total_gloves)
		. += "It contains [total_gloves] pair of gloves."
	else
		. += "It is empty."

/obj/item/glove_box/update_icon()
	cut_overlays()
	if(total_gloves > 1)
		add_overlay("glove_in")

/obj/item/glove_box/attack_self(mob/user)
	. = ..()
	if(total_gloves > 0)
		to_chat(user, span_warning("You can't fold this box with items still inside!"))
		return
	to_chat(user, span_notice("You fold [src] flat."))
	qdel(src)
	user.put_in_hands(new /obj/item/stack/sheet/cardboard())

