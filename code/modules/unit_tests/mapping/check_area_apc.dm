/datum/unit_test/map_test/apc/check_area(area/check_area)
	// Make sure there are no APCs in unpowered areas
	if (check_area.apc && check_area.always_unpowered)
		return "APC found in an always unpowered area"
	// If you have power then I guess you pass
	if (check_area.powered(AREA_USAGE_ENVIRON))
		return
	// Otherwise, make sure we need power
	if (!check_area.apc && !check_area.always_unpowered)
		return "No APC in an area that requires power"
