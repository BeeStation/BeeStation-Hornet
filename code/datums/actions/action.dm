/**
 * # Action system
 *
 * A simple base for an modular behavior attached to atom or datum.
 */
/datum/action
	/// The name of the action
	var/name = "Generic Action"
	/// The description of what the action does
	var/desc
	/// The datum the action is attached to. If the master datum is deleted, the action is as well.
	/// Set in New() via the proc link_to().
	var/datum/master
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// This is who currently owns the action, and most often, this is who is using the action if it is triggered
	/// This can be the same as "target" but is not ALWAYS the same - this is set and unset with Grant() and Remove()
	var/mob/owner
	// =====================================
	// Action Behaviour
	// =====================================
	/// Flags that will determine of the owner / user of the action can... use the action
	var/check_flags = NONE
	/// Setting for intercepting clicks before activating the ability
	var/requires_target = FALSE
	/// If TRUE, we will unset after using our click intercept. Requires requires_target
	/// If false, then cooldown and action conclussion needs to be handled manually
	var/unset_after_click = TRUE
	/// The cooldown added onto the user's next click. Requires requires_target
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	// =====================================
	// Action Appearance
	// =====================================
	/// The style the button's tooltips appear to be
	var/buttontooltipstyle = ""
	/// Whether the button becomes transparent when it can't be used or just reddened
	var/transparent_when_unavailable = TRUE
	/// This is the file for the BACKGROUND icon of the button
	var/button_icon = 'icons/hud/actions/backgrounds.dmi'
	/// This is the icon state state for the BACKGROUND icon of the button
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	/// This is the file for the icon that appears OVER the button background
	var/icon_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for the icon that appears OVER the button background
	var/button_icon_state = "default"
	///List of all mobs that are viewing our action button -> A unique movable for them to view.
	var/list/viewers = list()
	/// What icon to replace our mouse cursor with when active. Optional, Requires requires_target
	var/ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	/// Whether or not you want the cooldown for the ability to display in text form
	var/show_cooldown = TRUE
	// =====================================
	// Cooldown
	// =====================================
	/// The actual next time this ability can be used
	var/next_use_time = 0
	/// The default cooldown applied when start_cooldown() is called
	/// Actions are responsible for setting their own cooldown.
	var/cooldown_time = 0
	/// Shares cooldowns with other cooldown abilities of the same value, not active if null
	/// This allows a single thing with cooldowns to have multiple actions which share the same cooldown
	var/cooldown_group

/datum/action/New(master)
	if (master)
		link_to(master)

/// Links the passed target to our action, registering any relevant signals
/datum/action/proc/link_to(master)
	src.master = master
	RegisterSignal(master, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	if(isatom(master))
		RegisterSignal(master, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_icon_on_signal))

	if(istype(master, /datum/mind))
		RegisterSignal(master, COMSIG_MIND_TRANSFERRED, PROC_REF(on_master_mind_swapped))

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	master = null
	QDEL_LIST_ASSOC_VAL(viewers) // Qdel the buttons in the viewers list **NOT THE HUDS**
	return ..()

/// Signal proc that clears any references based on the owner or target deleting
/// If the owner's deleted, we will simply remove from them, but if the target's deleted, we will self-delete
/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == master)
		qdel(src)

/// Grants the action to the passed mob, making it the owner
/datum/action/proc/Grant(mob/grant_to)
	if(!grant_to)
		Remove(owner)
		return
	if(owner)
		if(owner == grant_to)
			return
		Remove(owner)
	SEND_SIGNAL(src, COMSIG_ACTION_GRANTED, grant_to)
	owner = grant_to
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	// Register some signals based on our check_flags
	// so that our button icon updates when relevant
	if(check_flags & AB_CHECK_CONSCIOUS)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_icon_on_signal))
	if(check_flags & AB_CHECK_IMMOBILE)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(update_icon_on_signal))
	if(check_flags & AB_CHECK_HANDS_BLOCKED)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(update_icon_on_signal))
	if(check_flags & AB_CHECK_LYING)
		RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(update_icon_on_signal))

	GiveAction(grant_to)
	// Start cooldown timer if we gained it mid-cooldown
	if(!owner)
		return
	UpdateButtons()
	if(next_use_time > world.time)
		START_PROCESSING(SSfastprocess, src)

