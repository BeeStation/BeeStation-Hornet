/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/ambient_occlusion
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "ambientocclusion"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/ambient_occlusion/apply_to_client(client/client, value)
	//main
	var/atom/movable/screen/plane_master/game_world/plane_master = locate() in client?.screen
	if (!plane_master)
		return
	plane_master.backdrop(client.mob)
	//non integral
	var/atom/movable/screen/plane_master/non_integral/plane_master_non_integral = locate() in client?.screen
	if (!plane_master_non_integral)
		return
	plane_master_non_integral.backdrop(client.mob)
