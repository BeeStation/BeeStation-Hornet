/datum/keybinding/client
    category = CATEGORY_CLIENT
    weight = WEIGHT_HIGHEST


/datum/keybinding/client/get_help
    key = "F1"
    name = "get_help"
    full_name = "Get Help"
    description = "Ask an admin or mentor for help."

/datum/keybinding/client/get_help/down(client/user)
    user.choosehelp()
    return TRUE


/datum/keybinding/client/screenshot
    key = "F2"
    name = "screenshot"
    full_name = "Screenshot"
    description = "Take a screenshot."
    
/datum/keybinding/client/screenshot/down(client/user)
    winset(src, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
    return TRUE