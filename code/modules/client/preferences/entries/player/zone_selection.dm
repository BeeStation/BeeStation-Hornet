/// Determines parallax, "fancy space"
/datum/preference/choiced/zone_select
	db_key = "zone_select"
	preference_type = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/zone_select/init_possible_values()
	return list(
		PREFERENCE_BODYZONE_SIMPLIFIED,
		PREFERENCE_BODYZONE_INTENT,
	)

/datum/preference/choiced/zone_select/create_default_value()
	return PREFERENCE_BODYZONE_SIMPLIFIED

/datum/preference/choiced/zone_select/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_parallax_pref(client?.mob)
