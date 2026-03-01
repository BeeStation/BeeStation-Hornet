GLOBAL_DATUM_INIT(clockcult_held_state, /datum/ui_state/clockcult_held_state, new)

/datum/ui_state/clockcult_held_state/can_use_topic(src_object, mob/user)
	// Requires clockcultist
	if(!IS_SERVANT_OF_RATVAR(user))
		return UI_CLOSE
	// Hands state
	. = user.shared_ui_interaction(src_object)
	if(. >= UI_CLOSE)
		return min(., user.hands_can_use_topic(src_object))
