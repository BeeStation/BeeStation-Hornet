/datum/objective/protect//The opposite of killing a dude.
	name = "protect"
	martyr_compatible = 1
	var/target_role_type = FALSE
	var/human_check = TRUE

/datum/objective/protect/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/protect/check_completion()
	var/obj/item/organ/brain/brain_target
	if(human_check)
		brain_target = target?.current.getorganslot(ORGAN_SLOT_BRAIN)
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

/datum/objective/protect/nonhuman
	name = "protect nonhuman"
	human_check = FALSE
