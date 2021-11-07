/datum/component/haircolor_clothing/Initialize()
    RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/onEquip)

/datum/component/haircolor_clothing/proc/onEquip(obj/item/I, mob/living/carbon/human/H, slot)
    SIGNAL_HANDLER
    if(ishuman(H) && slot == ITEM_SLOT_HEAD)
        update_color(I, H)
        H.update_inv_head() //Color might have been changed

/datum/component/haircolor_clothing/proc/update_color(obj/item/I, mob/living/carbon/human/H)
    if(ishuman(H))
        I.add_atom_colour("#[H.hair_color]", FIXED_COLOUR_PRIORITY)
