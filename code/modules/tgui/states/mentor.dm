/**
 * tgui state: mentor_state
 *
 * Checks that the user is a mentor.
 */

GLOBAL_DATUM_INIT(mentor_state, /datum/ui_state/mentor_state, new)

/datum/ui_state/mentor_state/can_use_topic(src_object, mob/user)
	if(GLOB.mentor_datums[user.ckey])
		return UI_INTERACTIVE
	return UI_CLOSE
