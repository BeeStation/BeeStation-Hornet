//Custom Shuttle
//Crew has to build a custom shuttle
/datum/station_goal/custom_shuttle
	name = "Custom Shuttle"

/datum/station_goal/custom_shuttle/get_report()
	return list(
		"<blockquote>Nanotrasen needs a new prototype light cruiser.",
		"We leave it up to you to decide what the shuttle needs to be an effective platform.",
		"",
		"You can create a designator in engineering or purchase one at cargo.</blockquote>",
	).Join("\n")

/datum/station_goal/custom_shuttle/check_completion()
	if(..())
		return TRUE
	if(GLOB.custom_shuttle_count)
		return TRUE
	return FALSE
