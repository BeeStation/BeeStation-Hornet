/datum/element/cleaning/Attach(datum/target)
	. = ..()
	if(!ismovableatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/Clean)

/datum/element/cleaning/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cleaning/proc/Clean(datum/source)
	var/atom/movable/AM = source
	var/turf/tile = AM.loc
	if(!isturf(tile))
		return
