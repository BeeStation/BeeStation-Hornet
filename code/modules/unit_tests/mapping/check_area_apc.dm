/datum/unit_test/map_test/apc/check_area(area/check_area)
	if (!check_area.requires_power)
		return
	if (!check_area.apc && !check_area.always_unpowered)
		return "No APC in an area that requires power"
	if (check_area.apc && check_area.always_unpowered)
		return "APC found in an always unpowered area"
