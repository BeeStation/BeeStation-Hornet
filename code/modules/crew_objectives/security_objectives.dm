/*				SECURITY OBJECTIVES				*/

/datum/objective/crew/enjoyyourstay
	jobs = list(
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_DETECTIVE,
		JOB_NAME_WARDEN,
		JOB_NAME_SECURITYOFFICER,
	)
	var/list/edglines = list(
		"Welcome aboard. Enjoy your stay.",
		"You signed up for this.",
		"Abandon hope.",
		"The tide's gonna stop eventually.",
		"Hey, someone's gotta do it.",
		"No, you can't resign.",
		"Security is a mission, not an intermission."
	)

/datum/objective/crew/enjoyyourstay/New()
	. = ..()
	update_explanation_text()

/datum/objective/crew/enjoyyourstay/update_explanation_text()
	. = ..()
	explanation_text = "Enforce Space Law to the best of your ability, and survive. [pick(edglines)]"

/datum/objective/crew/enjoyyourstay/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	return owner.current.stat != DEAD

/datum/objective/crew/nomanleftbehind
	explanation_text = "Ensure no prisoners are left in the brig when the shift ends."
	jobs = list(
		JOB_NAME_WARDEN,
		JOB_NAME_SECURITYOFFICER,
	)

/datum/objective/crew/nomanleftbehind/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	for(var/datum/mind/M in SSticker.minds)
		if(!istype(M.current) || (M.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
			continue
		if(istype(get_area(M.current), /area/security/prison))
			return FALSE
	return TRUE

/datum/objective/crew/justicemed
	explanation_text = "Ensure there are no dead bodies in the security wing when the shift ends."
	jobs = JOB_NAME_BRIGPHYSICIAN

/datum/objective/crew/justicemed/check_completion()
	if(..())
		return TRUE
	var/list/security_areas = typecacheof(list(
		/area/security,
		/area/security/brig,
		/area/security/main,
		/area/security/prison,
		/area/security/processing,
	))
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && is_type_in_typecache(A, security_areas)) // If person is dead and corpse is in one of these areas
			return FALSE
	return TRUE
