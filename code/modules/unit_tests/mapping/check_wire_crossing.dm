/datum/unit_test/map_test/check_wire_crossing/check_turf(turf/check_turf, is_map_border)
	var/list/powernets = null
	for (var/obj/structure/cable/cable in check_turf)
		if (!powernets)
			powernets = list()
		if (!powernets[cable.color])
			powernets[cable.color] = cable.powernet
		else if (powernets[cable.color] != cable.powernet)
			return "Two wires with the [cable.color] colour were on the same tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."
	// Check adjacent turfs
	for (var/obj/structure/cable/cable in get_step(check_turf, NORTH))
		if (!powernets)
			powernets = list()
		// If we don't have that colour, its fine
		if (!powernets[cable.color])
			continue
		else if (powernets[cable.color] != cable.powernet)
			return "Two wires with the [cable.color] colour were on the adjacent tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."
	// Check adjacent turfs
	for (var/obj/structure/cable/cable in get_step(check_turf, EAST))
		if (!powernets)
			powernets = list()
		// If we don't have that colour, its fine
		if (!powernets[cable.color])
			continue
		else if (powernets[cable.color] != cable.powernet)
			return "Two wires with the [cable.color] colour were on the adjacent tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."

