/datum/objective/assassinate/jealous //assassinate, but it changes the target to someone else in the obsession's department. cool, right?
	var/datum/mind/obsession //the target the coworker is picked from.

/datum/objective/assassinate/jealous/update_explanation_text()
	..()
	if(obsession && target?.current)
		explanation_text = "Murder [target.name], [obsession]'s coworker."
	else if(target?.current)
		explanation_text = "Murder [target.name]."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/jealous/find_target(list/dupe_search_range, list/blacklist)//returning null = free objective
	if(!obsession?.assigned_role)
		set_target(null)
		update_explanation_text()
		return
	var/list/viable_coworkers = list()
	var/list/all_coworkers = list()
	var/list/chosen_department
	//note that command and sillycone are gone because borgs can't be obsessions and the heads have their respective department. Sorry cap, your place is more with centcom or something
	if(obsession.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)
	else if(obsession.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING)
	else if(obsession.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL)
	else if(obsession.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE)
	else if(obsession.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO)
	else if(obsession.assigned_role in (SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN)))
		chosen_department = SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN)
	else
		set_target(null)
		update_explanation_text()
		return
	for(var/datum/mind/possible_target as() in get_crewmember_minds())
		if(!SSjob.GetJob(possible_target.assigned_role) || possible_target == obsession || possible_target.has_antag_datum(/datum/antagonist/obsessed) || (possible_target in blacklist))
			continue //the jealousy target has to have a job, and not be the obsession or obsessed.
		all_coworkers += possible_target
		if(possible_target.assigned_role in chosen_department)
			viable_coworkers += possible_target

	if(length(viable_coworkers))//find someone in the same department
		set_target(pick(viable_coworkers))
	else if(length(all_coworkers))//find someone who works on the station
		set_target(pick(all_coworkers))
	else
		set_target(null)
	update_explanation_text()
	return target
