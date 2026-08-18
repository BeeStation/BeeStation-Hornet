/datum/preference/choiced/insect_type
	db_key = "feature_insect_type"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "insect_type"

/datum/preference/choiced/insect_type/init_possible_values()
	return assoc_to_keys(SSaccessories.insect_type_list)

/datum/preference/choiced/insect_type/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["insect_type"] = value
