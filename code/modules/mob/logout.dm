/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	unset_machine()
	remove_from_player_list()
	..()

	if(loc)
		loc.on_log(FALSE)

	for (var/datum/component/comp in GetComponents(/datum/component/moved_relay))
		qdel(comp)

	// Unset the click abilities when logging out
	if(istype(click_intercept, /datum/action/cooldown))
		var/datum/action/cooldown/click_action = click_intercept
		click_action.unset_click_ability(src, refund_cooldown = TRUE)
	else if(istype(click_intercept, /datum/action/innate))
		var/datum/action/innate/click_action = click_intercept
		click_action.unset_ranged_ability(src)

	become_uncliented()

	return TRUE
