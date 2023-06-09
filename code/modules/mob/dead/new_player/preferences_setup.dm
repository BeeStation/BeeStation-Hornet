/// Fully randomizes everything in the character.
/datum/preferences/proc/randomise_appearance_prefs(randomize_flags = ALL)
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			write_preference(preference, preference.create_random_value(src))

/// Randomizes the character according to preferences.
/datum/preferences/proc/apply_character_randomization_prefs(antag_override = FALSE)
	switch (read_character_preference(/datum/preference/choiced/random_body))
		if (RANDOM_ANTAG_ONLY)
			if (!antag_override)
				return

		if (RANDOM_DISABLED)
			return

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (should_randomize(preference, antag_override))
			write_preference(preference, preference.create_random_value(src))

/// Returns what job is marked as highest
/datum/preferences/proc/get_highest_priority_job()
	var/datum/job/preview_job
	var/highest_pref = 0

	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			preview_job = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	return preview_job

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/datum/job/preview_job = get_highest_priority_job()

	if(preview_job)
		// Silicons only need a very basic preview since there is no customization for them.
		if (istype(preview_job,/datum/job/ai))
			return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(read_character_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
		if (istype(preview_job,/datum/job/cyborg))
			return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE)

	if(preview_job)
		mannequin.job = preview_job.title
		preview_job.equip(mannequin, TRUE, preference_source = parent)
		preview_job.after_spawn(mannequin, mannequin, preference_source = parent, on_dummy = TRUE)
	else
		apply_loadout_to_mob(mannequin, mannequin, preference_source = parent, on_dummy = TRUE)

	COMPILE_OVERLAYS(mannequin)
	return mannequin.appearance
