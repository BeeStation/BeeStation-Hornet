/datum/preference/toggle/auto_fit_viewport
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "auto_fit_viewport"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/auto_fit_viewport/apply_to_client_updated(client/client, value)
	INVOKE_ASYNC(client, /client/proc/fit_viewport)
