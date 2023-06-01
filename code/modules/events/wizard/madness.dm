/datum/round_event_control/wizard/madness
	name = "Brain Curse"
	weight = 1
	typepath = /datum/round_event/wizard/madness
	earliest_start = 0 MINUTES

	var/forced_secret

/datum/round_event_control/wizard/madness/admin_setup()
	if(!check_rights(R_FUN))
		return

/datum/round_event/wizard/madness/start()
	var/datum/round_event_control/wizard/madness/C = control
	brain_curse(null)

// note: this event used to give a random red pill question to people, but it's removed because it does actually nothing.
