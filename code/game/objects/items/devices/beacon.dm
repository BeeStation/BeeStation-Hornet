/obj/item/beacon
	name = "\improper tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/enabled = TRUE
	var/renamed = FALSE
	var/nettingportal = FALSE
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/beacon/Initialize(mapload)
	. = ..()
	if (enabled)
		GLOB.teleportbeacons += src
	else
		icon_state = "beacon-off"

/obj/item/beacon/Destroy()
	GLOB.teleportbeacons -= src
	return ..()

/obj/item/beacon/attack_self(mob/user)
	enabled = !enabled
	if (enabled)
		icon_state = "beacon"
		GLOB.teleportbeacons += src
	else
		icon_state = "beacon-off"
		GLOB.teleportbeacons -= src
	to_chat(user, "<span class='notice'>You [enabled ? "enable" : "disable"] the beacon.</span>")
	return

/obj/item/beacon/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen)) // needed for things that use custom names like the locator
		var/new_name = stripped_input(user, "What would you like the name to be?")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(new_name)
			name = new_name
			renamed = TRUE
		return
	else
		return ..()

/obj/item/beacon/nettingportal
	//dragnet location beacon
	name = "\improper DROPnet"
	desc = "A beacon designated for DRAGnets; all captured targets will teleport to it. Remember to activate before you deploy."
	nettingportal = TRUE
	enabled = FALSE	//can no longer teleport to Warden's office roundstart

/obj/item/beacon/medbayportal
	//bagnet location beacon
	name = "\improper BAGnet beacon"
	desc = "A beacon designated for BAGnets; all patients will teleport to it. Remember to secure it with your ID before you deploy."
	enabled = TRUE
	icon_state = "beacon_off"
	icon = 'icons/obj/bodybag.dmi'
	var/emagged = FALSE
	req_access = list(ACCESS_MEDICAL) //for locking it in place and making it work

/obj/item/beacon/medbayportal/attack_self(mob/user)
	return //cannot be deactivated

/obj/item/beacon/medbayportal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "BAGnet beacon")

/obj/item/beacon/medbayportal/attackby(obj/item/W, mob/user, params)
	if(W.GetID())
		if(!check_access(W))
			to_chat(user, "<span class='danger'>Access Denied.</span>")
			return
	if(!anchored && !(isturf(src.loc)))
		to_chat(user, "<span class='notice'>The [src] needs to be on the floor to be anchored!</span>")
		return
	if(anchored)
		icon_state = "beacon_off"
		anchored = FALSE
	else
		icon_state = "beacon"
		anchored = TRUE
	user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor.</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor.</span>")

/obj/item/beacon/proc/is_eligible()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(is_centcom_level(T.z) || is_away_level(T.z))
		return FALSE
	var/area/A = get_area(T)
	if(!A || A.teleport_restriction)
		return FALSE
	if(!anchored)
		return FALSE
	return TRUE
