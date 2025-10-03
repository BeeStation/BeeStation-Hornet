/datum/preference/toggle/hotkeys
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "hotkeys"
	preference_type = PREFERENCE_PLAYER
	priority = PREFERENCE_PRIORITY_HOTKEYS

/datum/preference/toggle/hotkeys/apply_to_client(client/client, value)
	client.hotkeys = value
	client.set_macros()
