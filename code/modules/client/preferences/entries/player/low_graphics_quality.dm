/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/low_graphics_quality
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "lowgraphicsquality"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/low_graphics_quality/apply_to_client(client/client, value)
	if (!client)
		return
	for (var/atom/movable/screen/plane_master/pm in client.screen)
		pm.backdrop(client.mob)
