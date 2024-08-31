/datum/unit_test/map_test/check_multiple_objects/check_turf(turf/check_turf, is_map_border)
	var/result = list()
	var/types = list()
	for (var/obj/object in check_turf)
		if (!isstructure(object) && !ismachinery(object))
			continue
		var/hash = "[object.type][object.dir][object.pixel_x][object.pixel_y]"
		if (istype(object, /obj/structure/cable))
			var/obj/structure/cable/cable = object
			hash = "[hash][min(cable.d1, cable.d2)][max(cable.d1, cable.d2)]"
		if (istype(object, /obj/machinery/atmospherics))
			var/obj/machinery/atmospherics/atmosmachine = object
			// 2 atmosmachines should never be on the same turf with the same layer
			// unless they are crossing
			hash = "/obj/machinery/atmospherics/[atmosmachine.piping_layer]"
			if (atmosmachine.device_type == BINARY)
				hash = "[hash][atmosmachine.dir <= 2 ? 1 : 0]"
		if (types[hash])
			result += "Multiple objects of type [object.type] detected on the same tile, with the same direction."
		else
			types[hash] = 1
	if (length(result))
		return result
	return null
