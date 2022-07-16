/datum/objective/assassinate
	name = "assasinate"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/assassinate/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/assassinate/check_completion()
	return ..() || (!considered_alive(target) || considered_afk(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/assassinate/incursion
	name = "eliminate"

/datum/objective/assassinate/incursion/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "[target.name], the [!target_role_type ? target.assigned_role : target.special_role] has been declared an ex-communicate of the syndicate. Eliminate them."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/internal
	var/stolen = 0 		//Have we already eliminated this target?

/datum/objective/assassinate/internal/update_explanation_text()
	..()
	if(target && !target.current)
		explanation_text = "Assassinate [target.name], who was obliterated"
