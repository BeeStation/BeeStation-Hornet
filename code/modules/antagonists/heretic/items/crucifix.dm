/obj/item/clothing/neck/crucifix
	name = "crucifix"
	desc = "In the event that one of those you falsely accused is, in fact, a real witch, this will ward you against their curses."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/objects.dmi'
	icon_state = "crucifix"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/crucifix/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK && istype(user))
		ADD_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/rosary
	name = "rosary beads"
	desc = "A wooden crucifix meant to ward off curses and hexes."
	resistance_flags = FLAMMABLE
	icon_state = "rosary"
