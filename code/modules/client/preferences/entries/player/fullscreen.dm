/datum/preference/toggle/fullscreen
	db_key = "fullscreen"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/fullscreen/apply_to_client(client/client, value)
	if (isobserver(client?.mob))
		client?.mob.hud_used?.show_hud()
	if (value)
		// Delete the menu
		winset(client, "mainwindow", "menu=\"\"")
		// Switch to the cool status bar
		winset(client, "mainwindow", "on-status=\".winset \\\"\[\[*]]=\\\"\\\" ? status_bar.text=\[\[*]] status_bar.is-visible=true : status_bar.is-visible=false\\\"\"")
		winset(client, "status_bar_wide", "is-visible=false")
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
		INVOKE_ASYNC(client, TYPE_VERB_REF(/client, fit_viewport))
	else
		// Restore the menu
		winset(client, "mainwindow", "menu=\"menu\"")
		// Switch to the lame status bar
		winset(client, "mainwindow", "on-status=\".winset \\\"status_bar_wide.text = \[\[*]]\\\"\"")
		winset(client, "status_bar", "is-visible=false")
		winset(client, "status_bar_wide", "is-visible=true")
		// Exit fullscreen mode
		winset(client, "mainwindow","titlebar=true")
		winset(client, "mainwindow","can-resize=true")
		// Fix the mapsize, turning off statusbar doesn't update scaling
		INVOKE_ASYNC(src, PROC_REF(fix_mapsize), client)

/datum/preference/toggle/fullscreen/proc/fix_mapsize(client/client)
	var/windowsize = winget(client, "split", "size")
	if (!client || !windowsize)
		return
	var/split = findtext(windowsize, "x")
	winset(client, "split", "size=[copytext(windowsize, 1, split)]x[text2num(copytext(windowsize, split + 1)) - 16]")
	client.fit_viewport()
