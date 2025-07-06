/datum/preference/toggle/fullscreen
	db_key = "fullscreen"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/fullscreen/apply_to_client(client/client, value)
	if(client.byond_version <= 515 || client.byond_build <= 1630)
		if (value)
			// Delete the menu
			winset(client, "mainwindow", "menu=\"\"")
			// Switch to fullscreen mode
			winset(client, "mainwindow","titlebar=false")
			winset(client, "mainwindow","can-resize=false")
			// Set it to minimized first because otherwise it doesn't enter fullscreen properly
			// This line is important, and the game won't properly enter fullscreen mode otherwise
			winset(client, "mainwindow","is-minimized=true")
			winset(client, "mainwindow","is-maximized=true")
			// Set the main window's size
			winset(client, null, "split.size=mainwindow.size")
			// Fit the viewport
			INVOKE_ASYNC(client, TYPE_PROC_REF(/client, fit_viewport))
		else
			// Restore the menu
			winset(client, "mainwindow", "menu=\"menu\"")
			// Exit fullscreen mode
			winset(client, "mainwindow","titlebar=true")
			winset(client, "mainwindow","can-resize=true")
			winset(client, "mainwindow","is-maximized=true")
			// Fix the mapsize, turning off statusbar doesn't update scaling
			INVOKE_ASYNC(src, PROC_REF(fix_mapsize), client)
	else
		if(value)
			winset(client, "mainwindow", "menu=;is-fullscreen=true")
		else
			winset(client, "mainwindow", "menu=\"menu\";is-fullscreen=false")

		if(client.fully_created)
			INVOKE_ASYNC(client, TYPE_PROC_REF(/client, fit_viewport))
		else
			addtimer(CALLBACK(client, TYPE_PROC_REF(/client, fit_viewport), 1 SECONDS))

/datum/preference/toggle/fullscreen/proc/fix_mapsize(client/client)
	var/windowsize = winget(client, "split", "size")
	if (!client || !windowsize)
		return
	var/split = findtext(windowsize, "x")
	winset(client, "split", "size=[copytext(windowsize, 1, split)]x[text2num(copytext(windowsize, split + 1)) - 16]")
	client.fit_viewport()