/// Remove the passed mob from being owner of our action
/datum/action/proc/Remove(mob/remove_from)
	SHOULD_CALL_PARENT(TRUE)

	for(var/datum/hud/hud in viewers)
		if(!hud.mymob)
			continue
		HideFrom(hud.mymob)
	LAZYREMOVE(remove_from.actions, src) // We aren't always properly inserted into the viewers list, gotta make sure that action's cleared
	viewers = list()

	if(owner)
		SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)

		// Clean up our check_flag signals
		UnregisterSignal(owner, list(
			COMSIG_LIVING_SET_BODY_POSITION,
			COMSIG_MOB_STATCHANGE,
			SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED),
			SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED),
		))

		if(master == owner)
			RegisterSignal(master, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref))
		owner = null

	if (remove_from.click_intercept == src)
		unset_click_ability(remove_from)

/// Actually triggers the effects of the action.
/// Called when the on-screen button is clicked, for example.
/datum/action/proc/Trigger()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	if(!owner)
		return FALSE

	var/mob/user = usr || owner

	// If our cooldown action is a requires_target action:
	// The actual action is activated on whatever the user clicks on -
	// the target is what the action is being used on
	// In trigger, we handle setting the click intercept
	if(requires_target)
		var/datum/action/cooldown/already_set = user.click_intercept
		if(already_set == src)
			// if we clicked ourself and we're already set, unset and return
			return unset_click_ability(user, refund_cooldown = TRUE)

		else if(istype(already_set))
			// if we have an active set already, unset it before we set our's
			already_set.unset_click_ability(user, refund_cooldown = TRUE)

		return set_click_ability(user)

	// If our cooldown action is not a requires_target action:
	// We can just continue on and use the action
	// the target is the user of the action (often, the owner)
	return PreActivate(user, null)

/// Adds the ability for signals to intercept the ability
/datum/action/proc/PreActivate(mob/user, atom/target)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src) & COMPONENT_BLOCK_ABILITY_START)
		return
	. = Activate(user, target)
	// There is a possibility our action (or owner) is qdeleted in Activate().
	if(!QDELETED(src) && !QDELETED(owner))
		SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_FINISHED, src)

/// Override to implement behaviour
/// If this action is not a targetted spell, target will be the user
/datum/action/proc/Activate(mob/user, atom/target)
	return

/// Intercepts client owner clicks to activate the ability
/datum/action/cooldown/proc/InterceptClickOn(mob/living/caller, params, atom/target)
	if(!IsAvailable())
		unset_click_ability(caller, refund_cooldown = FALSE)
		return FALSE
	if(!target)
		return FALSE
	// The actual action begins here
	if(!PreActivate(caller, target))
		return FALSE

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		start_cooldown()
		unset_click_ability(caller, refund_cooldown = FALSE)
	caller.next_click = world.time + click_cd_override

	return TRUE

/// Whether our action is currently available to use or not
/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if (next_use_time && world.time < next_use_time)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_user = owner
		if(action_user.body_position == LYING_DOWN)
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	return TRUE

/datum/action/proc/UpdateButtons(status_only, force)
	for(var/datum/hud/hud in viewers)
		var/atom/movable/screen/movable/button = viewers[hud]
		UpdateButton(button, status_only, force)

