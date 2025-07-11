/datum/preference/color/mutant_color
	db_key = "feature_mcolor"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = MUTCOLORS

/datum/preference/color/mutant_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/mutant_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["mcolor"] = value

/datum/preference/color/mutant_color/is_valid(value)
	if (!..(value))
		return FALSE

	if (is_color_dark_with_saturation(value))
		return FALSE

	return TRUE
