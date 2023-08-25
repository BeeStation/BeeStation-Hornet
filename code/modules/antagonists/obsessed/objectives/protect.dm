/datum/objective/protect/obsessed //just a creepy version of protect

/datum/objective/protect/obsessed/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from anyone and anything."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] obsessed objectives forged without an obsession!")
		explanation_text = "Free Objective"

/datum/objective/protect/obsessed/on_target_cryo()
	qdel(src) //trauma will give replacement objectives
