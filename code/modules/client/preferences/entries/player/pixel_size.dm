/datum/preference/numeric/pixel_size
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "pixel_size"
	preference_type = PREFERENCE_PLAYER

	minimum = 0
	maximum = 3

	step = 0.5

/datum/preference/numeric/pixel_size/create_default_value()
	return 0

/datum/preference/numeric/pixel_size/apply_to_client(client/client, value)
	client?.view_size?.resetFormat()
