/datum/component/haircolor_clothing/Initialize()
    RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(onEquip))
    RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(update_color))

/datum/component/haircolor_clothing/proc/onEquip(obj/item/I, mob/living/carbon/human/H, slot)
    SIGNAL_HANDLER
    if(ishuman(H) && slot == ITEM_SLOT_HEAD)
        update_color(I, H)
        H.update_inv_head() //Color might have been changed

/datum/component/haircolor_clothing/proc/update_color(obj/item/I, mob/living/carbon/human/H)
    SIGNAL_HANDLER
    if(ishuman(H))
        I.add_atom_colour("#[H.hair_color]", FIXED_COLOUR_PRIORITY)

/datum/component/haircolor_clothing/Destroy()
    UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,COMSIG_ATOM_UPDATE_ICON))
    return ..()
