/datum/preference/choiced/skin_tone
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	preference_type = PREFERENCE_CHARACTER
	db_key = "skin_tone"

/datum/preference/choiced/skin_tone/init_possible_values()
	return GLOB.skin_tones

/datum/preference/choiced/skin_tone/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.skin_tone_names

	var/list/to_hex = list()
	for (var/choice in get_choices())
		var/hex_value = skintone2hex(choice)
		var/list/hsl = rgb2num(hex_value, COLORSPACE_HSL)

		to_hex[choice] = list(
			"lightness" = hsl[3],
			"value" = hex_value,
		)

	data["to_hex"] = to_hex

	return data

/datum/preference/choiced/skin_tone/apply_to_human(mob/living/carbon/human/target, value)
	target.skin_tone = value

/datum/preference/choiced/skin_tone/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	var/datum/species/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	return initial(species_type.use_skintones)
