/datum/preference/toggle/deadmin_always
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_always"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/deadmin_always/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent)

/datum/preference/toggle/deadmin_antagonist
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_antagonist"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/deadmin_antagonist/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_head
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_head"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/deadmin_position_head/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_security
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_security"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/deadmin_position_security/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_silicon
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_silicon"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/deadmin_position_silicon/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)
