//The opposite of killing a dude.
/datum/objective/protect
	name = "protect"
	var/target_role_type = FALSE
	var/human_check = TRUE

/datum/objective/protect/check_completion()
	var/obj/item/organ/brain/brain_target
	if(human_check)
		brain_target = target?.current.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(..() || !target)
		return TRUE
	if(considered_alive(target, enforce_human = human_check))
		return TRUE
	//Protect will always succeed when someone suicides
	return (human_check && brain_target) ? brain_target.suicided : FALSE


/datum/objective/protect/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/protect/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/protect/get_tracking_target(atom/source)
	return target?.current

/datum/objective/protect/nonhuman
	name = "protect nonhuman"
	human_check = FALSE
