/// The color of a PDA
/datum/preference/color/pda_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "pda_color"
	preference_type = PREFERENCE_PLAYER

/datum/preference/color/pda_color/create_default_value()
	return COLOR_OLIVE

/// The visual style of a PDA
/datum/preference/choiced/pda_theme
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "pda_theme"
	preference_type = PREFERENCE_PLAYER

/datum/preference/choiced/pda_theme/init_possible_values()
	return GLOB.ntos_device_themes_default
