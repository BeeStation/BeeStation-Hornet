/// Determines what accessories your ghost will look like they have.
/datum/preference/choiced/ghost_accessories
	db_key = "ghost_accs"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_accessories/init_possible_values()
	return list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL)

/datum/preference/choiced/ghost_accessories/create_default_value()
	return GHOST_ACCS_DEFAULT_OPTION

/datum/preference/choiced/ghost_accessories/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	ghost.ghost_accs = value
	ghost.update_appearance()

/datum/preference/choiced/ghost_accessories/deserialize(input, datum/preferences/preferences)
	// Old ghost preferences used to be 1/50/100.
	// Whoever did that wasted an entire day of my time trying to get those sent
	// properly, so I'm going to buck them.
	if (isnum(input))
		switch (input)
			if (1)
				input = GHOST_ACCS_NONE
			if (50)
				input = GHOST_ACCS_DIR
			if (100)
				input = GHOST_ACCS_FULL

	return ..(input)

/// Determines the appearance of your ghost to others, when you are a BYOND member
/datum/preference/choiced/ghost_form
	db_key = "ghost_form"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	should_generate_icons = TRUE

/datum/preference/choiced/ghost_form/init_possible_values()
	return assoc_to_keys(GLOB.ghost_forms)

/datum/preference/choiced/ghost_form/icon_for(value)
	return uni_icon('icons/mob/mob.dmi', value)

/datum/preference/choiced/ghost_form/create_default_value()
	return "ghost"

/datum/preference/choiced/ghost_form/apply_to_client(client/client, datum/universal_icon/value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	if (!client.is_content_unlocked())
		return

	ghost.update_icon(ALL, icon(value.icon_file, value.icon_state))

/datum/preference/choiced/ghost_form/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.ghost_forms

	return data

/// Toggles the HUD for ghosts
/datum/preference/toggle/ghost_hud
	db_key = "ghost_hud"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/toggle/ghost_hud/apply_to_client(client/client, value)
	if (isobserver(client?.mob))
		client?.mob.hud_used?.show_hud()

/// Determines what ghosts orbiting look like to you.
/datum/preference/choiced/ghost_orbit
	db_key = "ghost_orbit"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_orbit/init_possible_values()
	return list(
		GHOST_ORBIT_CIRCLE,
		GHOST_ORBIT_TRIANGLE,
		GHOST_ORBIT_SQUARE,
		GHOST_ORBIT_HEXAGON,
		GHOST_ORBIT_PENTAGON,
	)

/datum/preference/choiced/ghost_orbit/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	if (!client.is_content_unlocked())
		return

	ghost.ghost_orbit = value

/datum/preference/choiced/ghost_orbit/create_default_value()
	return GHOST_ORBIT_CIRCLE

/// Determines how to show other ghosts
/datum/preference/choiced/ghost_others
	db_key = "ghost_others"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_others/init_possible_values()
	return list(
		GHOST_OTHERS_SIMPLE,
		GHOST_OTHERS_DEFAULT_SPRITE,
		GHOST_OTHERS_THEIR_SETTING,
	)

/datum/preference/choiced/ghost_others/create_default_value()
	return GHOST_OTHERS_DEFAULT_OPTION

/datum/preference/choiced/ghost_others/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	ghost.update_sight()

/datum/preference/choiced/ghost_others/deserialize(input, datum/preferences/preferences)
	// Old ghost preferences used to be 1/50/100.
	// Whoever did that wasted an entire day of my time trying to get those sent
	// properly, so I'm going to buck them.
	if (isnum(input))
		switch (input)
			if (1)
				input = GHOST_OTHERS_SIMPLE
			if (50)
				input = GHOST_OTHERS_DEFAULT_SPRITE
			if (100)
				input = GHOST_OTHERS_THEIR_SETTING

	return ..(input, preferences)

/// Whether or not ghosts can examine things by clicking on them.
/datum/preference/toggle/inquisitive_ghost
	db_key = "inquisitive_ghost"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
