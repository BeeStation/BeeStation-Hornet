SUBSYSTEM_DEF(stat)
	name = "Stat"
	wait = 2 SECONDS
	priority = FIRE_PRIORITY_STAT
	runlevels = RUNLEVEL_INIT | RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/stat/Initialize(start_timeofday)
	//Make it display (It will only auto update after INIT is complete, but this allows them to change tabs.)
	for(var/client/C in GLOB.clients)
		C.mob?.UpdateMobStat()
	return ..()

/datum/controller/subsystem/stat/fire(resumed = 0)
	if (!resumed)
		src.currentrun = GLOB.clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if (C)
			var/mob/M = C.mob

			if(M)
				M.UpdateMobStat()

		if (MC_TICK_CHECK)
			return
