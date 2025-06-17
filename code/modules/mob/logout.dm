/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	log_message("[key_name(src)] is no longer owning mob [src]([src.type])", LOG_OWNERSHIP)
	SStgui.on_logout(src)
	unset_machine()
	remove_from_player_list()
	..()

	if(loc)
		loc.on_log(FALSE)

	if(client)
		for(var/foo in client.player_details.post_logout_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()

	for (var/datum/component/comp in GetComponents(/datum/component/moved_relay))
		qdel(comp)

	// Unset the click abilities when logging out
	for (var/datum/action/action in actions)
		if (click_intercept == action)
			action.unset_click_ability(src)

	clear_important_client_contents(client)
	return TRUE
