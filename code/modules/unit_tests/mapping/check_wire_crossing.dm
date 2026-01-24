/datum/unit_test/map_test/check_wire_crossing/check_turf(turf/check_turf, is_map_border)
	// Smartwires reduces the number of wire colours, so we need
	// to make sure we won't get accidental connections
	var/static/list/powernet_lookup = list(
		"red" = "red",
		"yellow" = "yellow",
		"green" = "green",
		"blue" = "pink",
		"pink" = "pink",
		"orange" = "orange",
		"cyan" = "orange",
		"white" = "pink",
	)
	var/list/powernets = null
	for (var/obj/structure/cable/cable in check_turf)
		if (!powernets)
			powernets = list()
		var/actual_colour = powernet_lookup[cable::cable_color]
		if (!powernets[actual_colour])
			powernets[actual_colour] = cable.powernet
		else if (powernets[actual_colour] != cable.powernet)
			return "Two wires with the [cable::cable_color] colour were on the same tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."
	// Check adjacent turfs
	for (var/obj/structure/cable/cable in get_step(check_turf, NORTH))
		if (!powernets)
			powernets = list()
		var/actual_colour = powernet_lookup[cable::cable_color]
		// If we don't have that colour, its fine
		if (!powernets[actual_colour])
			continue
		else if (powernets[actual_colour] != cable.powernet)
			return "Two wires with the [cable::cable_color] colour were on the adjacent tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."
	// Check adjacent turfs
	for (var/obj/structure/cable/cable in get_step(check_turf, EAST))
		if (!powernets)
			powernets = list()
		var/actual_colour = powernet_lookup[cable::cable_color]
		// If we don't have that colour, its fine
		if (!powernets[actual_colour])
			continue
		else if (powernets[actual_colour] != cable.powernet)
			return "Two wires with the [cable::cable_color] colour were on the adjacent tile with different powernets. This will cause issues when we update to smartcables, please connect these cables or use a different colour."

