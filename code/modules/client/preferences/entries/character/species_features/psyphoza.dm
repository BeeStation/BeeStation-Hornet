/datum/preference/choiced/psyphoza_cap
	db_key = "feature_psyphoza_cap"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Mushroom Cap"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "psyphoza_cap"

/datum/preference/choiced/psyphoza_cap/init_possible_values()
	return assoc_to_keys_features(SSaccessories.psyphoza_cap_list)

/datum/preference/choiced/psyphoza_cap/icon_for(value)
	var/static/datum/universal_icon/psyphoza_head

	if (isnull(psyphoza_head))
		psyphoza_head = uni_icon('icons/mob/human/species/psyphoza/bodyparts.dmi', "psyphoza_head", dir = SOUTH)

	var/datum/sprite_accessory/cap = SSaccessories.psyphoza_cap_list[value]
	var/datum/universal_icon/icon_with_cap = psyphoza_head.copy()

	if (value != FEATURE_NONE)
		var/datum/universal_icon/screen_icon = uni_icon(cap.icon, "m_psyphoza_cap_[cap.icon_state]_ADJ", dir = SOUTH)
		icon_with_cap.blend_icon(screen_icon, ICON_OVERLAY)

	icon_with_cap.scale(64, 64)
	icon_with_cap.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_cap

/datum/preference/choiced/psyphoza_cap/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["psyphoza_cap"] = value
