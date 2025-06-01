/// UI style preference
/datum/preference/choiced/ui_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	preference_type = PREFERENCE_PLAYER
	db_key = "ui_style"
	should_generate_icons = TRUE

/datum/preference/choiced/ui_style/init_possible_values()
	var/list/values = list()

	for (var/style in GLOB.available_ui_styles)
		var/icons = GLOB.available_ui_styles[style]

		var/datum/universal_icon/icon = uni_icon(icons, "hand_l")
		icon.crop(1 - world.icon_size, 1, world.icon_size, world.icon_size)
		icon.blend_icon(uni_icon(icons, "hand_r"), ICON_OVERLAY)

		values[style] = icon

	return values

/datum/preference/choiced/ui_style/create_default_value()
	return GLOB.available_ui_styles[1]

/datum/preference/choiced/ui_style/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_ui_style(ui_style2icon(value))

/datum/preference/toggle/intent_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "intent_style"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/face_cursor_combat_mode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "face_cursor_combat_mode"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE
