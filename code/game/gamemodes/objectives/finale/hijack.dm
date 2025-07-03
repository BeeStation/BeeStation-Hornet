/datum/objective/hijack
	name = "hijack"
	explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols using the shuttle computer."
	team_explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols, using the shuttle computer. Leave no team member behind."
	martyr_compatible = FALSE //Technically you won't get both anyway.
	/// Overrides the hijack speed of any antagonist datum it is on ONLY, no other datums are impacted.
	var/hijack_speed_override = 1
	murderbone_flag = TRUE

/datum/objective/hijack/check_completion() // Requires all owners to escape.
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.is_hijacked() || ..()
