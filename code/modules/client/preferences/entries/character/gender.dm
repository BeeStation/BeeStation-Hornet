/// Gender preference
/datum/preference/choiced/gender
	preference_type = PREFERENCE_CHARACTER
	db_key = "gender"
	priority = PREFERENCE_PRIORITY_GENDER

/datum/preference/choiced/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/apply_to_human(mob/living/carbon/human/target, value)
	if(!target.dna.species.sexes)
		value = PLURAL //disregard gender preferences on this species
	target.gender = value
