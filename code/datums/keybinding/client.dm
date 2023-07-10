/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/get_help
	key = "F1"
	name = "get_help"
	full_name = "Get Help"
	description = "Ask an admin or mentor for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/get_help/down(client/user)
	. = ..()
	if(.)
		return
	user.get_adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	key = "F2"
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE


/datum/keybinding/client/toggleminimalhud
	key = "F12"
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
	key = "\]"
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
	winset(user, "mapwindow.map", "zoom=[user.prefs.pixel_size]")

/datum/keybinding/client/say
	key = "T"
	name = "say"
	full_name = "Say"
	description = "Open the speech input."
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/radio
	key = "Y"
	name = "radio"
	full_name = "Radio"
	description = "Open the speech input in Radio mode."
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/me
	key = "M"
	name = "me"
	full_name = "Me"
	description = "Open the speech input in Me mode."
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/ooc
	key = "O"
	name = "ooc"
	full_name = "OOC"
	description = "Open the speech input in OOC mode."
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/looc
	key = "U"
	name = "looc"
	full_name = "LOOC"
	description = "Open the speech input in LOOC mode."
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN
