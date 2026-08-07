#define SCREENTIP_VARIABLE_UNSET 99999

/datum/screentip_context
	var/mob/user
	var/obj/item/held_item
	var/access_context
	var/generic_context
	// Left context
	/// Used for the default left click action
	var/left_mouse_context
	/// Used for the left click with an empty hand action, overwrites left_mouse_context if the user has an empty hand
	var/left_attack_hand_context
	/// Used for the action to be shown if the user presses ctrl-left
	var/ctrl_left_mouse_context
	/// Used for the action to be shown if the user presses shift-left
	var/shift_left_mouse_context
	/// Used for the action to be shown if the user presses alt-left
	var/alt_left_mouse_context
	/// Used for the action to be shown if the user presses ctrl-shift-left
	var/ctrl_shift_left_mouse_context
	// Right contexts
	/// Used for the default right click action
	var/right_mouse_context
	/// Used for the right click with an empty hand action, overwrites right_mouse_context if the user has an empty hand
	var/right_attack_hand_context
	/// Used for the action to be shown if the user presses ctrl-right
	var/ctrl_right_mouse_context
	/// Used for the action to be shown if the user presses shift-right
	var/shift_right_mouse_context
	/// Used for the action to be shown if the user presses alt-right
	var/alt_right_mouse_context
	/// Used for the action to be shown if the user presses ctrl-shift-right
	var/ctrl_shift_right_mouse_context
	// Tool contexts
	/// Tooltip shown which represents an action performed by using wirecutters on the target
	var/wirecutter
	/// Tooltip shown which represents an action performed by using a screwdriver on the target
	var/screwdriver
	/// Tooltip shown which represents an action performed by using a wrench on the target
	var/wrench
	/// Tooltip shown which represents an action performed by using a welder on the target
	var/welder
	/// Tooltip shown which represents an action performed by using a crowbar on the target
	var/crowbar
	/// Tooltip shown which represents an action performed by using a multitool on the target
	var/multitool
	/// Tooltip shown which represents an action performed by using a knife on the target
	var/knife
	/// Tooltip shown which represents an action performed by using a rolling pin on the target
	var/rolling_pin
	// Other stuff
	/// True if the context does not depend on any external state.
	/// Once the cache is generated, it will never be recalculated for all
	/// objects of the specified type.
	/// Cache takes into account the type of the mob looking at the item,
	/// so can be used alongside accept_mob_type.
	var/cache_enabled = FALSE
	/// If accept_mob_type is set, then this indicates the type of mob that
	/// fit the conditions. This is used for calculating the appropriate cache
	/// of the screentip
	var/relevant_type = null
	/// Some procs inherently don't work with caching, so we force disallow caching
	/// if one of these is used. This is not an error on the external coder's part
	/// because we provide the assumption that using context without external state
	/// should simply work with caching.
	var/cache_force_disabled = FALSE

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
		access_context += "<br><span style='color:[SCREEN_TIP_ALLOWED]'>[context_text]</span>"
	else
		access_context += "<br><span style='color:[SCREEN_TIP_REJECTED]'>[context_text]</span>"

// ================================
// Left Click Actions
// ================================

