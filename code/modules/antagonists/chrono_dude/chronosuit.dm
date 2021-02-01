/*
	- CHRONO SUIT -

	CONTENTS
		The helm and suit (those ugly things that look like aluminum)
		Some protection code

*/

/obj/item/clothing/head/helmet/space/chronos
	name = "Chronosuit Helmet"
	desc = "A white helmet with an opaque blue visor."
	icon_state = "chronohelmet"
	item_state = "chronohelmet"
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/protected = FALSE

/obj/item/clothing/head/helmet/space/chronos/proc/protection_check(mob/user)
	return !(protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))

/obj/item/clothing/head/helmet/space/chronos/equipped(mob/living/user, slot)
	..()
	if (!protection_check(user))
		to_chat(user, "<span class='warning'>As you try to equipt it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/obj/item/clothing/suit/space/chronos
	name = "Chronosuit"
	desc = "An advanced spacesuit equipped with time-bluespace teleportation and anti-compression technology."
	icon_state = "chronosuit"
	item_state = "chronosuit"
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/protected = FALSE

/obj/item/clothing/suit/space/chronos/proc/protection_check(mob/user)
	if (protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))
		return FALSE
	return TRUE

/obj/item/clothing/suit/space/chronos/equipped(mob/living/user, slot)
	..()
	if (!protection_check(user))
		to_chat(user, "<span class='warning'>As you try to equipt it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/*
 * OUTFIT
 */

/datum/outfit/chrono_agent
	name = "Timeline Correction Agent"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/chrono_eraser
	belt = /obj/item/holosign_creator/chrono_trap
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	l_pocket = /obj/item/chrono_tele
	r_pocket = /obj/item/click_remote
	id = /obj/item/card/id

/datum/outfit/chrono_agent/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/implant/dust_self/L = new/obj/item/implant/dust_self(H)
	L.implant(H, null, 1)

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "silver"
	W.access = get_all_accesses()
	W.assignment = "Timeline Correction Agent"
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

	if (!visualsOnly)
		var/obj/item/clothing/suit/space/chronos/suit = H.get_item_by_slot(SLOT_WEAR_SUIT)
		if (suit)
			suit.protected = TRUE
		var/obj/item/clothing/head/helmet/space/chronos/helmet = H.get_item_by_slot(SLOT_HEAD)
		if (helmet)
			helmet.protected = TRUE
		var/obj/item/chrono_eraser/eraser = H.get_item_by_slot(SLOT_BACK)
		if (eraser)
			eraser.protected = TRUE
		var/obj/item/holosign_creator/chrono_trap/trap = H.get_item_by_slot(SLOT_BELT)
		if (trap)
			trap.protected = TRUE
		var/obj/item/chrono_tele/tele = H.get_item_by_slot(SLOT_L_STORE)
		if (tele)
			tele.protected = TRUE
		var/obj/item/click_remote/remote = H.get_item_by_slot(SLOT_R_STORE)
		if (remote)
			remote.protected = TRUE
