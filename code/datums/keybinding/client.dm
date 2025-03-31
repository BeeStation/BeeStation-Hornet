/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/get_help
	keys = list("F1")
	name = "get_help"
	full_name = "Get Help"
	description = "Ask an admin or mentor for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/get_help/down(client/user)
	. = ..()
	if(.)
		return
	user.adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	keys = list("F2")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.auto")
	return TRUE


/datum/keybinding/client/toggleminimalhud
	keys = list("F12")
	name = "toggleminimalhud"
	full_name = "Toggle Minimal HUD"
	description = "Toggle the minimalized state of your hud."
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/toggleminimalhud/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE


/datum/keybinding/client/zoomin
	keys = list("\]")
	name = "zoomin"
	full_name = "Zoom In"
	description = "Temporary switch icon scaling mode to 4x until unpressed"
	keybind_signal = COMSIG_KB_CLIENT_ZOOMIN_DOWN

/datum/keybinding/client/zoomin/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, "mapwindow.map", "zoom=[PIXEL_SCALING_4X]")

/datum/keybinding/client/zoomin/up(client/user)
	winset(user, "mapwindow.map", "zoom=[user.prefs.read_player_preference(/datum/preference/numeric/pixel_size)]")

/datum/keybinding/client/fullscreen
	keys = list("F11")
	name = "fullscreen"
	full_name = "Toggle Fullscreen"
	description = "Switch between windowed and fullscreen mode."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN

/datum/keybinding/client/fullscreen/down(client/user)
	. = ..()
	if (.)
		return
	var/previous_result = user.prefs?.read_player_preference(/datum/preference/toggle/fullscreen)
	user.prefs?.update_preference(/datum/preference/toggle/fullscreen, !previous_result)
