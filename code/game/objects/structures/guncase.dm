//GUNCASES//
/obj/structure/guncase
	name = "gun locker"
	desc = "A locker that holds guns."
	icon = 'icons/obj/closet.dmi'
	icon_state = "shotguncase"
	anchored = FALSE
	density = TRUE
	opacity = 0
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	//Slightly stronger than a regular locker
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0)
	var/case_type = ""
	var/gun_category = /obj/item/gun
	var/open = FALSE
	var/capacity = 4

/obj/structure/guncase/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc.contents)
			if(istype(I, gun_category))
				I.forceMove(src)
			if(contents.len >= capacity)
				break
	update_appearance()

/obj/structure/guncase/update_icon()
	cut_overlays()
	if(case_type && LAZYLEN(contents))
		var/mutable_appearance/gun_overlay = mutable_appearance(icon, case_type)
		for(var/i in 1 to contents.len)
			gun_overlay.pixel_x = 3 * (i - 1)
			add_overlay(gun_overlay)
	if(open)
		add_overlay("[icon_state]_open")
	else
		add_overlay("[icon_state]_door")

/obj/structure/guncase/proc/can_use()
	return TRUE

/obj/structure/guncase/attackby(obj/item/I, mob/user, params)
	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, gun_category) && open)
		if(LAZYLEN(contents) < capacity)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You place [I] in [src].</span>")
			update_appearance()
		else
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		return

	else if(user.a_intent != INTENT_HARM)
		if (can_use() || open)
			open = !open
			update_appearance()
		else
			to_chat(user, "<span class='warning'>[src] is locked, the door won't budge!</span>")
	else
		return ..()

/obj/structure/guncase/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(contents.len && open)
		ShowWindow(user)
	else if (can_use() || open)
		open = !open
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] is locked, the door won't budge!</span>")

/obj/structure/guncase/AltClick(mob/user)
	. = ..()
	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	if (can_use() || open)
		open = !open
		update_appearance()

/obj/structure/guncase/proc/ShowWindow(mob/user)
	var/dat = {"<div class='block'>
				<h3>Weapons Closet</h3>
				<table align='center'>
				<tr><A href='?src=[REF(src)];toggle_door=1'>Close Door</A><br>
				</table></div>
				<div class='block'>
				<h3>Stored Guns</h3>
				<table align='center'>"}
	if(LAZYLEN(contents))
		for(var/i in 1 to contents.len)
			var/obj/item/I = contents[i]
			dat += "<tr><A href='?src=[REF(src)];retrieve=[REF(I)]'>[I.name]</A><br>"
	dat += "</table></div>"

	var/datum/browser/popup = new(user, "gunlocker", "<div align='center'>[name]</div>", 350, 300)
	popup.set_content(dat)
	popup.open(FALSE)

/obj/structure/guncase/Topic(href, href_list)
	if(href_list["toggle_door"])
		if(!usr.canUseTopic(src, BE_CLOSE) || !open)
			return
		open = !open
		update_icon()
	if(href_list["retrieve"])
		var/obj/item/O = locate(href_list["retrieve"]) in contents
		if(!O || !istype(O))
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || !open)
			return
		if(ishuman(usr))
			if(!usr.put_in_hands(O))
				O.forceMove(get_turf(src))
			update_appearance()

/obj/structure/guncase/handle_atom_del(atom/A)
	update_appearance()

/obj/structure/guncase/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/structure/guncase/shotgun
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	case_type = "shotgun"
	gun_category = /obj/item/gun/ballistic/shotgun

/obj/structure/guncase/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	icon_state = "ecase"
	case_type = "egun"
	gun_category = /obj/item/gun/energy/e_gun

/obj/structure/guncase/locked
	var/is_unlocked = FALSE
	var/unlock_alert_level = null

/obj/structure/guncase/locked/Initialize(mapload)
	. = ..()
	//Add in signal handling for alert level changes
	if (unlock_alert_level)
		RegisterSignal(SSdcs, COMSIG_GLOB_SECURITY_ALERT_CHANGE, .proc/handle_alert)

/// React to the alert level by making a noise
/obj/structure/guncase/locked/proc/handle_alert(datum/source, new_alert)
	SIGNAL_HANDLER
	if(new_alert >= SEC_LEVEL_BLUE && !is_unlocked && !(obj_flags & EMAGGED))
		visible_message("<span class='notice'>The locking mechanism inside [src] disengages, it can now be opened.</span>")
		playsound(src, 'sound/machines/boltsup.ogg', 50, TRUE)
		update_icon()

/// Check if the locker can be unlocked with the card
/obj/structure/guncase/locked/attackby(obj/item/I, mob/user, params)
	if (user.a_intent == INTENT_HARM || !length(I.GetAccess()))
		return ..()
	if (check_access(I))
		if (is_unlocked)
			is_unlocked = FALSE
			if (can_use())
				to_chat(user, "<span class='notice'>You reactivate the manual override lock attached to [src]. It is now locked.</span>")
				playsound(src, 'sound/machines/boltsup.ogg', 50, TRUE)
			else
				to_chat(user, "<span class='notice'>You reactivate the manual override lock attached to [src]. It will be locked when the alert level is lowered back to green.</span>")
		else
			is_unlocked = TRUE
			to_chat(user, "<span class='notice'>You release the manual override lock attached to [src].</span>")
			playsound(src, 'sound/machines/boltsup.ogg', 50, TRUE)
		update_icon()
	else
		to_chat(user, "<span class='warning'>Insufficient access.</span>")

/// Can this locker be used?
/obj/structure/guncase/locked/can_use()
	return (obj_flags & EMAGGED) || is_unlocked || (unlock_alert_level && GLOB.security_level >= unlock_alert_level)

/// Add in emagging behaviour
/obj/structure/guncase/locked/emag_act(mob/user)
	. = ..()
	if (obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You override the locking mechanism inside of [src].</span>")
	playsound(src, 'sound/machines/boltsup.ogg', 50, TRUE)
	update_icon()

/obj/structure/guncase/locked/update_icon()
	. = ..()
	if (can_use())
		add_overlay("[icon_state]_unlock")
	else
		add_overlay("[icon_state]_lock")

/obj/structure/guncase/locked/detective
	name = "secure detective locker"
	desc = "A secure, electronically motored locker that stores the detective's revolver."
	case_type = "revolver"
	gun_category = /obj/item/clothing/accessory/holster/detective
	capacity = 2
	req_access = list(ACCESS_ARMORY)
	unlock_alert_level = SEC_LEVEL_BLUE

/obj/structure/guncase/locked/detective/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/accessory/holster/detective(src)
	update_icon()
