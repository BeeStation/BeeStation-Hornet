/datum/preference/choiced/monkey_tail
	db_key = "feature_monkey_tail"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "monkey_tail"
	can_randomize = FALSE

/datum/preference/choiced/monkey_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_monkey)

/datum/preference/choiced/monkey_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_monkey"] = value

/datum/preference/choiced/monkey_tail/create_default_value()
	var/datum/sprite_accessory/tails/monkey/default/tail = /datum/sprite_accessory/tails/monkey/default
	return initial(tail.name)
