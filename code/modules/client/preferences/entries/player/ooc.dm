/// The color admins will speak in for OOC.
/datum/preference/color/ooc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "ooccolor"
	preference_type = PREFERENCE_PLAYER

/datum/preference/color/ooc_color/create_default_value()
	return DEFAULT_BONUS_OOC_COLOR

/datum/preference/color/ooc_color/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content
