/mob/dead/observer/Login()
	..()

	ghost_accs = client.prefs.read_player_preference(/datum/preference/choiced/ghost_accessories)
	ghost_others = client.prefs.read_player_preference(/datum/preference/choiced/ghost_others)
	var/preferred_form = null

	if(IsAdminGhost(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.read_player_preference(/datum/preference/choiced/ghost_form)
		ghost_orbit = client.prefs.read_player_preference(/datum/preference/choiced/ghost_orbit)

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	update_icon(new_form = preferred_form)
	updateghostimages()
