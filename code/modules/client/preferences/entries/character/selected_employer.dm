/datum/preference/choiced/selected_employer
	db_key = "selected_employer"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/selected_employer/init_possible_values()
	var/list/ids = list()
	if(SSemployer) // I think initstage early is good for this?
		for(var/datum/employer_group/employer as anything in SSemployer.employer_datums)
			ids += employer.id
	return ids

/datum/preference/choiced/selected_employer/create_default_value()
	if(SSemployer && length(SSemployer.employer_datums))
		var/datum/employer_group/first = SSemployer.employer_datums[1]
		return first.id
	return EMPLOYER_ID_NANOTRASEN

/datum/preference/choiced/selected_employer/apply_to_human(mob/living/carbon/human/target, value)
	return // No touchy
