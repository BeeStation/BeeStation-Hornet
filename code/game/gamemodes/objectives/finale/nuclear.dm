/datum/objective/nuclear
	name = "nuclear"
	explanation_text = "Destroy the station with a nuclear device."
	murderbone_flag = TRUE

/datum/objective/nuclear/check_completion()
	if(GLOB.station_was_nuked)
		return TRUE
	return ..()
