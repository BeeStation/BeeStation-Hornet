SUBSYSTEM_DEF(callbacks)
	name = "Auxtools Callbacks"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CALLBACKS

/proc/process_callbacks()
	SScallbacks.can_fire = 0
	SScallbacks.flags |= SS_NO_FIRE
	CRASH("Auxtools not found! Callback subsystem shutting itself off.")

/datum/controller/subsystem/callbacks/fire()
	if(process_callbacks(null,MC_TICK_REMAINING_MS))
		pause()
