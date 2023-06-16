/datum/preference/color_legacy/underwear_color
	db_key = "underwear_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES

/datum/preference/color_legacy/underwear_color/apply_to_human(mob/living/carbon/human/target, value)
	target.underwear_color = value

/datum/preference/color_legacy/underwear_color/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	var/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return !(NO_UNDERWEAR in species.species_traits)
