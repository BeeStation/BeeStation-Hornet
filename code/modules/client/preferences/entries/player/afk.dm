/datum/preference/numeric/afk_time
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "afk_time"
	preference_type = PREFERENCE_PLAYER
	minimum = 3
	maximum = 10

/datum/preference/numeric/afk_time/create_default_value()
	return 5
