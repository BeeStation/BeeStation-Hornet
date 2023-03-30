/datum/preference/toggle/enable_runechat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "chat_on_map"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/enable_runechat_non_mobs
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "see_chat_non_mob"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/see_rc_emotes
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "see_rc_emotes"
	preference_type = PREFERENCE_PLAYER

/datum/preference/numeric/max_chat_length
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "max_chat_length"
	preference_type = PREFERENCE_PLAYER

	minimum = 1
	maximum = CHAT_MESSAGE_MAX_LENGTH

/datum/preference/numeric/max_chat_length/create_default_value()
	return CHAT_MESSAGE_MAX_LENGTH
