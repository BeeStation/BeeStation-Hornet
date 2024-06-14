/datum/preference/color/asay_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "asaycolor"
	preference_type = PREFERENCE_PLAYER

/datum/preference/color/asay_color/create_default_value()
	return DEFAULT_ASAY_COLOR

/datum/preference/color/asay_color/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	return is_admin(preferences.parent) && CONFIG_GET(flag/allow_admin_asaycolor)

/datum/preference/toggle/announce_login
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "announce_login"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/announce_login/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent)

/datum/preference/toggle/combohud_lighting
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "combohud_lighting"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/combohud_lighting/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent)
