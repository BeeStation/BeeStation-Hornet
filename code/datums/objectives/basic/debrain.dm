/datum/objective/debrain
	name = "debrain"
	admin_grantable = TRUE

	var/target_special_role = FALSE

/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return TRUE
	if(!target.current || !isbrain(target.current))
		return ..()
	var/atom/A = target.current

	while(A.loc) // Check to see if the brainmob is on our person
		A = A.loc
		for(var/datum/mind/M as() in get_owners())
			if(M.current && M.current.stat != DEAD && A == M.current)
				return TRUE
	return ..()

/datum/objective/debrain/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.name], the [!target_special_role ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/debrain/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/debrain/get_tracking_target(atom/source)
	return target?.current
