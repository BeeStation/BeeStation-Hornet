/datum/keybinding/living
    category = CATEGORY_HUMAN
    weight = WEIGHT_MOB


/datum/keybinding/living/resist
    key = "B"
    name = "resist"
    full_name = "Resist"
    description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"

/datum/keybinding/living/resist/down(client/user)
    var/mob/living/L = user.mob
    L.resist()
    return TRUE

