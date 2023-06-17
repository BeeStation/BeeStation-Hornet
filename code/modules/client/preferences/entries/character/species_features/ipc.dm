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

		var/icon/icon_with_screen = icon('icons/mob/species/ipc/bodyparts.dmi', "mcgipc_head", dir = SOUTH)
		if (screen.icon_state != "none")
			var/icon/screen_icon = icon(screen.icon, "m_ipc_screen_[screen.icon_state]_ADJ", dir = SOUTH)
			icon_with_screen.Blend(screen_icon, ICON_OVERLAY)
		icon_with_screen.Scale(64, 64)
		icon_with_screen.Crop(15, 64, 15 + 31, 64 - 31)

		values[screen.name] = icon_with_screen

	return values

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value

/datum/preference/choiced/ipc_screen/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "eye_color"

	return data

/// God forgive me for this
/datum/preference/color_legacy/eye_color/ipc
	db_key = "eye_color"
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = null

/datum/preference/color_legacy/eye_color/ipc/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && ispath(preferences.read_character_preference(/datum/preference/choiced/species), /datum/species/ipc)

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

		var/icon/icon_with_antennae = icon('icons/mob/species/ipc/bodyparts.dmi', "mcgipc_head", dir = SOUTH)
		if (antenna.icon_state != "none")
			// weird snowflake shit
			var/side = (antenna_name == "Light" || antenna_name == "Drone Eyes") ? "FRONT" : "ADJ"
			var/icon/antenna_icon = icon(antenna.icon, "m_ipc_antenna_[antenna.icon_state]_[side]", dir = SOUTH)
			icon_with_antennae.Blend(antenna_icon, ICON_OVERLAY)
		icon_with_antennae.Scale(64, 64)
		icon_with_antennae.Crop(15, 64, 15 + 31, 64 - 31)

		values[antenna.name] = icon_with_antennae

	return values

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value

/datum/preference/choiced/ipc_antenna/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"

	return data

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
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	for (var/chassis_name in GLOB.ipc_chassis_list)
		var/datum/sprite_accessory/chassis = GLOB.ipc_chassis_list[chassis_name]
		var/icon/icon_with_chassis = icon('icons/effects/effects.dmi', "nothing")

		for (var/body_part in body_parts)
			icon_with_chassis.Blend(icon('icons/mob/species/ipc/bodyparts.dmi', "[chassis.limbs_id]_[body_part]", dir = SOUTH), ICON_OVERLAY)

		// Zoom in
		icon_with_chassis.Scale(64, 64)
		icon_with_chassis.Crop(15, 64, 15 + 31, 64 - 31)

		values[chassis.name] = icon_with_chassis

	return values

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_chassis"] = value
