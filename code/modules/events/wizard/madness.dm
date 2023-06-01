/datum/round_event_control/wizard/madness
	name = "Curse of Madness"
	weight = 1
	typepath = /datum/round_event/wizard/madness
	earliest_start = 0 MINUTES

	var/forced_secret

/datum/round_event_control/wizard/madness/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/suggested = pick(strings(REDPILL_FILE, "redpill_questions"))

	forced_secret = capped_input(usr, "What horrifying truth will you reveal? This will be added to the twisted reality facts.", "Curse of Madness", sort_list(suggested)) || suggested

/datum/round_event/wizard/madness/start()
	var/datum/round_event_control/wizard/madness/C = control

	var/horrifying_truth

	if(C.forced_secret)
		horrifying_truth = C.forced_secret
		C.forced_secret = null
	else
		horrifying_truth = pick(strings(REDPILL_FILE, "redpill_questions"))

	message_admins("Random wizard event made a curse of reality with the message \"[horrifying_truth]\"!")
	log_game("Random wizard event made a curse of reality with the message \"[horrifying_truth]\"!")
	curse_of_twisted_reality(null, horrifying_truth)
