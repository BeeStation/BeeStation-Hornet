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


/datum/keybinding/human/holster
    key = "H"
    name = "holster"
    full_name = "Holster"
    description = ""

/datum/keybinding/human/holster/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.holster()
    return TRUE


/datum/keybinding/human/unique_action
    key = "Space"
    name = "unique_action"
    full_name = "Perform unique action"
    description = ""

/datum/keybinding/human/unique_action/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.unique_action()
    return TRUE