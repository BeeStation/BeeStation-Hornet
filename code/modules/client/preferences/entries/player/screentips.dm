/// The scaling method to show the world in, e.g. nearest neighbor
/datum/preference/toggle/screentips
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "screentips"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/screentips/apply_to_client(client/client, value)
	client?.show_screentips = value
	if (!value)
		client.mob.hud_used.screentip.maptext = null
