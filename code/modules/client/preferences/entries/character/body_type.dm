/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	db_key = "body_type"
	preference_type = PREFERENCE_CHARACTER

/datum/preference/choiced/body_type/init_possible_values()
	return list(MALE, FEMALE)

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	if (target.gender != MALE && target.gender != FEMALE)
		target.dna.features["body_model"] = value
	else
		target.dna.features["body_model"] = target.gender

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return gender != MALE && gender != FEMALE

/datum/preference/choiced/body_size
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	db_key = "body_size"
	preference_type = PREFERENCE_CHARACTER

/datum/preference/choiced/body_size/init_possible_values()
	return assoc_to_keys(GLOB.body_sizes)

/datum/preference/choiced/body_size/create_default_value()
	return "Normal"

/datum/preference/choiced/body_size/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["body_size"] = value
