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

/datum/preference/choiced/show_balloon_alerts
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "show_balloon_alerts"
	preference_type = PREFERENCE_PLAYER

/datum/preference/choiced/show_balloon_alerts/create_default_value()
	return BALLOON_ALERT_ALWAYS

/datum/preference/choiced/show_balloon_alerts/init_possible_values()
	return list(BALLOON_ALERT_ALWAYS, BALLOON_ALERT_WITH_CHAT, BALLOON_ALERT_NEVER)

/datum/preference/toggle/enable_runechat_looc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "enable_runechat_looc"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/enable_runechat_looc/is_accessible(datum/preferences/preferences,  ignore_page = TRUE)
	. = ..()
	if(!CONFIG_GET(flag/looc_enabled))
		return FALSE
	if(!preferences.read_player_preference(/datum/preference/toggle/enable_runechat))
		return FALSE
