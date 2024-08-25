/datum/unit_test/map_test/lights/check_turf(turf/check_turf, is_map_border)
	. = list()
	var/found = FALSE
	var/types = list()
	for (var/obj/object in check_turf)
		if (!isstructure(object) && !ismachinery(object))
			continue
		var/hash = "[object.type][object.dir]"
		if (istype(/obj/structure/power/cable))
			var/obj/structure/power/cable/cable = object
			hash = "[hash][min(cable.d1, cable.d2)][max(cable.d1, cable.d2)]"
		if (types[hash])
			. += "Multiple objects of type [object.type] detected on the same tile, with the same direction."
		else
			types[hash] = 1

