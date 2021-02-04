/datum/keybinding/client
    category = CATEGORY_CLIENT
    weight = WEIGHT_HIGHEST


/datum/keybinding/client/get_help
    key = "F1"
    name = "get_help"
    full_name = "Get Help"
    description = "Ask an admin or mentor for help."

/datum/keybinding/client/get_help/down(client/user)
    user.get_adminhelp()
    return TRUE


/datum/keybinding/client/screenshot
    key = "F2"
    name = "screenshot"
    full_name = "Screenshot"
    description = "Take a screenshot."

/datum/keybinding/client/screenshot/down(client/user)
    winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
    return TRUE


/datum/keybinding/client/toggleminimalhud
    key = "F12"
    name = "toggleminimalhud"
    full_name = "Toggle Minimal HUD"
    description = "Toggle the minimalized state of your hud."

/datum/keybinding/client/toggleminimalhud/down(client/user)
    user.mob.button_pressed_F12()
    return TRUE


/datum/keybinding/client/zoomin
	key = "\]"
	name = "zoomin"
	full_name = "Zoom In"
	description = "Temporary switch icon scaling mode to 4x until unpressed"

/datum/keybinding/client/zoomin/down(client/user)
	winset(user, "mapwindow.map", "zoom=[PIXEL_SCALING_4X]")

/datum/keybinding/client/zoomin/up(client/user)
	winset(user, "mapwindow.map", "zoom=[user.prefs.pixel_size]")
