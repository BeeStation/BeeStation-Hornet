/**
 * tgui state: admin_holder_state
 *
 * Checks that the user has an admin datum.
 * Use admin_state to check for R_ADMIN.
 */

GLOBAL_DATUM_INIT(admin_holder_state, /datum/ui_state/admin_holder_state, new)

/datum/ui_state/admin_holder_state/can_use_topic(src_object, mob/user)
	if(user.client?.holder)
		return UI_INTERACTIVE
	return UI_CLOSE
