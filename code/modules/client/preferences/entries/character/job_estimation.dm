/datum/preference/toggle/job_estimation_name
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "job_estimation_name"
	preference_type = PREFERENCE_CHARACTER
	disable_serialization = TRUE

/datum/preference/toggle/job_estimation_name/apply_to_human(mob/living/carbon/human/target, value)
	return
