/obj/item/bagnet
	name = "\improper BAGnet"
	desc = "An advanced piece of technology used to instantly transport patients and bodybags to a linked BAGnet beacon."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "BAGnet"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	item_state = "contractor_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	var/teleport_timer = 2 SECONDS
	var/self_teleport_multiplier = 2
	var/mob_teleport_multiplier = 2
	var/atom/target_beacon = null
	//var/in_use = FALSE

/obj/item/bagnet/afterattack(atom/target, mob/user, proximity, params)
	/*if(in_use)
		to_chat(user,"<span class='warning'>The [src] is already in use!</span>")
		return*/
	if(!ismob(target) && !(istype(target, /obj/structure/closet/body_bag)))
		return
	if(isnull(target_beacon))
		to_chat(user,"<span class='warning'>There aren't any selected beacons!</span>")
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
	var/obj/effect/bagnetmarker/P = new /obj/effect/bagnetmarker(get_turf(target))
	user.visible_message("<span class='notice'>[user] starts calibrating [src] on [target].</span>", "<span class='notice'>You start calibrating [src] on [target].</span>")
	var/teleport_delay = teleport_timer
	if(ismob(target))
		teleport_delay = teleport_delay * mob_teleport_multiplier
	if(target == user)
		teleport_delay = teleport_delay * self_teleport_multiplier
	if(do_after(user, teleport_delay, target))
		user.visible_message("<span class='notice'>[user] teleports away [target] with [src].</span>", "<span class='notice'>You start teleport [target] away with [src].</span>")
		playsound(src, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff_exponent = 5)
		do_teleport(target, target_beacon, 0, channel = TELEPORT_CHANNEL_BLUESPACE)//teleport what's in the tile to the beacon
		playsound(target_beacon, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff_exponent = 5)
		qdel(P)
		return
	else
		user.visible_message("<span class='notice'>[user] fails to calibrate [src].</span>","<span ='notice'>You fail to calibrate the [src].</span>")
		qdel(P)
		return

/obj/item/bagnet/attack_self(mob/user)
	if(!length(GLOB.teleportbeacons))
		to_chat(user,"<span class='warning'>There are no beacons available!</span>")
		return
	var/list/areaindex = list()
	var/list/L = list()
	for(var/obj/item/beacon/medbayportal/P as anything in GLOB.teleportbeacons)
		if(P.is_eligible())
			if(P.renamed)
				L[avoid_assoc_duplicate_keys("[P.name] ([get_area(P)])", areaindex)] = P
			else
				var/area/A = get_area(P)
				L[avoid_assoc_duplicate_keys(A.name, areaindex)] = P
	if(!length(L))//There could be teleporter beacons around but no medbay ones
		to_chat(user,"<span class='warning'>There are no active medical beacons available!</span>")
		return
	var/desc = input("Select the destination to lock in.", "Teleportation target") as null|anything in sort_list(L)
	var/datum/weakref/target_ref = WEAKREF(L[desc])
	var/atom/target = target_ref?.resolve()
	if(!target)
		return
	target_beacon = target
	to_chat(user, "<span class='notice'>Target selected : [get_area(target)]</span>")


/obj/effect/bagnetmarker
	name = "BAGnet teleportation marker"
	desc = "A field of bluespace energy, locking on to take away a patient."
	icon = 'icons/effects/effects.dmi'
	icon_state = "dragnetfield"
	light_range = 3
	anchored = TRUE

/obj/effect/bagnetmarker/Initialize(mapload)
	. = ..()
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)

/obj/effect/nettingportal/singularity_act()
	return

/obj/effect/nettingportal/singularity_pull()
	return
