/datum/unit_test/map_test/apc/check_area(area/check_area)
	// Make sure there are no APCs in unpowered areas
	if (check_area.apc && check_area.always_unpowered)
		return "APC found in an always unpowered area"
	if (check_area.apc && !check_area.requires_power)
		return "APC found in an area that does not require power"
	// If you have power then I guess you pass
	if (check_area.area_flags & REMOTE_APC)
		return
	// Otherwise, make sure we need power
	if (!check_area.apc && (!check_area.always_unpowered && check_area.requires_power))
		return "No APC in an area that requires power"
