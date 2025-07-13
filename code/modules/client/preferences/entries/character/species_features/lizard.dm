/proc/generate_lizard_side_shot(datum/sprite_accessory/sprite_accessory, key, include_snout = TRUE)
	var/static/datum/universal_icon/lizard
	var/static/datum/universal_icon/lizard_with_snout

	if (isnull(lizard))
		lizard = uni_icon('icons/mob/species/lizard/bodyparts.dmi', "lizard_head", EAST)
		var/datum/universal_icon/eyes = uni_icon('icons/mob/species/human/human_face.dmi', "eyes", EAST)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		lizard.blend_icon(eyes, ICON_OVERLAY)

		lizard_with_snout = lizard.copy()
		lizard_with_snout.blend_icon(uni_icon('icons/mob/species/lizard/lizard_misc.dmi', "m_snout_round_ADJ", EAST), ICON_OVERLAY)

	var/datum/universal_icon/final_icon = include_snout ? lizard_with_snout.copy() : lizard.copy()

	if (!isnull(sprite_accessory) && sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)
	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)

	return final_icon

/datum/preference/choiced/lizard_body_markings
	db_key = "feature_lizard_body_markings"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body Markings"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/lizard

/datum/preference/choiced/lizard_body_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.lizard_markings_list)

/datum/preference/choiced/lizard_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = GLOB.lizard_markings_list[value]

	var/datum/universal_icon/final_icon = uni_icon('icons/mob/species/lizard/bodyparts.dmi', "lizard_chest_m")

	if (sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/body_markings_icon = uni_icon(
			sprite_accessory.icon,
			"male_[sprite_accessory.icon_state]_chest",
		)

		final_icon.blend_icon(body_markings_icon, ICON_OVERLAY)

	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
	final_icon.crop(10, 8, 22, 23)
	final_icon.scale(26, 32)
	final_icon.crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/lizard_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["lizard_markings"] = value

/datum/preference/choiced/lizard_frills
	db_key = "feature_lizard_frills"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Frills"
	should_generate_icons = TRUE
	relevant_mutant_bodypart =  "frills"

/datum/preference/choiced/lizard_frills/init_possible_values()
	return assoc_to_keys_features(GLOB.frills_list)

/datum/preference/choiced/lizard_frills/icon_for(value)
	return generate_lizard_side_shot(GLOB.frills_list[value], "frills")

/datum/preference/choiced/lizard_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills"] = value

/datum/preference/choiced/lizard_horns
	db_key = "feature_lizard_horns"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Horns"
	should_generate_icons = TRUE
	relevant_mutant_bodypart =  "horns"

/datum/preference/choiced/lizard_horns/init_possible_values()
	return assoc_to_keys_features(GLOB.horns_list)

/datum/preference/choiced/lizard_horns/icon_for(value)
	return generate_lizard_side_shot(GLOB.horns_list[value], "horns")

/datum/preference/choiced/lizard_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns"] = value

/datum/preference/choiced/lizard_legs
	db_key = "feature_lizard_legs"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "legs"

/datum/preference/choiced/lizard_legs/init_possible_values()
	return assoc_to_keys_features(GLOB.legs_list)

/datum/preference/choiced/lizard_legs/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs"] = value

/datum/preference/choiced/lizard_snout
	db_key = "feature_lizard_snout"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	//relevant_mutant_bodypart = "snout"
	//relevant_external_organ = /obj/item/organ/external/snout

/datum/preference/choiced/lizard_snout/init_possible_values()
	return assoc_to_keys_features(GLOB.snouts_list)

/datum/preference/choiced/lizard_snout/icon_for(value)
	return generate_lizard_side_shot(GLOB.snouts_list[value], "snout", include_snout = FALSE)

/datum/preference/choiced/lizard_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout"] = value

/datum/preference/choiced/lizard_spines
	db_key = "feature_lizard_spines"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	//main_feature_name = "Spines"
	//relevant_mutant_bodypart = "spines"
	relevant_external_organ = /obj/item/organ/external/spines

/datum/preference/choiced/lizard_spines/init_possible_values()
	return assoc_to_keys_features(GLOB.spines_list)

/datum/preference/choiced/lizard_spines/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines"] = value

/datum/preference/choiced/lizard_tail
	db_key = "feature_lizard_tail"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	//main_feature_name = "Tail"
	relevant_external_organ = /obj/item/organ/external/tail/lizard

/datum/preference/choiced/lizard_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_lizard)

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/datum/preference/choiced/lizard_tail/create_default_value()
	var/datum/sprite_accessory/tails/lizard/smooth/tail = /datum/sprite_accessory/tails/lizard/smooth
	return initial(tail.name)
