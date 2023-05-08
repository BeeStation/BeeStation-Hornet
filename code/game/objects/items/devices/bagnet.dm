/obj/item/bagnet
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "BAGnet"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	item_state = "contractor_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
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
	//var/mob/living/M = target

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
