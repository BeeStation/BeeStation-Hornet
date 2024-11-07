/// The visual style of a PDA
/datum/preference/choiced/pda_theme
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "pda_theme"
	preference_type = PREFERENCE_CHARACTER

/datum/preference/choiced/pda_theme/compile_ui_data(mob/user, value)
	return value // The default behavior is to serialize. Don't do that.

/datum/preference/choiced/pda_theme/deserialize(input, datum/preferences/preferences)
	for(var/key in GLOB.ntos_device_themes_default)
		if(GLOB.ntos_device_themes_default[key] == input || key == input)
			return key
	return "NtOS Default"

/datum/preference/choiced/pda_theme/serialize(input)
	for(var/key in GLOB.ntos_device_themes_default)
		var/value = GLOB.ntos_device_themes_default[key]
		if(value == input || key == input)
			return value
	return GLOB.ntos_device_themes_default[sanitize_inlist(input, get_choices(), "NtOS Default")]

/datum/preference/choiced/pda_theme/create_default_value()
	return "NtOS Default"

/datum/preference/choiced/pda_theme/init_possible_values()
	return assoc_to_keys(GLOB.ntos_device_themes_default)

/datum/preference/choiced/pda_theme/apply_to_human(mob/living/carbon/human/target, value)
	return

/// The color of a PDA with Thinktronic Classic
/datum/preference/color/pda_classic_color
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	db_key = "pda_classic_color"
	preference_type = PREFERENCE_CHARACTER

/datum/preference/color/pda_classic_color/create_default_value()
	return COLOR_OLIVE

/datum/preference/color/pda_classic_color/is_accessible(datum/preferences/preferences, ignore_page)
	return ..() && preferences.read_character_preference(/datum/preference/choiced/pda_theme) == "Thinktronic Classic"

/datum/preference/color/pda_classic_color/apply_to_human(mob/living/carbon/human/target, value)
	return
