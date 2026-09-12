/// Ceiling on the station's standing power draw at roundstart, summed across every powered
/// area, in watts per machine tick.
///
/// If you trip this, the answer is not "I should make the number below bigger",
// its "does your little metastation clone power itself?""
#define STATION_ROUNDSTART_POWER_BUDGET (400 KILOWATT)

/// How many of the heaviest areas to name when reporting
#define POWER_BUDGET_REPORT_COUNT 8

/datum/unit_test/map_test/station_power_budget
	/// Total standing draw seen so far, in watts per tick
	var/total_draw = 0
	/// area type by their standing draw, for the report
	var/list/draw_by_area = list()

/datum/unit_test/map_test/station_power_budget/check_area(area/check_area)
	if(!check_area.requires_power || check_area.always_unpowered)
		return

	// Only the static channels. Dynamics are a type of "surge" and are not continous in their application
	var/area_draw = 0
	for(var/channel in AREA_USAGE_STATIC_START to AREA_USAGE_STATIC_END)
		area_draw += check_area.power_usage[channel]

	if(area_draw <= 0)
		return

	total_draw += area_draw
	draw_by_area[check_area.type] = area_draw

/datum/unit_test/map_test/station_power_budget/check_map()
	// Report always
	var/list/report = list("Station roundstart standing draw: [display_power(total_draw)] across [length(draw_by_area)] powered areas (budget [display_power(STATION_ROUNDSTART_POWER_BUDGET)]).")

	var/list/remaining = draw_by_area.Copy()
	for(var/i in 1 to min(POWER_BUDGET_REPORT_COUNT, length(remaining)))
		var/heaviest_type
		var/heaviest_draw = 0
		for(var/area_type in remaining)
			if(remaining[area_type] > heaviest_draw)
				heaviest_draw = remaining[area_type]
				heaviest_type = area_type
		if(!heaviest_type)
			break
		report += "  [display_power(heaviest_draw)] - [heaviest_type]"
		remaining -= heaviest_type

	log_world(jointext(report, "\n"))

	if(total_draw > STATION_ROUNDSTART_POWER_BUDGET)
		return "Station roundstart draw is [display_power(total_draw)], over the \
			[display_power(STATION_ROUNDSTART_POWER_BUDGET)] budget. \
			If this is intended, raise STATION_ROUNDSTART_POWER_BUDGET and say why in your PR, \
			power generation was not raised to match unless you also changed it."

#undef STATION_ROUNDSTART_POWER_BUDGET
#undef POWER_BUDGET_REPORT_COUNT
