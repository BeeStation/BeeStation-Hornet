/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	. = ..()
	if(!. || !button) // no button available
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	if(master == carbon_owner.internal)
		button.icon_state = "template_active"
