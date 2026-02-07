GLOBAL_LIST_EMPTY(tracks_by_type)

/datum/element/trackable
	element_flags = ELEMENT_DETACH

/datum/element/trackable/Attach(datum/target)
	var/atom/object = target
	if (!istype(object))
		return ELEMENT_INCOMPATIBLE
	if (!GLOB.tracks_by_type[object.type])
		GLOB.tracks_by_type[object.type] = list(object)
	else
		GLOB.tracks_by_type[object.type] += object
	return ..()

/datum/element/trackable/Detach(datum/source, ...)
	. = ..()
	var/atom/object = source
	if (istype(object))
		GLOB.tracks_by_type[object.type] -= object
	return ..()

/proc/get_trackables_by_type(typepath, locate_subtypes)
	if (locate_subtypes)
		var/list/results = list()
		for (var/type in typesof(typepath))
			results += GLOB.tracks_by_type[type]
		return results
	return GLOB.tracks_by_type[typepath]
