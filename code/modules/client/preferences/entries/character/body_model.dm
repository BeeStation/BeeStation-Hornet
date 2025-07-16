#define USE_GENDER "Use gender"

/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	db_key = "body_model"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/body_type/init_possible_values()
	return list(USE_GENDER, MALE, FEMALE)

/datum/preference/choiced/body_type/create_default_value()
	return USE_GENDER

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	if (value == USE_GENDER)
		target.physique = target.gender
	else
		target.physique = value

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..(preferences))
		return FALSE

	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species.sexes)

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

#undef USE_GENDER
