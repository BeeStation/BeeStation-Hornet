/**
 * tgui state: admin_state
 *
 * Checks that the user is an admin, end-of-story.
 */

GLOBAL_DATUM_INIT(admin_state, /datum/ui_state/admin_state, new)

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE

/**
 * tgui state: VV_state
 *
 * If the user is an admin, allows interaction.
 * If not (an admin let them *see* the panel), no touchies, only seesies. or something.
 */

GLOBAL_DATUM_INIT(VV_state, /datum/ui_state/VV_state, new)

/datum/ui_state/VV_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_UPDATE
