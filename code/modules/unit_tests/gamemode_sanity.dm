/// Verifies that gamemodes have various fields
/datum/unit_test/gamemode_sanity

/datum/unit_test/gamemode_sanity/Run()
	for (var/datum/game_mode/mode as anything in subtypesof(/datum/game_mode))
		var/name = initial(mode.name)
		if (!name)
			Fail("[mode] has no name set!")
		var/config_tag = initial(mode.config_tag)
		if (!config_tag)
			Fail("[mode] has no config_tag set!")
		// These gamemodes don't spawn antags directly and are exempt.
		if(!initial(mode.required_enemies) && !initial(mode.recommended_enemies))
			continue
		var/datum/antagonist/antag_datum = initial(mode.antag_datum)
		if (!ispath(antag_datum, /datum/antagonist) || !initial(antag_datum.banning_key))
			Fail("[mode] has no antag_datum with a banning key!")
		var/role_pref = initial(mode.role_preference)
		if (!role_pref || !ispath(role_pref, /datum/role_preference))
			Fail("[mode] has no role_preference set!")
