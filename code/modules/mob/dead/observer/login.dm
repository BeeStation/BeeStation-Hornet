/mob/dead/observer/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	ghost_accs = client.prefs ? client.prefs.read_player_preference(/datum/preference/choiced/ghost_accessories) : GHOST_ACCS_DEFAULT_OPTION
	ghost_others = client.prefs ? client.prefs.read_player_preference(/datum/preference/choiced/ghost_others) : GHOST_OTHERS_DEFAULT_OPTION
	var/preferred_form = null

	if(IsAdminGhost(src))
		has_unlimited_silicon_privilege = 1

	if(client.prefs?.unlock_content)
		preferred_form = client.prefs.read_player_preference(/datum/preference/choiced/ghost_form)
		ghost_orbit = client.prefs.read_player_preference(/datum/preference/choiced/ghost_orbit)

	update_icon(new_form = preferred_form)
	updateghostimages()
