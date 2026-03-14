/obj/structure/mop_bucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE

/obj/structure/mop_bucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mop_bucket/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.is_drainable() && attacking_item.reagents.total_volume > 0)
		update_appearance(UPDATE_OVERLAYS)
		return FALSE // we want to continue the attack chain

	if(!istype(attacking_item, /obj/item/mop))
		return ..()

	if(reagents.total_volume < 1)
		to_chat(user, span_warn("[src] is out of water!"))
		return TRUE
	else if(reagents.trans_to(attacking_item, 5, transfered_by = user))
		to_chat(user, span_notice("You wet [attacking_item] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/mop_bucket/update_overlays()
	. = ..()
	if(reagents.total_volume > 0)
		. += "mopbucket_water"
