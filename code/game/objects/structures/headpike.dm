/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	density = FALSE
	anchored = TRUE
	var/obj/item/spear/spear
	var/obj/item/bodypart/head/victim

/obj/structure/headpike/glass //for regular spears
	icon_state = "headpike"

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"

/obj/structure/headpike/bamboo //for bamboo spears
	icon_state = "headpike-bamboo"

/obj/structure/headpike/CheckParts(list/parts_list)
	victim = locate(/obj/item/bodypart/head) in parts_list
	name = "[victim.name] on a spear"
	..()
	update_icon()

/obj/structure/headpike/glass/CheckParts(list/parts_list)
	spear = locate(/obj/item/spear) in parts_list
	..()

/obj/structure/headpike/bone/CheckParts(list/parts_list)
	spear = locate(/obj/item/spear/bonespear) in parts_list
	..()

/obj/structure/headpike/bamboo/CheckParts(list/parts_list)
	spear = locate(/obj/item/spear/bamboospear) in parts_list
	..()

/obj/structure/headpike/Initialize(mapload)
	. = ..()
	pixel_x = rand(-8, 8)

/obj/structure/headpike/update_icon()
	..()
	var/obj/item/bodypart/head/H = locate() in contents
	var/mutable_appearance/MA = new()
	if(H)
		MA.copy_overlays(H)
		MA.pixel_y = 12
		add_overlay(H)

/obj/structure/headpike/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You take down [src]."))
	if(victim)
		victim.forceMove(drop_location())
		victim = null
	spear.forceMove(drop_location())
	spear = null
	qdel(src)
