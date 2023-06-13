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


/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"
	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.read_player_preference(/datum/preference/color/ooc_color)) as color|null
	if(new_ooccolor)
		prefs.update_preference(/datum/preference/color/ooc_color, new_ooccolor)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set OOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"
	prefs.update_preference(/datum/preference/color/ooc_color, DEFAULT_BONUS_OOC_COLOR)
