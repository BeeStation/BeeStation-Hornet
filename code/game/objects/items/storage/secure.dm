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
	icon = 'icons/obj/storage/case.dmi'
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

/obj/item/storage/secure/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(can_hack_open)
		. += "The service panel is currently <b>[open ? "unscrewed" : "screwed shut"]</b>."

/obj/item/storage/secure/attackby(obj/item/W, mob/user, params)
	if(can_hack_open && atom_storage.locked)
		if (W.tool_behaviour == TOOL_SCREWDRIVER)
			if (W.use_tool(src, user, 20))
				open = !open
				to_chat(user, span_notice("You [open ? "open" : "close"] the service panel."))
			return
		if (W.tool_behaviour == TOOL_WIRECUTTER)
			to_chat(user, span_danger("[src] is protected from this sort of tampering, yet it appears the internal memory wires can still be <b>pulsed</b>."))
			return
		if ((W.tool_behaviour == TOOL_MULTITOOL))
			if(l_hacking)
				to_chat(user, span_danger("This safe is already being hacked."))
				return
			if(open)
				to_chat(user, span_danger("Now attempting to reset internal memory, please hold."))
				l_hacking = TRUE
				if (W.use_tool(src, user, 400))
					to_chat(user, span_danger("Internal memory reset - lock has been disengaged."))
					l_set = FALSE

				l_hacking = FALSE
				return
			to_chat(user, span_notice("You must <b>unscrew</b> the service panel before you can pulse the wiring."))
			return

	// -> storage/attackby() what with handle insertion, etc
	return ..()

/obj/item/storage/secure/attack_self(mob/user)
	var/locked = atom_storage.locked
	user.set_machine(src)
	var/dat = "<TT><B>[src]</B><BR>\n\nLock Status: [(locked ? "LOCKED" : "UNLOCKED")]"
	var/message = "Code"
	if ((l_set == 0) && (!l_setshort))
		dat += "<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"
	if (l_setshort)
		dat += "<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>"
	message = "[code]"
	if (!locked)
		message = "*****"
	dat += "<HR>\n>[message]<BR>\n<A href='byond://?src=[REF(src)];type=1'>1</A>-<A href='byond://?src=[REF(src)];type=2'>2</A>-<A href='byond://?src=[REF(src)];type=3'>3</A><BR>\n \
			<A href='byond://?src=[REF(src)];type=4'>4</A>-<A href='byond://?src=[REF(src)];type=5'>5</A>-<A href='byond://?src=[REF(src)];type=6'>6</A><BR>\n \
			<A href='byond://?src=[REF(src)];type=7'>7</A>-<A href='byond://?src=[REF(src)];type=8'>8</A>-<A href='byond://?src=[REF(src)];type=9'>9</A><BR>\n \
			<A href='byond://?src=[REF(src)];type=R'>R</A>-<A href='byond://?src=[REF(src)];type=0'>0</A>-<A href='byond://?src=[REF(src)];type=E'>E</A><BR>\n</TT>"
	user << browse(HTML_SKELETON(dat), "window=caselock;size=300x280")

/obj/item/storage/secure/Topic(href, href_list)
	..()
	if (usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
				l_code = code
				l_set = 1
			else if ((code == l_code) && (l_set == 1))
				atom_storage.locked = FALSE
				cut_overlays()
				add_overlay(icon_opened)
				code = null
			else
				code = "ERROR"
		else
			if ((href_list["type"] == "R") && (!l_setshort))
				atom_storage.locked = TRUE
				cut_overlays()
				code = null
				atom_storage.hide_contents(usr)
			else
				code += "[sanitize_text(href_list["type"])]"
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
	icon_state = "sec-case"
	inhand_icon_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/case_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/case_righthand.dmi'
	desc = "A large briefcase with a digital locking system."
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")

/obj/item/storage/secure/briefcase/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/briefcase/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 21
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15
	item_flags = ISWEAPON

/obj/item/storage/secure/briefcase/syndie/PopulateContents()
	..()
	for(var/iterator in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)

/obj/item/storage/secure/briefcase/hitman/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/melee/classic_baton/police/telescopic(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/bodybag(src)
	new /obj/item/soap/nanotrasen(src)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	desc = "Excellent for securing things away from grubby hands."
	layer = ABOVE_WINDOW_LAYER
	w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/secure/safe, 32)

/obj/item/storage/secure/safe/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(cant_hold_list = list(/obj/item/storage/secure/briefcase))
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user, list/modifiers)
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
There appears to be a small amount of surface corrosion. It doesn't look like it could withstand much of an explosion. \
It remains quite flush against the wall, and there only seems to be enough room to fit something as slim as an ID card."
	can_hack_open = FALSE
	armor_type = /datum/armor/safe_caps_spare
	max_integrity = 300
	color = "#ffdd33"

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/secure/safe/caps_spare, 32)


/datum/armor/safe_caps_spare
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 70
	fire = 80
	acid = 70

/obj/item/storage/secure/safe/caps_spare/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/card/id/))
	l_code = SSjob.spare_id_safe_code
	l_set = TRUE
	atom_storage.locked = TRUE
	update_appearance()

/obj/item/storage/secure/safe/caps_spare/PopulateContents()
	new /obj/item/card/id/captains_spare(src)

/obj/item/storage/secure/safe/caps_spare/rust_heretic_act()
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = MELEE, armour_penetration = 100)
	return TRUE
