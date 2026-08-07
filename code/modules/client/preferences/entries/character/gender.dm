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

/datum/preference/choiced/gender/create_default_value()
	// Override for randomised characters to exclude plural from the selection
	// so that players picking the 'other' gender are players who will do it
	// properly.
	// These are stricter than what is possible, since its a default not a restriction
	return pick(MALE, FEMALE)
