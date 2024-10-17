/datum/preference/choiced/quirk/alcohol_type
	db_key = "quirk_alcohol_type"
	required_quirk = /datum/quirk/alcoholic

/datum/preference/choiced/quirk/alcohol_type/init_possible_values()
	return ..() + GLOB.alcoholic_bottles

/datum/preference/choiced/quirk/alcohol_type/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/obj/item/reagent_containers/cup/glass/bottle/S as() in GLOB.alcoholic_bottles)
		clean_names[S] = initial(S.name)
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data
