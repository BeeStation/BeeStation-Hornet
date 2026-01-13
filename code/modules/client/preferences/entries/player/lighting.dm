/datum/preference/numeric/bloom
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "bloom_amount"
	preference_type = PREFERENCE_PLAYER
	minimum = 0
	maximum = 100

/datum/preference/numeric/bloom/create_default_value()
	return 0

/datum/preference/numeric/bloom/apply_to_client(client/client, value)
	client.mob?.update_sight()

/datum/preference/numeric/lighting_saturation
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "lighting_saturation"
	preference_type = PREFERENCE_PLAYER
	minimum = 0
	maximum = 2
	step = 0.01

/datum/preference/numeric/lighting_saturation/create_default_value()
	return 1.1

/datum/preference/numeric/lighting_saturation/apply_to_client(client/client, value)
	client.mob?.update_sight()

