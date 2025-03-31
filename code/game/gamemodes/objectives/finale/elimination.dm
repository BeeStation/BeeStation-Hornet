/datum/objective/elimination
	name = "elimination"
	explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle."
	team_explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle. Leave no team member behind."
	martyr_compatible = FALSE
	murderbone_flag = TRUE

/datum/objective/elimination/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.elimination_hijack() || ..()

/datum/objective/elimination/highlander
	name="highlander elimination"
	explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."

/datum/objective/elimination/highlander/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.elimination_hijack(filter_by_human = FALSE, solo_hijack = TRUE) || ..()
