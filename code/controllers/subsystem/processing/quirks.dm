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
	var/list/quirk_blacklist = list() //A list of quirks that can not be used with each other. Format: list(quirk1,quirk2),list(quirk3,quirk4)

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	if(!length(quirks))
		SetupQuirks()

	quirk_blacklist = list(
		list("Blind","Nearsighted"),
		list("Jolly","Depression","Apathetic","Hypersensitive"),
		list("Ageusia","Vegetarian","Deviant Tastes"),
		list("Ananas Affinity","Ananas Aversion"),
		list("Alcohol Tolerance","Light Drinker"),
		list("Social Anxiety","Mute"),
	)
	return ..()

/datum/controller/subsystem/processing/quirks/proc/SetupQuirks()
	// Sort by Positive, Negative, Neutral; and then by name
	var/list/quirk_list = sortList(subtypesof(/datum/quirk), GLOBAL_PROC_REF(cmp_quirk_asc))

	for(var/datum/quirk/T as() in quirk_list)
		quirks[initial(T.name)] = T
		quirk_points[initial(T.name)] = initial(T.value)

/datum/controller/subsystem/processing/quirks/proc/AssignQuirks(mob/living/user, client/cli, spawn_effects)
	var/bad_quirk_checker = 0
	var/list/bad_quirks = list()
	for(var/V in cli.prefs.active_character.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
			user.add_quirk(Q, spawn_effects)
			bad_quirk_checker += initial(Q.value)
		else
			stack_trace("Invalid quirk \"[V]\" in client [cli.ckey] preferences. the game has reset their quirks automatically.")
			bad_quirks += V
	if(bad_quirk_checker > 0 || length(bad_quirks)) // negative & zero value = calculation good / positive quirk value = something's wrong
		cli.prefs.active_character.all_quirks = list()
		cli.prefs.active_character.save(cli)
		client_alert(cli, "You have one or more outdated quirks[length(bad_quirks) ? ": [english_list(bad_quirks)]" : ""]. Your eligible quirks are kept at this round, but your character preference has been reset. Please review them at any time.", "Oh, no!")
