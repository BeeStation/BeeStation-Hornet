//End Changeling Objectives

/datum/objective/destroy
	name = "destroy AI"

/datum/objective/destroy/find_target(list/dupe_search_range, list/blacklist)
	var/list/possible_targets = list()
	for(var/mob/living/silicon/ai/A as() in active_ais(TRUE))
		if(A.mind in blacklist)
			continue
		possible_targets += A
	if(possible_targets.len)
		var/mob/living/silicon/ai/target_ai = pick(possible_targets)
		set_target(target_ai.mind)
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/destroy/check_completion()
	if(target && target.current)
		return target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey || ..()//Borgs/brains/AIs count as dead for traitor objectives.
	return TRUE

/datum/objective/destroy/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free Objective"

/datum/objective/destroy/admin_edit(mob/admin)
	var/list/possible_targets = active_ais(1)
	if(possible_targets.len)
		var/mob/new_target = input(admin,"Select target:", "Objective target") as null|anything in sort_names(possible_targets)
		set_target(new_target.mind)
	else
		to_chat(admin, "No active AIs with minds")
	update_explanation_text()

/datum/objective/destroy/get_tracking_target(atom/source)
	return target?.current

/datum/objective/destroy/internal
	var/stolen = FALSE 		//Have we already eliminated this target?
