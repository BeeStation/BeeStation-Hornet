/datum/preference/toggle/fullscreen
	db_key = "fullscreen"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/fullscreen/apply_to_client(client/client, value)
	if (isobserver(client?.mob))
		client?.mob.hud_used?.show_hud()
	if (value)
		winset(client,"mainwindow","Titlebar=false")
		winset(client,"mainwindow","can-resize=false")
		// Set it to minimized first because otherwise it doesn't enter fullscreen properly
		// This line is important, and the game won't properly enter fullscreen mode otherwise
		winset(client,"mainwindow","is-minimized=true")
		winset(client,"mainwindow","is-maximized=true")
	else
		winset(client,"mainwindow","Titlebar=true")
		winset(client,"mainwindow","can-resize=true")
