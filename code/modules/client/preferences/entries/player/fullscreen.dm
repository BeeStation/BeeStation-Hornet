/datum/preference/toggle/fullscreen
	db_key = "fullscreen"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/fullscreen/apply_to_client(client/client, value)
	if(value)
		winset(client, "mainwindow", "menu=;is-fullscreen=true")
	else
		winset(client, "mainwindow", "menu=\"menu\";is-fullscreen=false")

	// The status bar floats over the map in both modes
	winset(client, "mainwindow", "on-status=\".winset \\\"\[\[*]]=\\\"\\\" ? status_bar.text=\[\[*]] status_bar.is-visible=true : status_bar.is-visible=false\\\"\"")

	client.attempt_auto_fit_viewport()
