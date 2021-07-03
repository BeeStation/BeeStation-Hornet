/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/open = FALSE
	var/can_hack_open = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	desc = "This shouldn't exist. If it does, create an issue report."

/obj/item/storage/secure/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(can_hack_open)
		. += "The service panel is currently <b>[open ? "unscrewed" : "screwed shut"]</b>."

/obj/item/storage/secure/attackby(obj/item/W, mob/user, params)
	if(can_hack_open && SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
		if (W.tool_behaviour == TOOL_SCREWDRIVER)
			if (W.use_tool(src, user, 20))
				open = !open
				to_chat(user, "<span class='notice'>You [open ? "open" : "close"] the service panel.</span>")
			return
		if (W.tool_behaviour == TOOL_WIRECUTTER)
			to_chat(user, "<span class='danger'>[src] is protected from this sort of tampering, yet it appears the internal memory wires can still be <b>pulsed</b>.</span>")
			return
		if ((W.tool_behaviour == TOOL_MULTITOOL))
			if(l_hacking)
				to_chat(user, "<span class='danger'>This safe is already being hacked.</span>")
				return
			if(open)
				to_chat(user, "<span class='danger'>Now attempting to reset internal memory, please hold.</span>")
				l_hacking = TRUE
				if (W.use_tool(src, user, 400))
					to_chat(user, "<span class='danger'>Internal memory reset - lock has been disengaged.</span>")
					l_set = FALSE

				l_hacking = FALSE
				return
			to_chat(user, "<span class='notice'>You must <b>unscrew</b> the service panel before you can pulse the wiring.</span>")
			return

	// -> storage/attackby() what with handle insertion, etc
	return ..()

/obj/item/storage/secure/attack_self(mob/user)
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((l_set == 0) && (!l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", code)
	if (!locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=[REF(src)];type=1'>1</A>-<A href='?src=[REF(src)];type=2'>2</A>-<A href='?src=[REF(src)];type=3'>3</A><BR>\n<A href='?src=[REF(src)];type=4'>4</A>-<A href='?src=[REF(src)];type=5'>5</A>-<A href='?src=[REF(src)];type=6'>6</A><BR>\n<A href='?src=[REF(src)];type=7'>7</A>-<A href='?src=[REF(src)];type=8'>8</A>-<A href='?src=[REF(src)];type=9'>9</A><BR>\n<A href='?src=[REF(src)];type=R'>R</A>-<A href='?src=[REF(src)];type=0'>0</A>-<A href='?src=[REF(src)];type=E'>E</A><BR>\n</TT>", message)
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
				l_code = code
				l_set = 1
			else if ((code == l_code) && (l_set == 1))
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
				cut_overlays()
				add_overlay(icon_opened)
				code = null
			else
				code = "ERROR"
		else
			if ((href_list["type"] == "R") && (!l_setshort))
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)
				cut_overlays()
				code = null
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_FROM, usr)
			else
				code += text("[]", sanitize_text(href_list["type"]))
				if (length(code) > 5)
					code = "ERROR"
		add_fingerprint(usr)
		for(var/mob/M as() in viewers(1, get_turf(src)))
			if ((M.client && M.machine == src))
				attack_self(M)
			return
	return


// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	desc = "A large briefcase with a digital locking system."
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	block_upgrade_walk = 1

/obj/item/storage/secure/briefcase/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/briefcase/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21
	STR.max_w_class = WEIGHT_CLASS_NORMAL

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/PopulateContents()
	..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i = 0, i < STR.max_items - 2, i++)
		new /obj/item/stack/spacecash/c1000(src)


// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	desc = "Excellent for securing things away from grubby hands."
	force = 8
	w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE

/obj/item/storage/secure/safe/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.cant_hold = typecacheof(list(/obj/item/storage/secure/briefcase))
	STR.max_w_class = 8						//??

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	return attack_self(user)

/obj/item/storage/secure/safe/HoS
	name = "head of security's safe"

/**
 * This safe is meant to be damn robust. To break in, you're supposed to get creative, or use acid or an explosion.
 *
 * This makes the safe still possible to break in for someone who is prepared and capable enough, either through
 * chemistry, botany or whatever else.
 *
 * The safe is also weak to explosions, so spending some early TC could allow an antag to blow it upen if they can
 * get access to it.
 */
/obj/item/storage/secure/safe/caps_spare
	name = "captain's spare ID safe"
	desc = "In case of emergency, do not break glass. All Captains and Acting Captains are provided with codes to access this safe. \
It is made out of the same material as the station's Black Box and is designed to resist all conventional weaponry. \
There appears to be a small amount of surface corrosion. It doesn't look like it could withstand much of an explosion."
	can_hack_open = FALSE
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 70, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70);
	max_integrity = 300
	color = "#ffdd33"

/obj/item/storage/secure/safe/caps_spare/Initialize()
	. = ..()
	l_code = SSjob.spare_id_safe_code
	l_set = TRUE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/storage/secure/safe/caps_spare/PopulateContents()
	new /obj/item/card/id/captains_spare(src)

/obj/item/storage/secure/safe/caps_spare/rust_heretic_act()
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = "melee", armour_penetration = 100)
