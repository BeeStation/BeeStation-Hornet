/datum/preference/choiced/quirk_prosthetic_limb_location
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_prosthetic_limb_location"
	can_randomize = FALSE

/datum/preference/choiced/quirk_prosthetic_limb_location/init_possible_values()
	return list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/preference/choiced/quirk_prosthetic_limb_location/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		BODY_ZONE_L_ARM = "Left Arm",
		BODY_ZONE_R_ARM = "Right Arm",
		BODY_ZONE_L_LEG = "Left Leg",
		BODY_ZONE_R_LEG = "Right Leg",
	)

	return data

/datum/preference/choiced/quirk_prosthetic_limb_location/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_prosthetic_limb_location/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Prosthetic Limb" in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk_phobia
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_phobia"
	can_randomize = FALSE

/datum/preference/choiced/quirk_phobia/init_possible_values() // tried to use the SStraumas.phobia_types but it seems that subsystem hasnt initialized before youre able to access character creation
	return list("spiders", "space", "security", "clowns", "greytide", "lizards",
				"skeletons", "snakes", "robots", "doctors", "authority", "the supernatural",
				"aliens", "strangers", "birds", "falling", "anime")

/datum/preference/choiced/quirk_phobia/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_phobia/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Phobia" in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk_multilingual_language
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_multilingual_language"
	can_randomize = FALSE

/datum/preference/choiced/quirk_multilingual_language/init_possible_values()
	return typecacheof(AVAILABLE_MULTILINGIAL_LANGUAGES_LIST)

/datum/preference/choiced/quirk_multilingual_language/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/datum/language/L as() in AVAILABLE_MULTILINGIAL_LANGUAGES_LIST)
		clean_names[L] = initial(L.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk_multilingual_language/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_multilingual_language/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Multilingual" in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk_smoker_cigarettes
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_smoker_cigarettes"
	can_randomize = FALSE

/datum/preference/choiced/quirk_smoker_cigarettes/init_possible_values()
	return list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp)

/datum/preference/choiced/quirk_smoker_cigarettes/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/obj/item/storage/fancy/cigarettes/S as() in init_possible_values())
		clean_names[S] = initial(S.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk_smoker_cigarettes/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_smoker_cigarettes/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Smoker" in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk_junkie_drug
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_junkie_drug"
	can_randomize = FALSE

/datum/preference/choiced/quirk_junkie_drug/init_possible_values()
	return list(
	/datum/reagent/drug/crank,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/ketamine)

/datum/preference/choiced/quirk_junkie_drug/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/datum/reagent/drug/D as() in init_possible_values())
		clean_names[D] = initial(D.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk_junkie_drug/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_junkie_drug/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Junkie" in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk_alcohol_type
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "quirk_alcohol_type"
	can_randomize = FALSE

/datum/preference/choiced/quirk_alcohol_type/init_possible_values()
	return list(
	/obj/item/reagent_containers/food/drinks/bottle/ale,
	/obj/item/reagent_containers/food/drinks/bottle/beer,
	/obj/item/reagent_containers/food/drinks/bottle/gin,
	/obj/item/reagent_containers/food/drinks/bottle/whiskey,
	/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/reagent_containers/food/drinks/bottle/rum,
	/obj/item/reagent_containers/food/drinks/bottle/applejack)

/datum/preference/choiced/quirk_alcohol_type/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list()
	for(var/obj/item/reagent_containers/food/drinks/bottle/S as() in init_possible_values())
		clean_names[S] = initial(S.name)

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names

	return data

/datum/preference/choiced/quirk_alcohol_type/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk_alcohol_type/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	if("Alcoholic" in preferences.all_quirks)
		return TRUE
	return FALSE
