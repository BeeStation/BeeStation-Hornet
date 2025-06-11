/obj/item/sbeacondrop/exploration
	name = "bluespace beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a bluespace gigabeacon to your location, which will allow you to return to promising stations.</i>."
	droptype = /obj/structure/bluespace_beacon

//Beacon structure

/obj/structure/bluespace_beacon
	name = "bluespace giga-beacon"
	desc = "Locks a location on the navigational map, allowing for it to be returned to at any time."
	icon = 'icons/obj/machines/NavBeacon.dmi'
	icon_state = "beacon-item"
	density = TRUE

	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

	light_power = 2
	light_range = 3
	light_color = "#cd87df"

	anchored = TRUE

/obj/structure/bluespace_beacon/Initialize(mapload)
	. = ..()
	GLOB.zclear_blockers += src

/obj/structure/bluespace_beacon/Destroy()
	GLOB.zclear_blockers -= src
	. = ..()

/obj/structure/bluespace_beacon/wrench_act(mob/living/user, obj/item/I)
	if(anchored)
		to_chat(user, span_notice("You start unsecuring [src]..."))
	else
		to_chat(user, span_notice("You start securing [src]..."))
	if(I.use_tool(src, user, 40, volume=50))
		if(QDELETED(I))
			return
		if(anchored)
			to_chat(user, span_notice("You unsecure [src]."))
		else
			to_chat(user, span_notice("You secure [src]."))
		set_anchored(!anchored)
