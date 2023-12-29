/datum/preference/choiced/quirk/smoker_cigarettes
	db_key = "quirk_smoker_cigarettes"
	required_quirk = /datum/quirk/junkie/smoker

/datum/preference/choiced/quirk/smoker_cigarettes/init_possible_values()
	return ..() + GLOB.smoker_cigarettes

/datum/preference/choiced/quirk/smoker_cigarettes/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/obj/item/storage/fancy/cigarettes/S as() in GLOB.smoker_cigarettes)
		clean_names[S] = initial(S.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data
