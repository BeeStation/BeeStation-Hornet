/datum/preference/toggle/screensize
	db_key = "screensize"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	preference_type = PREFERENCE_PLAYER
	default_value = FALSE


/datum/preference/choiced/screensize/init_possible_values()
	return list(
		SCREENSIZE_XWIDE,
		SCREENSIZE_WIDE,
		SCREENSIZE_SQUARE,
	)
//      square: '1:1 ratio (15x15)',
//      wide: 'Wide ratio (17x15)',
//      extrawide: 'Extra Wide ratio (19x15)',

/datum/preference/choiced/screensize/create_default_value()
	return SCREENSIZE_WIDE

/datum/preference/choiced/screensize/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_screensize_pref(client?.mob)

/datum/preference/choiced/screensize/deserialize(input, datum/preferences/preferences)
	// Old preferences were numbers, which causes annoyances when
	// sending over as lists that isn't worth dealing with.
	if (isnum(input))
		switch (input)
			if (-1)
				input = SCREENSIZE_XWIDE
			if (0)
				input = SCREENSIZE_WIDE
			if (1)
				input = SCREENSIZE_SQUARE
	return ..(input)

