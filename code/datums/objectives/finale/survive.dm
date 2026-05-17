/datum/objective/survive
	name = "survive"
	explanation_text = "Stay alive until the end."
	admin_grantable = TRUE

/datum/objective/survive/check_completion()
	for(var/datum/mind/objective_owner as anything in get_owners())
		if(!considered_alive(objective_owner))
			return ..()
	return TRUE

/datum/objective/survive/malf
	name = "survive AI"
	explanation_text = "Prevent your own deactivation"

/datum/objective/survive/malf/check_completion()
	for(var/datum/mind/objective_owner as anything in get_owners())
		if(!iscyborg(objective_owner) && !considered_alive(objective_owner, FALSE)) //Shells (and normal borgs for that matter) are considered alive for Malf
			return ..()
		return TRUE
