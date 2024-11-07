/datum/preference/choiced/jobless_role
	db_key = "joblessrole"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/jobless_role/create_default_value()
	return BEOVERFLOW

/datum/preference/choiced/jobless_role/init_possible_values()
	return list(BEOVERFLOW, BERANDOMJOB, RETURNTOLOBBY)

/datum/preference/choiced/jobless_role/apply_to_human(mob/living/carbon/human/target, value)
	return
