GLOBAL_LIST_EMPTY(tracks_by_type)

/datum/component/trackable/Initialize(...)
	var/atom/object = parent
	if (!istype(object))
		return COMPONENT_INCOMPATIBLE
	if (!GLOB.tracks_by_type[object.type])
		GLOB.tracks_by_type[object.type] = list(object)
	else
		GLOB.tracks_by_type[object.type] += object

/datum/component/trackable/Destroy(force, silent)
	var/atom/object = parent
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
