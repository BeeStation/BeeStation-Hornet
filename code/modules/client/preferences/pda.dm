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

/datum/preference/choiced/pda_theme/deserialize(input, datum/preferences/preferences)
	for(var/key in GLOB.ntos_device_themes_default) // if only there was a associative list flip proc that I could locate. Unfortunately, I could not locate one.
		if(GLOB.ntos_device_themes_default[key] == input)
			return key
	return "NtOS Default"

/datum/preference/choiced/pda_theme/serialize(input)
	return GLOB.ntos_device_themes_default[sanitize_inlist(input, GLOB.ntos_device_themes_default, "NtOS Default")]

/datum/preference/choiced/pda_theme/create_default_value()
	return "NtOS Default"

/datum/preference/choiced/pda_theme/init_possible_values()
	return GLOB.ntos_device_themes_default_content
