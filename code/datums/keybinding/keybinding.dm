/datum/keybinding
    var/key
    var/name
    var/full_name
    var/description = ""
    var/category = CATEGORY_MISC
    var/weight = WEIGHT_LOWEST

/datum/keybinding/proc/down(client/user)
    return EF_FALSE

/datum/keybinding/proc/up(client/user)
    return EF_FALSE
