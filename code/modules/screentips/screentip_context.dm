#define IMAGE_FOR_PATH(typepath) "<span class='small-icon'><img class=icon src=\ref[initial(typepath.icon)] iconstate='[initial(typepath.icon_state)]'></span>"

/datum/screentip_context
	var/mob/user
	var/obj/item/held_item
	var/relevant = FALSE
	var/access_context
	var/left_mouse_context
	var/tool_icon_context
	var/ctrl_left_mouse_context
	var/shift_left_mouse_context
	var/alt_left_mouse_context
	var/ctrl_shift_left_mouse_context

/// Indicates that this screentip does not depend on any external state, and only state provided
/// by this context object itself.
/datum/screentip_context/proc/use_cache()

/// Used in if statements to determine if the mob examining this object is of a certain type
/// as certain mobs may have specific interactions with things
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_mob_type(mob_type)
	if (istype(user, mob_type))
		relevant = TRUE
		return TRUE
	return FALSE

/// Used in if statements to determine if the mob examining this object is a silicon
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_silicons()
	if (issilicon(user))
		relevant = TRUE
		return TRUE
	return FALSE

/// Used in if statements to determine if the mob examining this object is an animal
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_animals()
	if (isanimal(user))
		relevant = TRUE
		return TRUE
	return FALSE

/datum/screentip_context/proc/add_context(context_text)

/datum/screentip_context/proc/add_access_context(context_text, has_access = FALSE)
	if (has_access)
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_ALLOWED]'>[CENTER(context_text)]</span>")]"
	else
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_REJECTED]'>[CENTER(context_text)]")]</span>"

/datum/screentip_context/proc/add_attack_hand_action(action_text, blocked_message = null, accessible = TRUE)
	if (ishuman(user) && held_item == null)
		if (accessible)
			left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"
		else
			left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_left_click_tool_action(action_text, tool)
	if (held_item?.tool_behaviour == tool)
		switch (tool)
			if (TOOL_WIRECUTTER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_wirecutters][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_SCREWDRIVER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_screwdriver][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_WRENCH)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_wrench][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_WELDER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_welder][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_CROWBAR)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_crowbar][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_MULTITOOL)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_multitool][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_KNIFE)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_knife][GLOB.lmb_icon][action_text]")]</span>")]"
			if (TOOL_ROLLINGPIN)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_rolling_pin][GLOB.lmb_icon][action_text]")]</span>")]"
			else
				left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon][action_text]")]</span>")]"
	else
		switch (tool)
			if (TOOL_WIRECUTTER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_wirecutters] [action_text]")]</span>")]"
			if (TOOL_SCREWDRIVER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_screwdriver] [action_text]")]</span>")]"
			if (TOOL_WRENCH)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_wrench] [action_text]")]</span>")]"
			if (TOOL_WELDER)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_welder] [action_text]")]</span>")]"
			if (TOOL_CROWBAR)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_crowbar] [action_text]")]</span>")]"
			if (TOOL_MULTITOOL)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_multitool] [action_text]")]</span>")]"
			if (TOOL_KNIFE)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_knife] [action_text]")]</span>")]"
			if (TOOL_ROLLINGPIN)
				tool_icon_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.hint_rolling_pin] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_generic_deconstruction_actions(obj/machinery/machine)
	if (!machine.panel_open)
		add_left_click_tool_action("Open Panel", TOOL_SCREWDRIVER)
	else
		add_left_click_tool_action("Deconstruct", TOOL_CROWBAR)

/datum/screentip_context/proc/add_generic_unfasten_actions(obj/machinery/machine, need_panel_open = FALSE)
	if (machine.panel_open || !need_panel_open)
		add_left_click_tool_action("Unfasten", TOOL_WRENCH)

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = TRUE)

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		alt_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		alt_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		alt_left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		ctrl_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("alt-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		shift_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		shift_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("shift-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		shift_left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_shift_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		ctrl_shift_left_mouse_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_shift_left_mouse_context = "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text]")]</span>")]"
