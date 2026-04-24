/**
 * tgui state: pre_auth_state
 *
 * Checks that the user is not logged in
 */

GLOBAL_DATUM_INIT(pre_auth_state, /datum/ui_state/pre_auth_state, new)

/datum/ui_state/pre_auth_state/can_use_topic(src_object, mob/user)
	if(user.client && !user.client.logged_in && istype(user, /mob/dead/new_player/pre_auth))
		return UI_INTERACTIVE
	return UI_CLOSE

