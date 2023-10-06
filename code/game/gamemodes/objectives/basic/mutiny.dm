/datum/objective/mutiny
	name = "mutiny"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/mutiny/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/mutiny/check_completion()
	if(!target || !considered_alive(target) || considered_afk(target))
		return TRUE
	var/turf/T = get_turf(target.current)
	return ..() || !T || !is_station_level(T.z)

/datum/objective/mutiny/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate or exile [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/mutiny/on_target_cryo()
	set_target(null)
	team.objectives -= src
	for(var/datum/mind/M as() in team.members)
		var/datum/antagonist/rev/R = M.has_antag_datum(/datum/antagonist/rev)
		if(R)
			R.objectives -= src
			to_chat(M.current, "<BR><span class='userdanger'>Your target is no longer within reach. Objective removed!</span>")
			M.announce_objectives()
	qdel(src)
