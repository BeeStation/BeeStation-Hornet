/datum/preference/choiced/helmet_style
	db_key = "helmet_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/helmet_style/init_possible_values()
	return assoc_to_keys(GLOB.helmet_styles)

/datum/preference/choiced/helmet_style/create_default_value()
	return HELMET_DEFAULT

/datum/preference/choiced/helmet_style/apply_to_human(mob/living/carbon/human/target, value)
	return