/datum/action/proc/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	if(!button)
		return
	if(!status_only)
		button.name = name
		button.desc = desc
		if(owner?.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
			var/list/settings = owner.hud_used.get_action_buttons_icons()
			if(button.icon != settings["bg_icon"])
				button.icon = settings["bg_icon"]
			if(button.icon_state != settings["bg_state"])
				button.icon_state = settings["bg_state"]
		else
			if(button.icon != button_icon)
				button.icon = button_icon
			if(button.icon_state != background_icon_state)
				button.icon_state = background_icon_state

		ApplyIcon(button, force)

	var/available = IsAvailable()
	if(available)
		button.color = rgb(255,255,255,255)
	else
		button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
	return available

/// Applies our button icon over top the background icon of the action
/datum/action/proc/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state

/// Gives our action to the passed viewer.
/// Puts our action in their actions list and shows them the button.
/datum/action/proc/GiveAction(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(viewers[our_hud]) // Already have a copy of us? go away
		return

	LAZYOR(viewer.actions, src) // Move this in
	ShowTo(viewer)

/// Adds our action button to the screen of the passed viewer.
/datum/action/proc/ShowTo(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(!our_hud || viewers[our_hud]) // There's no point in this if you have no hud in the first place
		return

	var/atom/movable/screen/movable/action_button/button = CreateButton()
	SetId(button, viewer)

	button.our_hud = our_hud
	viewers[our_hud] = button
	if(viewer.client)
		viewer.client.screen += button

	button.load_position(viewer)
	viewer.update_action_buttons()

/// Removes our action from the passed viewer.
/datum/action/proc/HideFrom(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	var/atom/movable/screen/movable/action_button/button = viewers[our_hud]
	LAZYREMOVE(viewer.actions, src)
	if(button)
		qdel(button)

/// Creates an action button movable for the passed mob, and returns it.
/datum/action/proc/CreateButton()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc
	return button

/datum/action/proc/SetId(atom/movable/screen/movable/action_button/our_button, mob/owner)
	//button id generation
	var/bitfield = 0
	for(var/datum/action/action in owner.actions)
		if(action == src) // This could be us, which is dumb
			continue
		var/atom/movable/screen/movable/action_button/button = action.viewers[owner.hud_used]
		if(action.name == name && button.id)
			bitfield |= button.id

	bitfield = ~bitfield // Flip our possible ids, so we can check if we've found a unique one
	for(var/i in 0 to 23) // We get 24 possible bitflags in dm
		var/bitflag = 1 << i // Shift us over one
		if(bitfield & bitflag)
			our_button.id = bitflag
			return

/// A general use signal proc that reacts to an event and updates our button icon in accordance
/datum/action/proc/update_icon_on_signal(datum/source)
	SIGNAL_HANDLER

	UpdateButtons()

/// Signal proc for COMSIG_MIND_TRANSFERRED - for minds, transfers our action to our new mob on mind transfer
/datum/action/proc/on_master_mind_swapped(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	// Grant() calls Remove() from the existing owner so we're covered on that
	Grant(source.current)

/// Starts a cooldown time to be shared with similar abilities
/// Will use default cooldown time if an override is not specified
/datum/action/proc/start_cooldown(override_cooldown_time)
	// "Shared cooldowns" covers actions which are not the same type,
	// but have the same cooldown group and are on the same mob
	if(cooldown_group)
		for(var/datum/action/cooldown/shared_ability in owner.actions - src)
			if(cooldown_group != shared_ability.cooldown_group)
				continue
			shared_ability.start_cooldown_self(override_cooldown_time)

	start_cooldown_self(override_cooldown_time)

/// Starts a cooldown time for this ability only
/// Will use default cooldown time if an override is not specified
/datum/action/proc/start_cooldown_self(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	UpdateButtons()
	// Needs to update once per second
	START_PROCESSING(SSprocessing, src)

/// Actions process to handle their cooldown timer
/datum/action/process()
	if(!owner || (next_use_time - world.time) <= 0)
		UpdateButtons()
		STOP_PROCESSING(SSfastprocess, src)
		return

	UpdateButtons()

/**
 * Set our action as the click override on the passed mob.
 */
/datum/action/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = src
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()
	UpdateButtons()
	return TRUE

/**
 * Unset our action as the click override of the passed mob.
 *
 * if refund_cooldown is TRUE, we are being unset by the user clicking the action off
 * if refund_cooldown is FALSE, we are being forcefully unset, likely by someone actually using the action
 */
/datum/action/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(on_who.client?.mouse_override_icon)
		on_who.update_mouse_pointer()
	UpdateButtons()
	return TRUE
