/datum/keybinding/human
    category = CATEGORY_HUMAN
    weight = WEIGHT_MOB


/datum/keybinding/human/quick_equip
    key = "E"
    name = "quick_equip"
    full_name = "Quick equip"
    description = ""

/datum/keybinding/human/quick_equip/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.quick_equip()
    return TRUE
