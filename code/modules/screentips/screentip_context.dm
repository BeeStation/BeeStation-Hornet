#define SCREEN_TIP_ALLOWED "#a9f59d"
#define SCREEN_TIP_REJECTED "#e39191"
#define SCREEN_TIP_NORMAL "#daf3f2"
#define SCREEN_TIP_INACCESSIBLE "#a1b6b5"

/datum/screentip_context
	var/mob/user
	var/access_context
	var/left_mouse_context

/datum/screentip_context/proc/add_context(context_text)

/datum/screentip_context/proc/add_access_context(context_text, has_access = FALSE)
	if (has_access)
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_ALLOWED]'>[CENTER(context_text)]</span>")]"
	else
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_REJECTED]'>[CENTER(context_text)]")]</span>"

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("LMB: [action_text]")]</span>")]"
	else
		left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("LMB: [action_text] ([blocked_message])")]</span>")]"

/// Add a left-click action that requires an item to be held
/// Will overwrite any default hand left-click interactions
/// If shift is held, then the interaction will be shown unless secret is set, otherwise
/// the player must be holding the item to see this tip.
/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required, secret = FALSE)
	var/atom/path = item_required
	if (user.client?.keys_held["Shift"] && !secret)
		left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("LMB: [initial(path.name)]: [action_text]")]</span>")]"
	if (istype(user.get_active_held_item(), item_required) || istype(user.get_inactive_held_item(), item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("LMB: [initial(path.name)]: [action_text]")]</span>")]"

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
