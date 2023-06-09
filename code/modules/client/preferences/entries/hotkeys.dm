/datum/preference/toggle/hotkeys
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "hotkeys"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/hotkeys/apply_to_client(client/client, value)
	client.hotkeys = value
