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
	if(is_unassigned_job(obsession.assigned_role))
		set_target(null)
		update_explanation_text()
		return
	var/list/viable_coworkers = list()
	var/list/all_coworkers = list()
	var/our_departments = obsession.assigned_role.departments
	for(var/mob/living/carbon/human/human_alive in GLOB.alive_mob_list)
		if(!human_alive.mind)
			continue
		if(human_alive == obsession.current || human_alive.mind.assigned_role.faction != FACTION_STATION || human_alive.mind.has_antag_datum(/datum/antagonist/obsessed))
			continue //the jealousy target has to have a job, and not be the obsession or obsessed.
		all_coworkers += human_alive.mind
		if(!(our_departments & human_alive.mind.assigned_role.departments))
			continue
		viable_coworkers += human_alive.mind
	if(length(viable_coworkers))//find someone in the same department
		target = pick(viable_coworkers)
	else if(length(all_coworkers))//find someone who works on the station
		target = pick(all_coworkers)
	return target
