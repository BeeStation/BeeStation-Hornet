/datum/preference/toggle/deadmin_always
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_always"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/deadmin_always/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent)

/datum/preference/toggle/deadmin_always/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_deadmin_players),
	)

/datum/preference/toggle/deadmin_antagonist
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_antagonist"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/deadmin_antagonist/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_antagonist/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_deadmin_antagonists),
	)

/datum/preference/toggle/deadmin_position_head
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_head"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/deadmin_position_head/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_head/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_deadmin_heads),
	)

/datum/preference/toggle/deadmin_position_security
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_security"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/deadmin_position_security/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_security/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_deadmin_security),
	)

/datum/preference/toggle/deadmin_position_silicon
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "deadmin_position_silicon"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/deadmin_position_silicon/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && is_admin(preferences.parent) && !preferences.read_player_preference(/datum/preference/toggle/deadmin_always)

/datum/preference/toggle/deadmin_position_silicon/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_deadmin_silicons),
	)
