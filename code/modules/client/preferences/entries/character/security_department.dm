/// Which department to put security officers in, when the config is enabled
/datum/preference/choiced/security_department
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	preference_type = PREFERENCE_CHARACTER
	db_key = "preferred_security_department"

// This is what that #warn wants you to remove :)
/datum/preference/choiced/security_department/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.security_depts_prefs))
		return SEC_DEPT_NONE
	return ..()

/datum/preference/choiced/security_department/init_possible_values()
	return GLOB.security_depts_prefs

/datum/preference/choiced/security_department/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/security_department/create_default_value()
	return SEC_DEPT_NONE
