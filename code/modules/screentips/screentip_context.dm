#define SCREEN_TIP_ALLOWED "#a9f59d"
#define SCREEN_TIP_REJECTED "#e39191"
#define SCREEN_TIP_NORMAL "#daf3f2"
#define SCREEN_TIP_INACCESSIBLE "#a1b6b5"

/datum/screentip_context
	var/mob/user
	var/context_message

/datum/screentip_context/proc/add_context(context_text)

/datum/screentip_context/proc/add_access_context(context_text, has_access = FALSE)
	if (has_access)
		context_message += "\n[MAPTEXT("<span style='line-height: 0.5; color:[SCREEN_TIP_ALLOWED]'>[CENTER(context_text)]</span>")]"
	else
		context_message += "\n[MAPTEXT("<span style='line-height: 0.5; color:[SCREEN_TIP_REJECTED]'>[CENTER(context_text)]")]</span>"

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		context_message += "\n[MAPTEXT("<span style='line-height: 0.5; color:[SCREEN_TIP_NORMAL]'>[CENTER(action_text)]</span>")]"
	else
		context_message += "\n[MAPTEXT("<span style='line-height: 0.5; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER(action_text)] ([blocked_message])</span>")]"

/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required)
	context_message += "\n[MAPTEXT("<span style='line-height: 0.5; color:[SCREEN_TIP_NORMAL]'>[CENTER(action_text)]</span>")]"

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
