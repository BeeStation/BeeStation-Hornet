/datum/preference/toggle/chat_bankcard
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_bankcard"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_dead
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_dead"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_dead/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	return is_admin(preferences.parent)

/datum/preference/toggle/chat_followghostmindless
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_followghostmindless"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_ghostears
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostears"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/chat_ghostlaws
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostlaws"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_ghostpda
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostpda"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_ghostradio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostradio"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_ghostsight
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostsight"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/chat_ghostwhisper
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ghostwhisper"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/chat_ooc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_ooc"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_prayer
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_prayer"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_prayer/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	return is_admin(preferences.parent)

/datum/preference/toggle/chat_pullr
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_pullr"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_radio"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/chat_radio/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	return is_admin(preferences.parent)
