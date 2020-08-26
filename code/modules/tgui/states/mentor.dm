GLOBAL_DATUM_INIT(mentor_state, /datum/ui_state/mentor_state, new)

/datum/ui_state/mentor_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_MENTOR))
		return UI_INTERACTIVE
	return UI_CLOSE
