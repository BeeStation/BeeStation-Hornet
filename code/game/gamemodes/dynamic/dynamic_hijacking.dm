/datum/game_mode/dynamic/proc/setup_hijacking()
	RegisterSignal(SSdcs, COMSIG_GLOB_PRE_RANDOM_EVENT, .proc/on_pre_random_event)

/datum/game_mode/dynamic/proc/on_pre_random_event(datum/source, datum/round_event_control/round_event_control)
	if (!round_event_control.dynamic_should_hijack)
		return

	if (random_event_hijacked != HIJACKED_NOTHING)
		dynamic_log("Random event [round_event_control.name] tried to roll, but Dynamic vetoed it (random event has already ran).")
		SSevents.spawnEvent()
		SSevents.reschedule()
		return CANCEL_PRE_RANDOM_EVENT

	var/time_range = rand(random_event_hijack_minimum, random_event_hijack_maximum)

	if (world.time - last_midround_injection_attempt < time_range)
		random_event_hijacked = HIJACKED_TOO_RECENT
		dynamic_log("Random event [round_event_control.name] tried to roll, but the last midround injection \
			was too recent. Injection chance has been raised to [get_midround_injection_chance(dry_run = TRUE)]%.")
		return CANCEL_PRE_RANDOM_EVENT

	if (midround_injection_cooldown - world.time < time_range)
		random_event_hijacked = HIJACKED_TOO_SOON
		dynamic_log("Random event [round_event_control.name] tried to roll, but the next midround injection \
			is too soon. Injection chance has been raised to [get_midround_injection_chance(dry_run = TRUE)]%.")
		return CANCEL_PRE_RANDOM_EVENT
