/datum/preference/choiced/ethereal_color
	db_key = "feature_ethcolor"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ethereal Color"
	should_generate_icons = TRUE

/datum/preference/choiced/ethereal_color/init_possible_values()
	var/list/values = list()

	var/datum/universal_icon/ethereal_base = uni_icon('icons/mob/human/species/ethereal/bodyparts.dmi', "ethereal_head")
	ethereal_base.blend_icon(uni_icon('icons/mob/human/species/ethereal/bodyparts.dmi', "ethereal_chest"), ICON_OVERLAY)
	ethereal_base.blend_icon(uni_icon('icons/mob/human/species/ethereal/bodyparts.dmi', "ethereal_l_arm"), ICON_OVERLAY)
	ethereal_base.blend_icon(uni_icon('icons/mob/human/species/ethereal/bodyparts.dmi', "ethereal_r_arm"), ICON_OVERLAY)

	var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes")
	eyes.blend_color(COLOR_BLACK, ICON_MULTIPLY)
	ethereal_base.blend_icon(eyes, ICON_OVERLAY)

	ethereal_base.scale(64, 64)
	ethereal_base.crop(15, 64 - 31, 15 + 31, 64)

	for (var/name in GLOB.color_list_ethereal)
		var/color = GLOB.color_list_ethereal[name]

		var/datum/universal_icon/icon = ethereal_base.copy()
		icon.blend_color("#[color]", ICON_MULTIPLY)
		values[name] = icon

	return values

/datum/preference/choiced/ethereal_color/deserialize(input, datum/preferences/preferences)
	if(findtext(input, GLOB.is_color_nocrunch)) // Migrate old data
		var/valid = assoc_key_for_value(GLOB.color_list_ethereal, LOWER_TEXT(input))
		if(!isnull(valid))
			return valid
	return ..()

/datum/preference/choiced/ethereal_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethcolor"] = GLOB.color_list_ethereal[value]

