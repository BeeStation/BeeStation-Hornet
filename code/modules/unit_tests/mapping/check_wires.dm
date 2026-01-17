
/datum/unit_test/map_test/check_wires/check_turf(turf/check_turf, is_map_border)
	. = ..()
	var/cable_node_count = 0
	for (var/obj/structure/cable/wire in check_turf)
		if (wire.has_power_node)
			cable_node_count ++
	if (cable_node_count > 1)
		return "Location has [cable_node_count] power nodes, which is not allowed. Overlapping wires are not allowed when something that connects to the power grid is on that tile."
