/datum/preference/choiced/selected_employer
	db_key = "selected_employer"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/selected_employer/compile_constant_data()
	return null

/datum/preference/choiced/selected_employer/init_possible_values()
	// Preferences can be deserialized before SSemployer initializes (the host
	// client builds /datum/preferences during world setup, which happens
	// before INITSTAGE_EARLY runs). Read ids straight from the type tree so we
	// never depend on subsystem state here. SSemployer is still the source of
	// truth at runtime via build_tgui_payload()/get_employer().
	var/list/ids = list()
	for(var/datum/employer_group/employer_type as anything in subtypesof(/datum/employer_group))
		var/id = initial(employer_type.id)
		if(!id)
			continue
		ids |= id
	if(!length(ids))
		// Failsafe: keep the assert in get_choices() happy even if no subtypes
		// declared an id for some reason.
		ids += EMPLOYER_ID_NANOTRASEN
	return ids

/datum/preference/choiced/selected_employer/create_default_value()
	if(SSemployer && length(SSemployer.employer_datums))
		var/datum/employer_group/first = SSemployer.employer_datums[1]
		return first.id
	return EMPLOYER_ID_NANOTRASEN

/datum/preference/choiced/selected_employer/apply_to_human(mob/living/carbon/human/target, value)
	return // No touchy
