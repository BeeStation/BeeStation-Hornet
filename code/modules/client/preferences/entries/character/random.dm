/datum/preference/choiced/random_body
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "body_is_always_random"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/random_body/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/random_body/init_possible_values()
	return list(
		RANDOM_ANTAG_ONLY,
		RANDOM_DISABLED,
		RANDOM_ENABLED,
	)

/datum/preference/choiced/random_body/create_default_value()
	return RANDOM_DISABLED

/datum/preference/choiced/random_name
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "name_is_always_random"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/random_name/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/random_name/init_possible_values()
	return list(
		RANDOM_ANTAG_ONLY,
		RANDOM_DISABLED,
		RANDOM_ENABLED,
	)

/datum/preference/choiced/random_name/create_default_value()
	return RANDOM_DISABLED
