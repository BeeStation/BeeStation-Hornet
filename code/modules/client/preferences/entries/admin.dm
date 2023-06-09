/datum/preference/color/asay_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "asaycolor"
	preference_type = PREFERENCE_PLAYER

/datum/preference/color/asay_color/create_default_value()
	return DEFAULT_ASAY_COLOR

/datum/preference/color/asay_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent) && CONFIG_GET(flag/allow_admin_asaycolor)
