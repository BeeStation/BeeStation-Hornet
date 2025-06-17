/datum/preference/choiced/ipc_screen
	db_key = "feature_ipc_screen"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Screen Style"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/choiced/ipc_screen/init_possible_values()
	var/list/values = list()

	for (var/screen_name in GLOB.ipc_screens_list)
		var/datum/sprite_accessory/screen = GLOB.ipc_screens_list[screen_name]

		var/datum/universal_icon/icon_with_screen = uni_icon('icons/mob/species/ipc/bodyparts.dmi', "mcgipc_head", dir = SOUTH)
		if (screen_name != FEATURE_NONE)
			var/datum/universal_icon/screen_icon = uni_icon(screen.icon, "m_ipc_screen_[screen.icon_state]_ADJ", dir = SOUTH)
			icon_with_screen.blend_icon(screen_icon, ICON_OVERLAY)
		icon_with_screen.scale(64, 64)
		icon_with_screen.crop(15, 64 - 31, 15 + 31, 64)

		values[screen.name] = icon_with_screen

	return values

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value

/datum/preference/choiced/ipc_screen/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_ipc_screen_color"

	return data

/datum/preference/color_legacy/ipc_screen_color
	db_key = "feature_ipc_screen_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_mutant_bodypart = "ipc_antenna"
	priority = PREFERENCE_PRIORITY_EYE_COLOR

/datum/preference/color_legacy/ipc_screen_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!isipc(target))
		return
	target.eye_color = value
	var/obj/item/organ/eyes/eyes_organ = target.get_organ_by_type(/obj/item/organ/eyes)
	if (istype(eyes_organ))
		if (!initial(eyes_organ.eye_color))
			eyes_organ.eye_color = value
		eyes_organ.old_eye_color = value

/datum/preference/color_legacy/ipc_screen_color/create_default_value()
	return "fff"

/datum/preference/choiced/ipc_antenna
	db_key = "feature_ipc_antenna"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antenna Style"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/choiced/ipc_antenna/init_possible_values()
	var/list/values = list()

	for (var/antenna_name in GLOB.ipc_antennas_list)
		var/datum/sprite_accessory/antenna = GLOB.ipc_antennas_list[antenna_name]

		var/datum/universal_icon/icon_with_antennae = uni_icon('icons/mob/species/ipc/bodyparts.dmi', "mcgipc_head", dir = SOUTH)
		if (antenna.icon_state != "none")
			// weird snowflake shit
			var/side = (antenna_name == "Light" || antenna_name == "Drone Eyes") ? "FRONT" : "ADJ"
			var/datum/universal_icon/antenna_icon = uni_icon(antenna.icon, "m_ipc_antenna_[antenna.icon_state]_[side]", dir = SOUTH)
			icon_with_antennae.blend_icon(antenna_icon, ICON_OVERLAY)
		icon_with_antennae.scale(64, 64)
		icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

		values[antenna.name] = icon_with_antennae

	return values

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value

/datum/preference/choiced/ipc_antenna/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_ipc_antenna_color"

	return data

/datum/preference/color_legacy/ipc_antenna_color
	db_key = "feature_ipc_antenna_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_mutant_bodypart = "ipc_antenna"
	priority = PREFERENCE_PRIORITY_HAIR_COLOR

/datum/preference/color_legacy/ipc_antenna_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!isipc(target))
		return
	target.hair_color = value

/datum/preference/color_legacy/ipc_antenna_color/create_default_value()
	return "222"

/datum/preference/choiced/ipc_chassis
	db_key = "feature_ipc_chassis"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Chassis Style"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/choiced/ipc_chassis/init_possible_values()
	var/list/values = list()
	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	for (var/chassis_name in GLOB.ipc_chassis_list)
		var/datum/sprite_accessory/chassis = GLOB.ipc_chassis_list[chassis_name]
		var/datum/universal_icon/icon_with_chassis = uni_icon('icons/effects/effects.dmi', "nothing")

		for (var/body_part in body_parts)
			icon_with_chassis.blend_icon(uni_icon('icons/mob/species/ipc/bodyparts.dmi', "[chassis.limbs_id]_[body_part]", dir = SOUTH), ICON_OVERLAY)

		values[chassis.name] = icon_with_chassis

	return values

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_chassis"] = value
