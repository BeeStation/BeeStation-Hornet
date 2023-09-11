/datum/preference/choiced/quirk
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	can_randomize = TRUE
	abstract_type = /datum/preference/choiced/quirk
	var/required_quirk_name // name of the quirk to be checked for (caps sensitive)

/datum/preference/choiced/quirk/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if(required_quirk_name in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk/prosthetic_limb_location
	required_quirk_name = "Prosthetic Limb"
	db_key = "quirk_prosthetic_limb_location"

/datum/preference/choiced/quirk/prosthetic_limb_location/init_possible_values()
	return list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/preference/choiced/quirk/prosthetic_limb_location/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		BODY_ZONE_L_ARM = "Left Arm",
		BODY_ZONE_R_ARM = "Right Arm",
		BODY_ZONE_L_LEG = "Left Leg",
		BODY_ZONE_R_LEG = "Right Leg",
	)

	return data

/datum/preference/choiced/quirk/phobia
	db_key = "quirk_phobia"
	required_quirk_name = "Phobia"

/datum/preference/choiced/quirk/phobia/init_possible_values() // tried to use the SStraumas.phobia_types but it seems that subsystem hasnt initialized before youre able to access character creation
	return assoc_to_keys(GLOB.available_random_trauma_list)

/datum/preference/choiced/quirk/multilingual_language
	db_key = "quirk_multilingual_language"
	required_quirk_name = "Multilingual"

/datum/preference/choiced/quirk/multilingual_language/init_possible_values()
	return GLOB.multilingual_language_list

/datum/preference/choiced/quirk/multilingual_language/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/datum/language/L as() in GLOB.multilingual_language_list)
		clean_names[L] = initial(L.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk/smoker_cigarettes
	db_key = "quirk_smoker_cigarettes"
	required_quirk_name = "Smoker"

/datum/preference/choiced/quirk/smoker_cigarettes/init_possible_values()
	return list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp)

/datum/preference/choiced/quirk/smoker_cigarettes/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/obj/item/storage/fancy/cigarettes/S as() in init_possible_values())
		clean_names[S] = initial(S.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk/junkie_drug
	db_key = "quirk_junkie_drug"
	required_quirk_name = "Junkie"

/datum/preference/choiced/quirk/junkie_drug/init_possible_values()
	return list(
	/datum/reagent/drug/crank,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/ketamine)

/datum/preference/choiced/quirk/junkie_drug/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/datum/reagent/drug/D as() in init_possible_values())
		clean_names[D] = initial(D.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk/alcohol_type
	db_key = "quirk_alcohol_type"
	required_quirk_name = "Alcoholic"

/datum/preference/choiced/quirk/alcohol_type/init_possible_values()
	return list(
	/obj/item/reagent_containers/food/drinks/bottle/ale,
	/obj/item/reagent_containers/food/drinks/bottle/beer,
	/obj/item/reagent_containers/food/drinks/bottle/gin,
	/obj/item/reagent_containers/food/drinks/bottle/whiskey,
	/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/reagent_containers/food/drinks/bottle/rum,
	/obj/item/reagent_containers/food/drinks/bottle/applejack)

/datum/preference/choiced/quirk/alcohol_type/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/obj/item/reagent_containers/food/drinks/bottle/S as() in init_possible_values())
		clean_names[S] = initial(S.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data
