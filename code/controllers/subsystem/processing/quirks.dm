//Used to process and handle roundstart quirks
// - Quirk strings are used for faster checking in code
// - Quirk datums are stored and hold different effects, as well as being a vector for applying trait string

PROCESSING_SUBSYSTEM_DEF(quirks)
	name = "Quirks"
	init_order = INIT_ORDER_QUIRKS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 1 SECONDS

	var/list/quirks = list()		//Assoc. list of all roundstart quirk datum types; "name" = /path/
	var/list/quirk_points = list()	//Assoc. list of quirk names and their "point cost"; positive numbers are good traits, and negative ones are bad
	var/list/quirk_objects = list()	//A list of all quirk objects in the game, since some may process
	/// A list of quirks that can not be used with each other. Format: list(quirk1,quirk2),list(quirk3,quirk4)
	var/static/list/quirk_blacklist = list(
		list("Blind","Nearsighted"),
		list("Jolly","Depression","Apathetic","Hypersensitive"),
		list("Ageusia","Vegetarian","Deviant Tastes"),
		list("Ananas Affinity","Ananas Aversion"),
		list("Alcohol Tolerance","Light Drinker"),
		list("Social Anxiety","Mute"),
	)

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	get_quirks()
	return ..()

/// Returns the list of possible quirks
/datum/controller/subsystem/processing/quirks/proc/get_quirks()
	RETURN_TYPE(/list)
	if (!quirks.len)
		SetupQuirks()
	return quirks

/datum/controller/subsystem/processing/quirks/proc/SetupQuirks()
	// Sort by Positive, Negative, Neutral; and then by name
	var/list/quirk_list = sort_list(subtypesof(/datum/quirk), GLOBAL_PROC_REF(cmp_quirk_asc))

	for(var/datum/quirk/T as() in quirk_list)
		quirks[initial(T.name)] = T
		quirk_points[initial(T.name)] = initial(T.value)

/datum/controller/subsystem/processing/quirks/proc/AssignQuirks(datum/mind/user, client/cli, spawn_effects)
	var/bad_quirk_checker = 0
	var/list/bad_quirks = list()
	for(var/V in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
			user.add_quirk(Q, spawn_effects)
			bad_quirk_checker += initial(Q.value)
		else
			stack_trace("Invalid quirk \"[V]\" in client [cli.ckey] preferences. the game has reset their quirks automatically.")
			bad_quirks += V
	if(bad_quirk_checker > 0 || length(bad_quirks)) // negative & zero value = calculation good / positive quirk value = something's wrong
		cli.prefs.all_quirks = list()
		// save the new cleared quirks.
		cli.prefs.mark_undatumized_dirty_character()
		client_alert(cli, "You have one or more outdated quirks[length(bad_quirks) ? ": [english_list(bad_quirks)]" : ""]. Your eligible quirks are kept at this round, but your character preference has been reset. Please review them at any time.", "Oh, no!")

/// Takes a list of quirk names and returns a new list of quirks that would
/// be valid.
/// If no changes need to be made, will return the same list.
/// Expects all quirk names to be unique, but makes no other expectations.
/datum/controller/subsystem/processing/quirks/proc/filter_invalid_quirks(list/quirks)
	var/list/new_quirks = list()
	var/list/positive_quirks = list()
	var/balance = 0

	var/list/all_quirks = get_quirks()

	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = all_quirks[quirk_name]
		if (isnull(quirk))
			continue

		if (initial(quirk.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			continue

		var/blacklisted = FALSE

		for (var/list/blacklist as anything in quirk_blacklist)
			if (!(quirk in blacklist))
				continue

			for (var/other_quirk in blacklist)
				if (other_quirk in new_quirks)
					blacklisted = TRUE
					break

			if (blacklisted)
				break

		if (blacklisted)
			continue

		var/value = initial(quirk.value)
		if (value > 0)
			if (positive_quirks.len == MAX_QUIRKS)
				continue

			positive_quirks[quirk_name] = value

		balance += value
		new_quirks += quirk_name

	if (balance > 0)
		var/balance_left_to_remove = balance

		for (var/positive_quirk in positive_quirks)
			var/value = positive_quirks[positive_quirk]
			balance_left_to_remove -= value
			new_quirks -= positive_quirk

			if (balance_left_to_remove <= 0)
				break

	// It is guaranteed that if no quirks are invalid, you can simply check through `==`
	if (new_quirks.len == quirks.len)
		return quirks

	return new_quirks
