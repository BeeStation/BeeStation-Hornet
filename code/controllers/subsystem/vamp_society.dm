SUBSYSTEM_DEF(society)
	name = "Vampire Society"
	wait = 10 MINUTES
	flags = SS_NO_INIT | SS_BACKGROUND | SS_TICKER

	///If the Society is currently active or not.
	var/society_active = FALSE


/datum/controller/subsystem/society/fire(resumed = FALSE)
