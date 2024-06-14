/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	keys = list("T")
	name = "say"
	full_name = "IC Say"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/radio
	keys = list("Y")
	name = "radio"
	full_name = "IC Radio Say"
	description = "Open the speech input in Radio mode."
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/communication/me
	keys = list("M")
	name = "me"
	full_name = "Custom Emote (/Me)"
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/communication/ooc
	keys = list("O")
	name = "ooc"
	full_name = "Out Of Character Say (OOC)"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/looc
	keys = list("U")
	name = "looc"
	full_name = "Local Out of Character Say (LOOC)"
	description = "Open the speech input in LOOC mode."
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN
