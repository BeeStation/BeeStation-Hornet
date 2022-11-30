SUBSYSTEM_DEF(zfall)
	name = "Zfall"
	flags = SS_KEEP_TIMING|SS_TICKER
	wait = 5
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_ZFALL
	var/list/atom/movable/openspace_inhabitants = list()

/datum/controller/subsystem/zfall/proc/add_openspace_inhabitant(atom/movable/A)
	if(!istype(A) || (A in openspace_inhabitants) || (!isobj(A) && !ismob(A)))
		return
	RegisterSignal(A, COMSIG_PARENT_QDELETING, .proc/remove_openspace_inhabitant, A)
	openspace_inhabitants |= A

/datum/controller/subsystem/zfall/proc/remove_openspace_inhabitant(atom/movable/A)
	SIGNAL_HANDLER
	if(!(A in openspace_inhabitants))
		return
	UnregisterSignal(A, COMSIG_PARENT_QDELETING)
	openspace_inhabitants -= A

/datum/controller/subsystem/zfall/fire(resumed)
	var/list/removals = list()
	for(var/atom/movable/A as() in openspace_inhabitants)
		if(MC_TICK_CHECK)
			break
		var/turf/T = get_turf(A)
		if(!isopenspace(T))
			removals |= A
			continue
		if(!A.zfalling)
			T.zFall(A)
	if(MC_TICK_CHECK)
		return
	for(var/A as() in removals)
		remove_openspace_inhabitant(A)
