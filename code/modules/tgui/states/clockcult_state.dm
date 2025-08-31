GLOBAL_DATUM_INIT(clockcult_state, /datum/ui_state/clockcult_state, new)

/datum/ui_state/clockcult_state/can_use_topic(src_object, mob/user)
	if(IS_SERVANT_OF_RATVAR(user))
		return UI_INTERACTIVE
	return UI_CLOSE
