/datum/unit_test/map_test/abstract/check_turf(turf/check_turf, is_map_border)
	var/list/failures = list()
	for(var/atom/object in check_turf)
		if (object.abstract_type == object.type)
			failures += "Abstract object, [object.type], placed on map. Please remove this or use a correct subtype."
	if (length(failures))
		return jointext(failures, "\n")
