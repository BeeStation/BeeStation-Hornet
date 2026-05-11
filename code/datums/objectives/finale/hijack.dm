/datum/objective/hijack
	name = "hijack"
	explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols using the shuttle computer."
	team_explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols, using the shuttle computer. Leave no team member behind."
	murderbone_flag = TRUE

	/// Overrides the hijack speed of any antagonist datum it is on ONLY, no other datums are impacted.
	var/hijack_speed_override = 1

/datum/objective/hijack/check_completion() // Requires all owners to escape.
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/objective_owner as anything in get_owners())
		if(!considered_alive(objective_owner) || !SSshuttle.emergency.shuttle_areas[get_area(objective_owner.current)])
			return ..()
	return SSshuttle.emergency.is_hijacked() || ..()
