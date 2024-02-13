/**
 * This is the preference for the player's SpaceMessenger ringtone.
 * Currently only applies to humans spawned in with a job, as it's hooked
 * into `/datum/job/proc/after_spawn()`.
 */
/datum/preference/string/pda_ringtone
	db_key = "pda_ringtone"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	maximum_value_length = MESSENGER_RINGTONE_MAX_LENGTH


/datum/preference/string/pda_ringtone/create_default_value()
	return MESSENGER_RINGTONE_DEFAULT


// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/string/pda_ringtone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
