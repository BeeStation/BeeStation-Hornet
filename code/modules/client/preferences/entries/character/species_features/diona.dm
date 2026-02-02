/datum/preference/choiced/diona_leaves
	db_key = "feature_diona_leaves"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Leaves"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_leaves"

/datum/preference/choiced/diona_leaves/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_leaves_list)
		var/datum/sprite_accessory/markings = GLOB.diona_leaves_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != FEATURE_NONE)
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_leaves_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_leaves/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_leaves"] = value

//----------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_thorns
	db_key = "feature_diona_thorns"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Thorns"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_thorns"

/datum/preference/choiced/diona_thorns/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_thorns_list)
		var/datum/sprite_accessory/markings = GLOB.diona_thorns_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_thorns_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_thorns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_thorns"] = value

//----------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_flowers
	db_key = "feature_diona_flowers"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Flowers"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_flowers"

/datum/preference/choiced/diona_flowers/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_flowers_list)
		var/datum/sprite_accessory/markings = GLOB.diona_flowers_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_flowers_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_flowers/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_flowers"] = value

//----------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_moss
	db_key = "feature_diona_moss"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Moss"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_moss"

/datum/preference/choiced/diona_moss/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_CHEST
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_moss_list)
		var/datum/sprite_accessory/markings = GLOB.diona_moss_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_moss_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_moss/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_moss"] = value

//----------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_mushroom
	db_key = "feature_diona_mushroom"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Mushrooms"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_mushroom"

/datum/preference/choiced/diona_mushroom/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_mushroom_list)
		var/datum/sprite_accessory/markings = GLOB.diona_mushroom_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_mushroom_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_mushroom/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_mushroom"] = value

//----------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_antennae
	db_key = "feature_diona_antennae"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Antennae"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_antennae"

/datum/preference/choiced/diona_antennae/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_antennae_list)
		var/datum/sprite_accessory/markings = GLOB.diona_antennae_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_antennae_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_antennae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_antennae"] = value

//------------------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_eyes
	db_key = "feature_diona_eyes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona Eyes"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_eyes"

/datum/preference/choiced/diona_eyes/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	for (var/markings_name in GLOB.diona_eyes_list)
		var/datum/sprite_accessory/markings = GLOB.diona_eyes_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
			body_part_icon.crop(1, 1, 32, 32)
			icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_eyes_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_eyes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_eyes"] = value

//------------------------------------------------------------------------------------------------------------------------------

/datum/preference/choiced/diona_pbody
	db_key = "feature_diona_pbody"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Diona P-Body"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "diona_pbody"

/datum/preference/choiced/diona_pbody/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/diona_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_CHEST
	)

	for (var/body_part in body_parts)
		diona_body.blend_icon(uni_icon('icons/mob/human/species/diona/bodyparts.dmi', "diona_[body_part]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.diona_pbody_list)
		var/datum/sprite_accessory/markings = GLOB.diona_pbody_list[markings_name]
		var/datum/universal_icon/icon_with_markings = diona_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "m_[relevant_mutant_bodypart]_[markings.icon_state]_ADJ", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/diona_markings.dmi', "m_diona_pbody_ADJ"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/diona_pbody/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["diona_pbody"] = value
