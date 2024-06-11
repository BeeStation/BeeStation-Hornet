/obj/item/clothing/head/costume/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = null
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/costume/pirate
	var/datum/language/piratespeak/L = new

/obj/item/clothing/head/costume/pirate/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_HEAD)
		user.grant_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "You suddenly know how to speak like a pirate!")

/obj/item/clothing/head/costume/pirate/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_HEAD) == src && !QDELETED(src)) //This can be called as a part of destroy
		user.remove_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "You can no longer speak like a pirate.")

/obj/item/clothing/head/costume/pirate/captain
	name = "pirate captain hat"
	icon_state = "hgpiratecap"
	item_state = null

/obj/item/clothing/head/costume/pirate/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = null
	dynamic_hair_suffix = ""
