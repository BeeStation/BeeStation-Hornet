/datum/unit_test/map_test/check_multiple_objects/check_turf(turf/check_turf, is_map_border)
	var/list/powernets = list()
	for (var/obj/structure/cable/cable in check_turf)
		if (!powernets[cable.color])
			powernets[cable.color] = cable.powernet
		else if (powernets[cable.color] != cable.powernet)
			return "Two wires with the [cable.color] colour were on the same tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."

