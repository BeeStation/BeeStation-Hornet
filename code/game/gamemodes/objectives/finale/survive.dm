/datum/objective/survive
	name = "survive"
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M))
			return ..()
	return TRUE

/datum/objective/survive/exist //Like survive, but works for silicons and zombies and such.
	name = "survive nonhuman"

/datum/objective/survive/exist/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, FALSE))
			return ..()
	return TRUE
