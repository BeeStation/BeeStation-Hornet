/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/bag_type = /obj/structure/closet/body_bag

/obj/item/bodybag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, bag_type)

/obj/item/bodybag/suicide_act(mob/living/user)
	if(isopenturf(user.loc))
		user.visible_message(span_suicide("[user] is crawling into [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		SEND_SIGNAL(src, COMSIG_DEPLOYABLE_FORCE_DEPLOY, user.loc)
		var/obj/structure/closet/body_bag/R = locate() in user.loc
		playsound(src, 'sound/items/zip.ogg', 15, 1, -3)
		if (!R)
			qdel(user)
			return OXYLOSS
		user.forceMove(R)
		return OXYLOSS

// Bluespace bodybag

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	bag_type = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(length(contents))
		var/s = length(contents)== 1 ? "" : "s"
		. += span_notice("You can make out the shape[s] of [contents.len] object[s] through the fabric.")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, span_notice("You suddenly feel the space around you tear apart! You're free!"))
	return ..()
