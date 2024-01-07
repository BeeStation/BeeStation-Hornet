/datum/preference/choiced/quirk/multilingual_language
	db_key = "quirk_multilingual_language"
	required_quirk = /datum/quirk/multilingual

/datum/preference/choiced/quirk/multilingual_language/init_possible_values()
	return ..() + assoc_to_keys(GLOB.multilingual_language_list)

/datum/preference/choiced/quirk/multilingual_language/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/datum/language/L as() in GLOB.multilingual_language_list)
		clean_names[L] = initial(L.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data
