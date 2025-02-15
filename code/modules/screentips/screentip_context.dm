/datum/screentip_context
	var/mob/user
	var/obj/item/held_item
	var/access_context
	var/generic_context
	// Left context
	var/left_mouse_context
	var/left_tool_icon_context
	var/ctrl_left_mouse_context
	var/shift_left_mouse_context
	var/alt_left_mouse_context
	var/ctrl_shift_left_mouse_context
	// Right contexts
	var/right_mouse_context
	var/right_tool_icon_context
	var/ctrl_right_mouse_context
	var/shift_right_mouse_context
	var/alt_right_mouse_context
	var/ctrl_shift_right_mouse_context
	// Tool contexts
	var/wirecutter
	var/screwdriver
	var/wrench
	var/welder
	var/crowbar
	var/multitool
	var/knife
	var/rolling_pin
	// Other stuff
	var/cache_enabled = FALSE
	var/relevant_type = null

// ================================
// Caching
// ================================

/// Indicates that this screentip does not depend on any external state, and only state provided
/// by this context object itself.
/datum/screentip_context/proc/use_cache()
	cache_enabled = TRUE

/// Used in if statements to determine if the mob examining this object is of a certain type
/// as certain mobs may have specific interactions with things
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_mob_type(mob_type)
	if (istype(user, mob_type))
		relevant_type = mob_type
		return TRUE
	return FALSE

/// Used in if statements to determine if the mob examining this object is a silicon
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_silicons()
	if (issilicon(user))
		relevant_type = /mob/living/silicon
		return TRUE
	return FALSE

/// Used in if statements to determine if the mob examining this object is an animal
/// Uses this proc to inform the cache and mark that the screentip for this mob is successfully handled.
/datum/screentip_context/proc/accept_animals()
	if (isanimal(user))
		relevant_type = /mob/living/simple_animal
		return TRUE
	return FALSE

// ================================
// Non-Input Contexts
// ================================

/datum/screentip_context/proc/add_access_context(context_text, has_access = FALSE)
	if (has_access)
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_ALLOWED]'>[CENTER(context_text)]</span>")]"
	else
		access_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_REJECTED]'>[CENTER(context_text)]")]</span>"

// ================================
// Left Click Actions
// ================================

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_left_click_tool_action(action_text, tool)
	switch (tool)
		if (TOOL_WIRECUTTER)
			wirecutter = "[GLOB.lmb_icon] [action_text] [wirecutter]"
		if (TOOL_SCREWDRIVER)
			screwdriver = "[GLOB.lmb_icon] [action_text] [screwdriver]"
		if (TOOL_WRENCH)
			wrench = "[GLOB.lmb_icon] [action_text] [wrench]"
		if (TOOL_WELDER)
			welder = "[GLOB.lmb_icon] [action_text] [welder]"
		if (TOOL_CROWBAR)
			crowbar = "[GLOB.lmb_icon] [action_text] [crowbar]"
		if (TOOL_MULTITOOL)
			multitool = "[GLOB.lmb_icon] [action_text] [multitool]"
		if (TOOL_KNIFE)
			knife = "[GLOB.lmb_icon] [action_text] [knife]"
		if (TOOL_ROLLINGPIN)
			rolling_pin = "[GLOB.lmb_icon] [action_text] [rolling_pin]"
		else
			left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		alt_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		alt_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("alt-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		alt_left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		ctrl_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		shift_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		shift_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("shift-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		shift_left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.lmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_shift_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text]")]</span>")]"
	else
		ctrl_shift_left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_shift_left_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.lmb_icon] [action_text]")]</span>")]"

// ================================
// Right Click Actions
// ================================

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.rmb_icon] [action_text]")]</span>")]"
	else
		right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.rmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.rmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_right_click_tool_action(action_text, tool)
	switch (tool)
		if (TOOL_WIRECUTTER)
			wirecutter = "[wirecutter] [GLOB.rmb_icon] [action_text]"
		if (TOOL_SCREWDRIVER)
			screwdriver = "[screwdriver] [GLOB.rmb_icon] [action_text]"
		if (TOOL_WRENCH)
			wrench = "[wrench] [GLOB.rmb_icon] [action_text]"
		if (TOOL_WELDER)
			welder = "[welder] [GLOB.rmb_icon] [action_text]"
		if (TOOL_CROWBAR)
			crowbar = "[crowbar] [GLOB.rmb_icon] [action_text]"
		if (TOOL_MULTITOOL)
			multitool = "[multitool] [GLOB.rmb_icon] [action_text]"
		if (TOOL_KNIFE)
			knife = "[knife] [GLOB.rmb_icon] [action_text]"
		if (TOOL_ROLLINGPIN)
			rolling_pin = "[rolling_pin] [GLOB.rmb_icon] [action_text]"
		else
			right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.rmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_alt_right_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		alt_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.rmb_icon] [action_text]")]</span>")]"
	else
		alt_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("alt-[GLOB.rmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_alt_right_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		alt_right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("alt-[GLOB.rmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_right_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.rmb_icon] [action_text]")]</span>")]"
	else
		ctrl_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-[GLOB.rmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_right_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		ctrl_right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-[GLOB.rmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_shift_right_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		shift_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.rmb_icon] [action_text]")]</span>")]"
	else
		shift_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("shift-[GLOB.rmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_shift_right_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		shift_right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("shift-[GLOB.rmb_icon] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_right_click_action(action_text, blocked_message = null, accessible = TRUE)
	if (accessible)
		ctrl_shift_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.rmb_icon] [action_text]")]</span>")]"
	else
		ctrl_shift_right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("ctrl-shift-[GLOB.rmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_ctrl_shift_right_click_item_action(action_text, item_required)
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		ctrl_shift_right_mouse_context = "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("ctrl-shift-[GLOB.rmb_icon] [action_text]")]</span>")]"

// ================================
// Generic Actions
// ================================

/datum/screentip_context/proc/add_attack_self_action(action_text)
	generic_context += "\n[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("\[Z\] [action_text]")]</span>")]"

/datum/screentip_context/proc/add_attack_hand_action(action_text, blocked_message = "hands full", accessible = TRUE)
	if (ishuman(user) && held_item == null)
		if (accessible)
			left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"
		else
			left_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"

/datum/screentip_context/proc/add_attack_hand_secondary_action(action_text, blocked_message = "hands full", accessible = TRUE)
	if (ishuman(user) && held_item == null)
		if (accessible)
			right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_NORMAL]'>[CENTER("[GLOB.lmb_icon] [action_text]")]</span>")]"
		else
			right_mouse_context += "[MAPTEXT("<span style='line-height: 0.35; color:[SCREEN_TIP_INACCESSIBLE]'>[CENTER("[GLOB.lmb_icon] [action_text] ([blocked_message])")]</span>")]"


/datum/screentip_context/proc/add_generic_deconstruction_actions(obj/machinery/machine)
	if (!machine.panel_open)
		add_left_click_tool_action("Open Panel", TOOL_SCREWDRIVER)
	else
		add_left_click_tool_action("Deconstruct", TOOL_CROWBAR)

/datum/screentip_context/proc/add_generic_unfasten_actions(obj/machinery/machine, need_panel_open = FALSE)
	if (machine.panel_open || !need_panel_open)
		add_left_click_tool_action("Unfasten", TOOL_WRENCH)
