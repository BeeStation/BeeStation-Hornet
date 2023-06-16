/datum/preference/color_legacy/mutant_color
	savefile_key = "feature_mcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = MUTCOLORS

/datum/preference/color_legacy/mutant_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color_legacy/mutant_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor"] = value

/datum/preference/color_legacy/mutant_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark(expand_three_digit_color(value)))
		return FALSE

	return TRUE
