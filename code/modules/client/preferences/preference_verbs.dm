/client/verb/open_character_preferences()
	set category = "Preferences"
	set name = "Character Preferences"
	set desc = "Open Character Preferences"

	var/datum/preferences/preferences = usr?.client?.prefs
	if (!preferences)
		return

	preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)

/client/verb/open_game_preferences()
	set category = "Preferences"
	set name = "Game Preferences"
	set desc = "Open Game Preferences"

	var/datum/preferences/preferences = usr?.client?.prefs
	if (!preferences)
		return

	preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)
