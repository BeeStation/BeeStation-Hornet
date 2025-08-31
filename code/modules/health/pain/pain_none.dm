/datum/pain_source/none

/datum/pain_source/none/update_pain(pain_value)
	return

/datum/pain_source/none/enter_pain_crit()
	return

/datum/pain_source/none/exit_pain_crit()
	return

/// Set an active pain source that automatically clears after some time
/datum/pain_source/none/set_pain_source_until(amount, source, time)
	return

/// Provide a source of consciousness. Without one consciousness will be 0, which is dead.
/// Source: The source of the modifier
/// Amount: The amount of consciousness provided by the source.
/datum/pain_source/none/set_pain_source(amount, source)
	return

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/pain_source/none/set_pain_modifier(amount, source)
	return

/// Add a pain message caused by a specific source
/datum/pain_source/none/add_pain_message(message, source)
	return

/// Remove all pain messages associated with that source
/datum/pain_source/none/remove_pain_messages(source)
	return
