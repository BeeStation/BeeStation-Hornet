/datum/objective/martyr
	name = "martyr"
	explanation_text = "Die a glorious death."
	murderbone_flag = TRUE

/datum/objective/martyr/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(considered_alive(M))
			return ..()
		if(M.current?.suiciding) //killing yourself ISN'T glorious.
			return ..()
	return TRUE
