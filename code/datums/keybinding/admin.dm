/datum/keybinding/admin
    category = CATEGORY_ADMIN
    weight = WEIGHT_ADMIN


/datum/keybinding/admin/admin_say
    key = "F3"
    name = "admin_say"
    full_name = "Admin say"
    description = "Talk with other admins."
    
/datum/keybinding/admin/admin_say/down(client/user)
    user.get_asay()
    return TRUE


/datum/keybinding/admin/mentor_say
    key = "F4"
    name = "mentor_say"
    full_name = "Mentor say"
    description = "Speak with other mentors."
    
/datum/keybinding/admin/mentor_say/down(client/user)
    user.get_msay()
    return TRUE


/datum/keybinding/admin/dead_say
    key = "F5"
    name = "dead_say"
    full_name = "Dead chat"
    description = "Speak with the dead."
    
/datum/keybinding/admin/dead_say/down(client/user)
    user.get_dsay()
    return TRUE

