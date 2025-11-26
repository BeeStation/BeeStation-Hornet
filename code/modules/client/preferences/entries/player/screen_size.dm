/// The scaling method to show the world in, e.g. nearest neighbor
/datum/preference/choiced/screen_size
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "screen_size"
	preference_type = PREFERENCE_PLAYER

/datum/preference/choiced/screen_size/create_default_value()
	return SCREEN_SIZE_NORMAL

/datum/preference/choiced/screen_size/init_possible_values()
	return list(SCREEN_SIZE_NORMAL, SCREEN_SIZE_SMALL, SCREEN_SIZE_TINY)

/datum/preference/choiced/screen_size/apply_to_client(client/client, value)
	// Can't change it here
	if (istype(client.mob, /mob/dead/new_player))
		return
	client.view_size?.setDefault(value)
