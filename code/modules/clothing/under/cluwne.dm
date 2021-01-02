/obj/item/clothing/under/cluwne
    name = "clown suit"
    desc = "<i>'HONK!'</i>"
    icon_state = "greenclown"
    item_state = "greenclown"
    resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
    item_flags = DROPDEL
    can_adjust = 0

/obj/item/clothing/under/cluwne/Initialize()
    .=..()
    ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/under/cluwne/equipped(mob/living/carbon/user, slot)
    if(!ishuman(user))
        return
    if(slot == ITEM_SLOT_ICLOTHING)
        var/mob/living/carbon/human/H = user
        H.dna.add_mutation(CLUWNEMUT)
    return ..()
