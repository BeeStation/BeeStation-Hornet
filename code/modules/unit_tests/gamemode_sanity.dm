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
		if(name == "event" || name == "extended" || name == "meteor" || name == "sandbox") // These gamemodes don't spawn antags and are exempt.
			continue
		if (!initial(mode.banning_key))
			Fail("[mode] has no banning_key set!")
		var/role_pref = initial(mode.role_preference)
		if (!role_pref || !ispath(role_pref, /datum/role_preference))
			Fail("[mode] has no role_preference set!")
