#define USE_GENDER "Use gender"
// Capitalised so stale lowercase values from the old body_model pref fail sanitization
#define BODY_TYPE_MALE "Male"
#define BODY_TYPE_FEMALE "Female"

/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	db_key = "body_model"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/body_type/init_possible_values()
	return list(USE_GENDER, BODY_TYPE_MALE, BODY_TYPE_FEMALE)

/datum/preference/choiced/body_type/create_default_value()
	return USE_GENDER

/datum/preference/choiced/body_type/create_informed_default_value(datum/preferences/preferences)
	return gender_has_physique(preferences.read_preference(/datum/preference/choiced/gender)) ? USE_GENDER : BODY_TYPE_FEMALE

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	switch(value)
		if(BODY_TYPE_MALE)
			target.physique = MALE
		if(BODY_TYPE_FEMALE)
			target.physique = FEMALE
		else
			target.physique = gender_has_physique(target.gender) ? target.gender : FEMALE

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..(preferences, ignore_page))
		return FALSE

	var/datum/species/species = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species.sexes)

/proc/gender_has_physique(gender)
	return gender == MALE || gender == FEMALE

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

#undef BODY_TYPE_FEMALE
#undef BODY_TYPE_MALE
#undef USE_GENDER
