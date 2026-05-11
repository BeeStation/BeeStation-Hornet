/datum/objective/maroon
	name = "maroon"
	var/target_special_role=FALSE

/datum/objective/maroon/check_completion()
	return ..() || !target || !considered_alive(target) || (!target.current.onCentCom() && !target.current.onSyndieBase())

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_special_role ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/maroon/get_tracking_target(atom/source)
	return target?.current
