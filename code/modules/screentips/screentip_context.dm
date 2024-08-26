/datum/screentip_context
	var/mob/user
	var/context_message

/datum/screentip_context/proc/add_context(context_text)

/datum/screentip_context/proc/add_access_context(context_text, has_access = FALSE)
	if (has_access)
		context_message += "\n<font color='green'>[MAPTEXT(context_text)]</font>"
	else
		context_message += "\n<font color='red'>[MAPTEXT(context_text)]</font>"

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		context_message += "\n[MAPTEXT(action_text)]"
	else
		context_message += "\n<font color='grey'>[MAPTEXT("[action_text] ([blocked_message])")]</font>"

/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required)
	context_message += "\n[MAPTEXT(action_text)]"

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
