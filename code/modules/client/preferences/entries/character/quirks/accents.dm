/datum/preference/choiced/quirk/accent
	db_key = "quirk_accent"
	required_quirk = /datum/quirk/accent

/datum/preference/choiced/quirk/accent/init_possible_values()
	return ..() + assoc_to_keys(GLOB.accents)

/datum/preference/choiced/quirk/accent/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")

	for(var/name in GLOB.accents)
		clean_names[name] = name  // Show display names as-is (e.g., "Roadman")

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data
