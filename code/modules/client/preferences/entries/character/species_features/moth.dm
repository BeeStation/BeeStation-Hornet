/datum/preference/choiced/moth_antennae
	db_key = "feature_moth_antennae"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "moth_antennae"

/datum/preference/choiced/moth_antennae/init_possible_values()
	var/list/values = list()

	for (var/antennae_name in GLOB.moth_antennae_roundstart_list)
		var/datum/sprite_accessory/antennae = GLOB.moth_antennae_roundstart_list[antennae_name]

		var/datum/universal_icon/icon_with_antennae = uni_icon('icons/mob/species/moth/bodyparts.dmi', "moth_head", dir = SOUTH)
		icon_with_antennae.blend_icon(uni_icon(antennae.icon, "m_moth_antennae_[antennae.icon_state]_FRONT", dir = SOUTH), ICON_OVERLAY)
		icon_with_antennae.scale(64, 64)
		icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)
		values[antennae.name] = icon_with_antennae

	return values

/datum/preference/choiced/moth_antennae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_antennae"] = value

/datum/preference/choiced/moth_markings
	db_key = "feature_moth_markings"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body Markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "moth_markings"

/datum/preference/choiced/moth_markings/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/moth_body = uni_icon('icons/effects/effects.dmi', "nothing")

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
	)

	for (var/body_part in body_parts)
		var/gender = body_part == "chest" ? "_m" : ""
		moth_body.blend_icon(uni_icon('icons/mob/species/moth/bodyparts.dmi', "moth_[body_part][gender]", dir = SOUTH), ICON_OVERLAY)

	for (var/markings_name in GLOB.moth_markings_roundstart_list)
		var/datum/sprite_accessory/markings = GLOB.moth_markings_roundstart_list[markings_name]
		var/datum/universal_icon/icon_with_markings = moth_body.copy()

		if (markings_name != "None")
			for (var/body_part in body_parts)
				var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "[markings.icon_state]_[body_part]", dir = SOUTH)
				body_part_icon.crop(1, 1, 32, 32)
				icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

		icon_with_markings.blend_icon(uni_icon('icons/mob/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
		icon_with_markings.blend_icon(uni_icon('icons/mob/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

		// Zoom in on the top of the head and the chest
		icon_with_markings.scale(64, 64)
		icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

		values[markings.name] = icon_with_markings

	return values

/datum/preference/choiced/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings"] = value

/datum/preference/choiced/moth_wings
	db_key = "feature_moth_wings"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Moth Wings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "moth_wings"

/datum/preference/choiced/moth_wings/init_possible_values()
	var/list/values = list()
	for (var/wings_name in GLOB.moth_wings_roundstart_list)
		var/datum/sprite_accessory/wings = GLOB.moth_wings_roundstart_list[wings_name]
		var/datum/universal_icon/icon = uni_icon(wings.icon, "m_moth_wings_[wings.icon_state]_BEHIND")
		values[wings.name] = icon
	return values


/datum/preference/choiced/moth_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value

