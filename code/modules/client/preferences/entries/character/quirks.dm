/datum/preference/choiced/quirk
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	can_randomize = TRUE
	abstract_type = /datum/preference/choiced/quirk
	/// typepath of the quirk to be checked for (exact)
	var/required_quirk

/datum/preference/choiced/quirk/deserialize(input, datum/preferences/preferences)
	// stupid, but if you have a better solution, then go ahead and write it
	var/input_path = text2path(input)
	if(ispath(input_path))
		return ..(input_path, preferences)
	else
		return ..(input, preferences)

/datum/preference/choiced/quirk/create_default_value()
	return "Random"

/datum/preference/choiced/quirk/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/quirk/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE
	var/datum/quirk/quirk = required_quirk
	if(initial(quirk.name) in preferences.all_quirks)
		return TRUE
	return FALSE

/datum/preference/choiced/quirk/init_possible_values()
	return list("Random")
