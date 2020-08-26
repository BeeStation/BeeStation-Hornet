GLOBAL_DATUM_INIT(staff_state, /datum/ui_state/staff_state, new)

/datum/ui_state/staff_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, 0)) //Do they have a holder at all?
		return UI_INTERACTIVE
	return UI_CLOSE
