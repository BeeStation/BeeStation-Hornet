/datum/preference/choiced/apid_stripes
	db_key = "feature_apid_stripes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Stripe Pattern"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_stripes"

/datum/preference/choiced/apid_stripes/init_possible_values()
	var/list/values = list()

	for (var/stripe_name in GLOB.apid_stripes_list)
		var/datum/sprite_accessory/stripe = GLOB.apid_stripes_list[stripe_name]

		var/datum/universal_icon/icon_with_stripes = uni_icon('icons/mob/human/species/apid/bodyparts.dmi', "apid_chest_m", dir = SOUTH)
		if (stripe.icon_state != "none")
			var/datum/universal_icon/stripes_icon = uni_icon(stripe.icon, "m_apid_stripes_[stripe.icon_state]_ADJ", dir = SOUTH)
			stripes_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
			icon_with_stripes.blend_icon(stripes_icon, ICON_OVERLAY)

		icon_with_stripes.crop(10, 8, 22, 23)
		icon_with_stripes.scale(26, 32)
		icon_with_stripes.crop(-2, 1, 29, 32)

		values[stripe.name] = icon_with_stripes

	return values

/datum/preference/choiced/apid_stripes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_stripes"] = value

/datum/preference/choiced/apid_antenna
	db_key = "feature_apid_antenna"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae Style"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_antenna"

/datum/preference/choiced/apid_antenna/init_possible_values()
	var/list/values = list()

	for (var/antenna_name in GLOB.apid_antenna_list)
		var/datum/sprite_accessory/antenna = GLOB.apid_antenna_list[antenna_name]

		var/datum/universal_icon/icon_with_antennae = uni_icon('icons/mob/human/species/apid/bodyparts.dmi', "apid_head_m", dir = SOUTH)
		if (antenna.icon_state != "none")
			var/datum/universal_icon/antenna_icon = uni_icon(antenna.icon, "m_apid_antenna_[antenna.icon_state]_ADJ", dir = SOUTH)
			antenna_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
			icon_with_antennae.blend_icon(antenna_icon, ICON_OVERLAY)
		icon_with_antennae.scale(64, 64)
		icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

		values[antenna.name] = icon_with_antennae

	return values

/datum/preference/choiced/apid_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_antenna"] = value

/datum/preference/choiced/apid_headstripes
	db_key = "feature_apid_headstripes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Headstripe Pattern"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "apid_headstripes"

/datum/preference/choiced/apid_headstripes/init_possible_values()
	var/list/values = list()

	for (var/headstripe_name in GLOB.apid_headstripes_list)
		var/datum/sprite_accessory/headstripe = GLOB.apid_headstripes_list[headstripe_name]

		var/datum/universal_icon/icon_with_headstripes = uni_icon('icons/mob/human/species/apid/bodyparts.dmi', "apid_head_m", dir = SOUTH)
		if (headstripe.icon_state != "none")
			var/datum/universal_icon/headstripes_icon = uni_icon(headstripe.icon, "m_apid_headstripes_[headstripe.icon_state]_ADJ", dir = SOUTH)
			headstripes_icon.blend_color(COLOR_YELLOW, ICON_MULTIPLY)
			icon_with_headstripes.blend_icon(headstripes_icon, ICON_OVERLAY)
		icon_with_headstripes.scale(64, 64)
		icon_with_headstripes.crop(15, 64 - 31, 15 + 31, 64)

		values[headstripe.name] = icon_with_headstripes

	return values

/datum/preference/choiced/apid_headstripes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_headstripes"] = value
