/datum/preference/numeric/fps
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "clientfps"
	preference_type = PREFERENCE_PLAYER

	minimum = -1
	maximum = 240

/datum/preference/numeric/fps/apply_to_client(client/client, value)
	client.fps = (value < 0) ? RECOMMENDED_FPS : value

/datum/preference/numeric/fps/compile_constant_data()
	var/list/data = ..()

	data["recommended_fps"] = RECOMMENDED_FPS

	return data
