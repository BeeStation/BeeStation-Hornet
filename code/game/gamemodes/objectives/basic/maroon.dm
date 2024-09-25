/datum/objective/maroon
	name = "maroon"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/maroon/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/maroon/check_completion()
	return ..() || !target || !considered_alive(target) || (!target.current.onCentCom() && !target.current.onSyndieBase())

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
