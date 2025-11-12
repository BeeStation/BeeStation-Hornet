/*
/datum/preference/choiced/tail_human
	db_key = "feature_human_tail"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/tail/cat

/datum/preference/choiced/tail_human/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_human)

/datum/preference/choiced/tail_human/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_cat"] = value

/datum/preference/choiced/tail_human/create_default_value()
	var/datum/sprite_accessory/tails/human/cat/tail = /datum/sprite_accessory/tails/human/cat
	return initial(tail.name)

/datum/preference/choiced/ears
	db_key = "feature_human_ears"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/ears/cat

/datum/preference/choiced/ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list)

/datum/preference/choiced/ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears"] = value

/datum/preference/choiced/ears/create_default_value()
	return /datum/sprite_accessory/ears/cat::name

*/
