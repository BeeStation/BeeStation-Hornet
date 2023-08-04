/obj/item/deployable/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	deployed_object = /obj/structure/closet/body_bag
	ignores_mob_density = TRUE

/obj/item/deployable/bodybag/suicide_act(mob/user)
	if(isopenturf(user.loc))
		user.visible_message("<span class='suicide'>[user] is crawling into [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/obj/structure/closet/body_bag/R = new deployed_object(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/items/zip.ogg', 15, 1, -3)
		return (OXYLOSS)
	..()

// Bluespace bodybag

/obj/item/deployable/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	deployed_object = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/deployable/bodybag/bluespace/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_CANREACH, PROC_REF(CanReachReact))

/obj/item/deployable/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(length(contents))
		var/s = length(contents)== 1 ? "" : "s"
		. += "<span class='notice'>You can make out the shape[s] of [contents.len] object[s] through the fabric.</span>"

/obj/item/deployable/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, "<span class='notice'>You suddenly feel the space around you tear apart! You're free!</span>")
	return ..()

/obj/item/deployable/bodybag/bluespace/proc/CanReachReact(atom/movable/source, list/next)
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_REACH
