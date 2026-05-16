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

/// Whether or not ghosts can examine things by clicking on them.
/datum/preference/toggle/inquisitive_ghost
	db_key = "inquisitive_ghost"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
