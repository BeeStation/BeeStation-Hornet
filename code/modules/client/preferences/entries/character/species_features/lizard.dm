/proc/generate_lizard_side_shot(datum/sprite_accessory/sprite_accessory, key, include_snout = TRUE)
	var/static/datum/universal_icon/lizard
	var/static/datum/universal_icon/lizard_with_snout

	if (isnull(lizard))
		lizard = uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_head", dir = EAST)
		var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes_l", dir = EAST)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		lizard.blend_icon(eyes, ICON_OVERLAY)

		lizard_with_snout = lizard.copy()
		lizard_with_snout.blend_icon(uni_icon('icons/mob/mutant_bodyparts.dmi', "m_snout_round_ADJ", dir = EAST), ICON_OVERLAY)

	var/datum/universal_icon/final_icon = include_snout ? lizard_with_snout.copy() : lizard.copy()

	if (!isnull(sprite_accessory))
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", dir = EAST)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)
	final_icon.blend_color(COLOR_LIME, ICON_MULTIPLY)

	return final_icon

/datum/preference/choiced/lizard_body_markings
	db_key = "feature_lizard_body_markings"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body Markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "body_markings"

/datum/preference/choiced/lizard_body_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.body_markings_list)

/datum/preference/choiced/lizard_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = GLOB.body_markings_list[value]

	var/datum/universal_icon/final_icon = uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_chest_m", dir = SOUTH)

	if (value != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/body_markings_icon = uni_icon(
			sprite_accessory.icon,
			"m_body_markings_[sprite_accessory.icon_state]_ADJ",
		)

		final_icon.blend_icon(body_markings_icon, ICON_OVERLAY)

	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
	final_icon.crop(10, 8, 22, 23)
	final_icon.scale(26, 32)
	final_icon.crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/lizard_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["body_markings"] = value

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
	var/datum/sprite_accessory/frills = value != SPRITE_ACCESSORY_NONE ? GLOB.frills_list[value] : null
	return generate_lizard_side_shot(frills, "frills")

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
	var/datum/sprite_accessory/horns = value != SPRITE_ACCESSORY_NONE ? GLOB.horns_list[value] : null
	return generate_lizard_side_shot(horns, "horns")

/datum/preference/choiced/lizard_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns"] = value

/datum/preference/choiced/lizard_legs
	db_key = "feature_lizard_legs"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "legs"

/datum/preference/choiced/lizard_legs/init_possible_values()
	return assoc_to_keys(GLOB.legs_list)

/datum/preference/choiced/lizard_legs/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs"] = value

/datum/preference/choiced/lizard_snout
	db_key = "feature_lizard_snout"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "snout"

/datum/preference/choiced/lizard_snout/init_possible_values()
	return assoc_to_keys_features(GLOB.snouts_list)

/datum/preference/choiced/lizard_snout/icon_for(value)
	var/datum/sprite_accessory/snout = value != SPRITE_ACCESSORY_NONE ? GLOB.snouts_list[value] : null
	return generate_lizard_side_shot(snout, "snout", include_snout = FALSE)

/datum/preference/choiced/lizard_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout"] = value

/datum/preference/choiced/lizard_spines
	db_key = "feature_lizard_spines"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Spines"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "spines"

/datum/preference/choiced/lizard_spines/init_possible_values()
	return assoc_to_keys_features(GLOB.spines_list)

/datum/preference/choiced/lizard_spines/icon_for(value)
	var/datum/sprite_accessory/spines = value != SPRITE_ACCESSORY_NONE ? GLOB.spines_list[value] : null
	return generate_lizard_body_shot(spines, "spines", show_tail = TRUE)

/datum/preference/choiced/lizard_spines/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines"] = value

/datum/preference/choiced/lizard_tail
	db_key = "feature_lizard_tail"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Tail"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "tail_lizard"

/datum/preference/choiced/lizard_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_lizard)

/datum/preference/choiced/lizard_tail/icon_for(value)
	var/datum/sprite_accessory/tail = value != SPRITE_ACCESSORY_NONE ? GLOB.tails_list_lizard[value] : null
	return generate_lizard_body_shot(tail, "tail")

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/proc/generate_lizard_body_shot(datum/sprite_accessory/sprite_accessory, key, show_tail = FALSE, shift_x = -8)
	var/static/datum/universal_icon/body_icon
	var/static/datum/universal_icon/body_icon_with_tail

	if (isnull(body_icon))
		body_icon = uni_icon('icons/effects/effects.dmi', "nothing")
		var/list/body_parts = list(
			BODY_ZONE_CHEST,
			BODY_ZONE_R_ARM,
			BODY_ZONE_PRECISE_R_HAND,
			BODY_ZONE_R_LEG,
		)
		for (var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST ? "_m" : ""
			body_icon.blend_icon(uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_[body_part][gender]", dir = EAST), ICON_OVERLAY)

		body_icon_with_tail = body_icon.copy()
		body_icon_with_tail.blend_icon(uni_icon('icons/mob/mutant_bodyparts.dmi', "m_tail_smooth_BEHIND", dir = EAST), ICON_OVERLAY)

	var/datum/universal_icon/icon_with_changes = show_tail ? body_icon_with_tail.copy() : body_icon.copy()

	if (!isnull(sprite_accessory))
		var/ex = key == "spines" ? "ADJ" : "BEHIND"
		var/datum/universal_icon/sprite_icon = uni_icon('icons/mob/mutant_bodyparts.dmi', "m_[key]_[sprite_accessory.icon_state]_[ex]", dir = EAST)
		icon_with_changes.blend_icon(sprite_icon, ICON_OVERLAY)

	icon_with_changes.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)

	// Zoom in
	icon_with_changes.scale(64, 64)
	icon_with_changes.crop(15 + shift_x, 0, 15 + 31 + shift_x, 31)

	return icon_with_changes
