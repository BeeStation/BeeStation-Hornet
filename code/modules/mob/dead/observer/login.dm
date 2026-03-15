/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	if(IsAdminGhost(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs?.unlock_content)
		ghost_orbit = client.prefs.read_player_preference(/datum/preference/choiced/ghost_orbit)
