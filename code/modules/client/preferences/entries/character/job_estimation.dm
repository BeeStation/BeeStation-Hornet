/datum/preferences/var/list/job_estimation_name_by_slot = list()

/datum/preference/toggle/job_estimation_name
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "job_estimation_name"
	preference_type = PREFERENCE_CHARACTER
	disable_serialization = TRUE
	informed = TRUE

/datum/preference/toggle/job_estimation_name/create_informed_default_value(datum/preferences/preferences)
	var/cached_value = preferences.job_estimation_name_by_slot["[preferences.default_slot]"]
	return isnull(cached_value) ? default_value : cached_value

/datum/preference/toggle/job_estimation_name/apply_to_human(mob/living/carbon/human/target, value)
	return
