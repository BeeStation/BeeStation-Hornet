SUBSYSTEM_DEF(hub)
	name = "Hub Entry"
	ss_flags = SS_NO_INIT
	wait = 1 MINUTES

/datum/controller/subsystem/hub/fire(resumed)
	world.update_status()