/datum/screentip_context/proc/add_left_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.lmb_icon] [action_text]</span>"
	else
		left_mouse_context = "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_left_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.lmb_icon] [action_text]</span>"

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
			left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.lmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_alt_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		alt_left_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>alt-[GLOB.lmb_icon] [action_text]</span>"
	else
		alt_left_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>alt-[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_alt_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		alt_left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>alt-[GLOB.lmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_ctrl_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		ctrl_left_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-[GLOB.lmb_icon] [action_text]</span>"
	else
		ctrl_left_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>ctrl-[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_ctrl_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-[GLOB.lmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_shift_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		shift_left_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>shift-[GLOB.lmb_icon] [action_text]</span>"
	else
		shift_left_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>shift-[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_shift_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		shift_left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>shift-[GLOB.lmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_ctrl_shift_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		ctrl_shift_left_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-shift-[GLOB.lmb_icon] [action_text]</span>"
	else
		ctrl_shift_left_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>ctrl-shift-[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_ctrl_shift_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the left mouse action to only show this (we aren't using our hands anymore)
		ctrl_shift_left_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-shift-[GLOB.lmb_icon] [action_text]</span>"

// ================================
// Right Click Actions
// ================================

/datum/screentip_context/proc/add_right_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		right_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.rmb_icon] [action_text]</span>"
	else
		right_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>[GLOB.rmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_right_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		right_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.rmb_icon] [action_text]</span>"

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
			right_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.rmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_alt_right_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		alt_right_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>alt-[GLOB.rmb_icon] [action_text]</span>"
	else
		alt_right_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>alt-[GLOB.rmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_alt_right_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		alt_right_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>alt-[GLOB.rmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_ctrl_right_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		ctrl_right_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-[GLOB.rmb_icon] [action_text]</span>"
	else
		ctrl_right_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>ctrl-[GLOB.rmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_ctrl_right_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		ctrl_right_mouse_context = MAPTEXT("<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-[GLOB.rmb_icon] [action_text]</span>")

/datum/screentip_context/proc/add_shift_right_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		shift_right_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>shift-[GLOB.rmb_icon] [action_text]</span>"
	else
		shift_right_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>shift-[GLOB.rmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_shift_right_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		shift_right_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>shift-[GLOB.rmb_icon] [action_text]</span>"

/datum/screentip_context/proc/add_ctrl_shift_right_click_action(action_text, blocked_message = null, accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accessible)
		ctrl_shift_right_mouse_context += "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-shift-[GLOB.rmb_icon] [action_text]</span>"
	else
		ctrl_shift_right_mouse_context += "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>ctrl-shift-[GLOB.rmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_ctrl_shift_right_click_item_action(action_text, item_required)
	cache_force_disabled = TRUE
	if (istype(held_item, item_required))
		// Reset the right mouse action to only show this (we aren't using our hands anymore)
		ctrl_shift_right_mouse_context = "<span style='color:[SCREEN_TIP_NORMAL]'>ctrl-shift-[GLOB.rmb_icon] [action_text]</span>"

// ================================
// Generic Actions
// ================================

/datum/screentip_context/proc/add_attack_self_action(action_text)
	generic_context += "<br><span style='color:[SCREEN_TIP_NORMAL]'>\[Z\] [action_text]</span>"

/datum/screentip_context/proc/add_attack_hand_action(action_text, blocked_message = "hands full", accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accept_mob_type(/mob/living/carbon/human))
		if (accessible)
			left_attack_hand_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.lmb_icon] [action_text]</span>"
		else
			left_attack_hand_context = "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"

/datum/screentip_context/proc/add_attack_hand_secondary_action(action_text, blocked_message = "hands full", accessible = SCREENTIP_VARIABLE_UNSET)
	if (accessible != SCREENTIP_VARIABLE_UNSET)
		cache_force_disabled = TRUE
	if (accept_mob_type(/mob/living/carbon/human))
		if (accessible)
			right_attack_hand_context = "<span style='color:[SCREEN_TIP_NORMAL]'>[GLOB.lmb_icon] [action_text]</span>"
		else
			right_attack_hand_context+= "<span style='color:[SCREEN_TIP_INACCESSIBLE]'>[GLOB.lmb_icon] [action_text] ([blocked_message])</span>"


/datum/screentip_context/proc/add_generic_deconstruction_actions(obj/machinery/machine)
	cache_force_disabled = TRUE
	if (!machine.panel_open)
		add_left_click_tool_action("Open Panel", TOOL_SCREWDRIVER)
	else
		add_left_click_tool_action("Deconstruct", TOOL_CROWBAR)

/datum/screentip_context/proc/add_generic_unfasten_actions(obj/machinery/machine, need_panel_open = FALSE)
	cache_force_disabled = TRUE
	if ((machine.panel_open || !need_panel_open) & machine.anchored)
		add_left_click_tool_action("Unfasten", TOOL_WRENCH)

#undef SCREENTIP_VARIABLE_UNSET
