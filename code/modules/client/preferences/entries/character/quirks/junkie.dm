/datum/preference/choiced/quirk/junkie_drug
	db_key = "quirk_junkie_drug"
	required_quirk = /datum/quirk/junkie

/datum/preference/choiced/quirk/junkie_drug/init_possible_values()
	return ..() + GLOB.junkie_drugs

/datum/preference/choiced/quirk/junkie_drug/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/datum/reagent/drug/D as() in GLOB.junkie_drugs)
		clean_names[D] = initial(D.name)
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data
