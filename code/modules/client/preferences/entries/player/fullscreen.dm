/datum/preference/toggle/fullscreen
	db_key = "fullscreen"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/fullscreen/apply_to_client(client/client, value)
	if(value)
		winset(client, "mainwindow", "menu=;is-fullscreen=true")
		winset(client, "status_bar_wide", "is-visible=false")
		winset(client, "mainwindow", "on-status=\".winset \\\"\[\[*]]=\\\"\\\" ? status_bar.text=\[\[*]] status_bar.is-visible=true : status_bar.is-visible=false\\\"\"")
	else
		winset(client, "mainwindow", "menu=\"menu\";is-fullscreen=false")
		winset(client, "status_bar_wide", "is-visible=true")
		winset(client, "mainwindow", "on-status=\".winset \\\"status_bar_wide.text = \[\[*]]\\\"\"")
		winset(client, "status_bar", "is-visible=false")

	client.attempt_auto_fit_viewport()

/datum/preference/toggle/fullscreen/proc/fix_mapsize(client/client)
	var/windowsize = winget(client, "split", "size")
	if (!client || !windowsize)
		return
	var/split = findtext(windowsize, "x")
	winset(client, "split", "size=[copytext(windowsize, 1, split)]x[text2num(copytext(windowsize, split + 1)) - 16]")
	client.fit_viewport()
