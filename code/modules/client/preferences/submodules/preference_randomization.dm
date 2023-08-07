/// Fully randomizes everything in the character.
/datum/preferences/proc/randomize_appearance_prefs(randomize_flags = ALL)
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			write_preference(preference, preference.create_random_value(src))

/// Randomizes the character according to preferences.
/datum/preferences/proc/apply_character_randomization_prefs(antag_override = FALSE)
	var/body_choice = read_character_preference(/datum/preference/choiced/random_body)
	if (body_choice == RANDOM_ANTAG_ONLY)
		if (!antag_override)
			return
	else if (body_choice != RANDOM_ENABLED)
		return

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (should_randomize(preference, antag_override))
			write_preference(preference, preference.create_random_value(src))

/// Returns the default `randomise` variable ouptut
/datum/preferences/proc/get_default_randomization()
	var/list/default_randomization = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (preference.is_randomizable() && preference.randomize_by_default)
			default_randomization[preference_key] = RANDOM_ENABLED

	return default_randomization

/// Sanitizes the preferences, applies the randomization prefs, and then applies the preference to the human mob.
/// This is generally used over apply_prefs_to, since it respects the player's body/antag randomization
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	apply_prefs_to(character, icon_updates)
