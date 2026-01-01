/// Handles the assets for species icons
/datum/preference_middleware/species

/datum/preference_middleware/species/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/species),
	)

/datum/preference_middleware/species/post_set_preference(mob/user, preference, previous_value, value)
	// Wrong preference
	if (preference != /datum/preference/choiced/species::db_key)
		return

	var/datum/species/old_species = previous_value
	var/datum/species/new_species = value

	if (old_species == new_species)
		return
	if (ispath(old_species, /datum/species) && ispath(new_species, /datum/species) && old_species::name_key && old_species::name_key == new_species::name_key)
		return

	var/datum/preference/name/name_preference = GLOB.preference_entries[/datum/preference/name/real_name]
	if (!istype(name_preference))
		return

	log_preferences("[preferences?.parent?.ckey]: Randomized name preference as result of species change [name_preference.type]")
	preferences.update_preference(name_preference, name_preference.create_random_value(preferences), in_menu = TRUE)
	preferences.update_current_character_profile()

/datum/asset/spritesheet/species
	name = "species"
	early = TRUE

/datum/asset/spritesheet/species/create_spritesheets()
	var/list/to_insert = list()

	for (var/species_id in get_selectable_species())
		var/datum/species/species_type = GLOB.species_list[species_id]

		var/mob/living/carbon/human/dummy/consistent/dummy = new
		dummy.set_species(species_type)
		dummy.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
		dummy.dna.species.prepare_human_for_preview(dummy)
		COMPILE_OVERLAYS(dummy)

		var/icon/dummy_icon = getFlatIcon(dummy)
		dummy_icon.Scale(64, 64)
		dummy_icon.Crop(15, 64 - 31, 15 + 31, 64)
		dummy_icon.Scale(64, 64)
		to_insert[sanitize_css_class_name(initial(species_type.name))] = dummy_icon

		SSatoms.prepare_deletion(dummy)

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])
