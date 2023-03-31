/// Responsible for triggering mob zfalls when they are not already triggered by structure deconstruction or moving into openspace
SUBSYSTEM_DEF(zfall)
	name = "Zfall"
	flags = SS_TICKER
	wait = 5
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_ZFALL
	var/list/atom/movable/openspace_inhabitants = list()
	var/datum/enumerator/enumerator

/datum/controller/subsystem/zfall/proc/add_openspace_inhabitant(atom/movable/A)
	if(!ismob(A) || (A in openspace_inhabitants))
		return
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(remove_openspace_inhabitant), A)
	openspace_inhabitants |= A

/datum/controller/subsystem/zfall/proc/remove_openspace_inhabitant(atom/movable/A)
	SIGNAL_HANDLER
	if(!(A in openspace_inhabitants))
		return
	UnregisterSignal(A, COMSIG_PARENT_QDELETING)
	openspace_inhabitants -= A

/datum/controller/subsystem/zfall/proc/check_z_fall(atom/movable/A)
	var/turf/T = get_turf(A)
	if(!isopenspace(T))
		remove_openspace_inhabitant(A)
		return
	if(!A.zfalling)
		T.try_start_zFall(A)

/datum/controller/subsystem/zfall/fire()
	if(enumerator == null)
		var/datum/enumerator/E = get_list_enumerator(openspace_inhabitants.Copy())
		enumerator = E.foreach(CALLBACK(src, PROC_REF(check_z_fall)))
	//Run over the enumerators while we are allowed
	var/enumerator_has_next = enumerator.has_next()
	while (enumerator_has_next)
		//Enumerate the current element (This doesn't do anything with the value, but may run side-effectful actions)
		enumerator.next()
		//Check the next element
		enumerator_has_next = enumerator.has_next()
		//Tick check, if necessary
		if (MC_TICK_CHECK)
			break
	//The enumeration has finished
	if (!enumerator_has_next)
		enumerator = null // reset the enumerator

