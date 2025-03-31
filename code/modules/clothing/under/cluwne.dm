/obj/item/clothing/under/cluwne
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon = 'icons/obj/clothing/under/civilian.dmi'
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'
	icon_state = "greenclown"
	item_state = "greenclown"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	can_adjust = 0

/obj/item/clothing/under/cluwne/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/under/cluwne/equipped(mob/living/carbon/user, slot)
	if(!user.has_dna())
		return
	if(slot == ITEM_SLOT_ICLOTHING)
		var/mob/living/carbon/C = user
		C.dna.add_mutation(/datum/mutation/cluwne)
	return ..()
