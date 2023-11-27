/datum/preference/toggle/bloom
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "see_bloom"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/bloom/apply_to_client(client/client, value)
	client.mob?.update_sight()
