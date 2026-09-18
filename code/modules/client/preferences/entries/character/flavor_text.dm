/datum/preference/text/flavor_text
	db_key = "flavor_text"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	maximum_value_length = 400

/datum/preference/text/flavor_text/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["flavor_text"] = value
