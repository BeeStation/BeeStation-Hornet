/datum/preference/choiced/species_feature/apid_stripes
	db_key = "feature_apid_stripes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Stripe Pattern"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_stripes"
	feature_key = FEATURE_APID_STRIPES

/datum/preference/choiced/species_feature/apid_stripes/icon_for(value)
	var/datum/sprite_accessory/stripe = get_accessory_for_value(value)

	var/datum/universal_icon/icon_with_stripes = uni_icon('icons/mob/species/apid/bodyparts.dmi', "apid_chest_m", dir = SOUTH)
	if (stripe.icon_state != "none")
		var/datum/universal_icon/stripes_icon = uni_icon(stripe.icon, "m_apid_stripes_[stripe.icon_state]_ADJ", dir = SOUTH)
		stripes_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
		icon_with_stripes.blend_icon(stripes_icon, ICON_OVERLAY)

	icon_with_stripes.crop(10, 8, 22, 23)
	icon_with_stripes.scale(26, 32)
	icon_with_stripes.crop(-2, 1, 29, 32)

	return icon_with_stripes

/datum/preference/choiced/species_feature/apid_antenna
	db_key = "feature_apid_antenna"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae Style"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_antenna"
	feature_key = FEATURE_APID_ANTENNA

/datum/preference/choiced/species_feature/apid_antenna/icon_for(value)
	var/static/datum/universal_icon/apid_head

	if (isnull(apid_head))
		apid_head = uni_icon('icons/mob/species/apid/bodyparts.dmi', "apid_head_m", dir = SOUTH)

	var/datum/sprite_accessory/antenna = get_accessory_for_value(value)

	var/datum/universal_icon/icon_with_antennae = apid_head.copy()
	if (antenna.icon_state != "none")
		var/datum/universal_icon/antenna_icon = uni_icon(antenna.icon, "m_apid_antenna_[antenna.icon_state]_ADJ", dir = SOUTH)
		antenna_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
		icon_with_antennae.blend_icon(antenna_icon, ICON_OVERLAY)
	icon_with_antennae.scale(64, 64)
	icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_antennae

/datum/preference/choiced/species_feature/apid_headstripes
	db_key = "feature_apid_headstripes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Headstripe Pattern"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_headstripes"
	feature_key = FEATURE_APID_HEADSTRIPES

/datum/preference/choiced/species_feature/apid_headstripes/icon_for(value)
	var/static/datum/universal_icon/apid_head

	if (isnull(apid_head))
		apid_head = uni_icon('icons/mob/species/apid/bodyparts.dmi', "apid_head_m", dir = SOUTH)

	var/datum/sprite_accessory/headstripe = get_accessory_for_value(value)

	var/datum/universal_icon/icon_with_headstripes = apid_head.copy()
	if (headstripe.icon_state != "none")
		var/datum/universal_icon/headstripes_icon = uni_icon(headstripe.icon, "m_apid_headstripes_[headstripe.icon_state]_ADJ", dir = SOUTH)
		headstripes_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
		icon_with_headstripes.blend_icon(headstripes_icon, ICON_OVERLAY)
	icon_with_headstripes.scale(64, 64)
	icon_with_headstripes.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_headstripes
