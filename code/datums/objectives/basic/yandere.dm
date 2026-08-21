//The opposite of killing a dude.
/datum/objective/yandere
	name = "yandere"
	admin_grantable = TRUE

	var/target_special_role = FALSE
	var/human_check = TRUE

/datum/objective/yandere/check_completion()
	var/obj/item/organ/brain/brain_target
	if(human_check)
		brain_target = target?.current.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(..() || !target)
		return TRUE
	if(considered_alive(target, enforce_human = human_check))
		return TRUE
	//yandere will always succeed when someone suicides
	return ((human_check && brain_target) ? brain_target.suicided : FALSE) && (!target.current.onCentCom() && !target.current.onSyndieBase())

/datum/objective/yandere/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Protect and ensure sure they stay marooned on station so they are yours forever[target.name], the [!target_special_role ? target.assigned_role.title : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/yandere/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/yandere/get_tracking_target(atom/source)
	return target?.current

/datum/objective/yandere/nonhuman
	name = "protect nonhuman"
	human_check = FALSE
