/datum/preference/choiced/psyphoza_cap
	db_key = "feature_psyphoza_cap"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Mushroom Cap"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "psyphoza_cap"

/datum/preference/choiced/psyphoza_cap/init_possible_values()
	var/list/values = list()

	for (var/cap_name in GLOB.psyphoza_cap_list)
		var/datum/sprite_accessory/cap = GLOB.psyphoza_cap_list[cap_name]

		var/icon/icon_with_cap = icon('icons/mob/species/psyphoza/bodyparts.dmi', "psyphoza_head", dir = SOUTH)
		if (cap.icon_state != "none")
			var/icon/screen_icon = icon(cap.icon, "m_psyphoza_cap_[cap.icon_state]_ADJ", dir = SOUTH)
			icon_with_cap.Blend(screen_icon, ICON_OVERLAY)
		icon_with_cap.Scale(64, 64)
		icon_with_cap.Crop(15, 64, 15 + 31, 64 - 31)

		values[cap.name] = icon_with_cap

	return values

/datum/preference/choiced/psyphoza_cap/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["psyphoza_cap"] = value
