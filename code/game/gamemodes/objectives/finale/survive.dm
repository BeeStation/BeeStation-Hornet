/datum/objective/survive
	name = "survive"
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M))
			return ..()
	return TRUE

/datum/objective/survive/malf
	name = "survive AI"
	explanation_text = "Prevent your own deactivation"

/datum/objective/survive/malf/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/mindobj in owners)
		if(!iscyborg(mindobj) && !considered_alive(mindobj, FALSE)) //Shells (and normal borgs for that matter) are considered alive for Malf
			return FALSE
		return TRUE
