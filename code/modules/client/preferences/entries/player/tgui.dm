/datum/preference/toggle/tgui_fancy
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_fancy"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_fancy/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

/// Changes layout in some UI's, like Vending, Smartfridge etc. Making it list or grid
/datum/preference/choiced/tgui_layout
	db_key = "tgui_layout"
	preference_type = PREFERENCE_PLAYER
	disable_serialization = TRUE //Will break during the TM otherwise

/datum/preference/choiced/tgui_layout/init_possible_values()
	return list(
		TGUI_LAYOUT_GRID,
		TGUI_LAYOUT_LIST,
	)

/datum/preference/choiced/tgui_layout/create_default_value()
	return TGUI_LAYOUT_LIST

/datum/preference/choiced/tgui_layout/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

/datum/preference/choiced/tgui_layout/smartfridge
	db_key = "tgui_layout_smartfridge"

/datum/preference/choiced/tgui_layout/create_default_value()
	return TGUI_LAYOUT_GRID

/datum/preference/toggle/tgui_lock
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_lock"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_lock/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

// Determines if input boxes are in tgui or old fashioned
/datum/preference/toggle/tgui_input
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_input"
	preference_type = PREFERENCE_PLAYER

/// Large button preference. Error text is in tooltip.
/datum/preference/toggle/tgui_input_large
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_input_large"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_input_large/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/// Swapped button state - sets buttons to SS13 traditional SUBMIT/CANCEL
/datum/preference/toggle/tgui_input_swapped
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_input_swapped"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_input_swapped/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/// TGUI Say vs Classic Say
/datum/preference/toggle/tgui_say
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_say"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/tgui_say/apply_to_client(client/client, value)
	if(value)
		client.tgui_say?.load()
	else
		client.tgui_say?.close()
	// Update what the macro will open
	client.update_special_keybinds()

/// Light mode for tgui say
/datum/preference/toggle/tgui_say_light_mode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_say_light_mode"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_say_light_mode/apply_to_client(client/client)
	client.tgui_say?.load()

/datum/preference/toggle/tgui_say_show_prefix
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_say_show_prefix"
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_say_show_prefix/apply_to_client(client/client)
	client.tgui_say?.load()

/datum/preference/toggle/tgui_asay
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "tgui_asay"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/tgui_asay/apply_to_client(client/client, value)
	if(value)
		client.tgui_asay?.load()
	else
		client.tgui_asay?.close()
	// Update what the macro will open
	client.update_special_keybinds()

/datum/preference/toggle/tgui_asay/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && (is_admin(preferences.parent) || preferences.parent.mentor_datum)
