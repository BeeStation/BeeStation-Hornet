/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	icon_icon = 'icons/hud/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Whether this action is intended for the AI. Stuff breaks a lot if this is done differently.
	var/ai_action = FALSE

/datum/action/item_action/mod/New(Target)
	..()
	if(!istype(Target, /obj/item/mod/control))
		qdel(src)
		return
	if(ai_action)
		background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

/datum/action/item_action/mod/Grant(mob/user)
	var/obj/item/mod/control/mod = master
	if(ai_action && user != mod.ai_assistant)
		return
	else if(!ai_action && user == mod.ai_assistant)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	var/obj/item/mod/control/mod = master
	if(ai_action && user != mod.ai_assistant)
		return
	else if(!ai_action && user == mod.ai_assistant)
		return
	return ..()

/datum/action/item_action/mod/on_activate(mob/user, atom/target, trigger_flags)
	if(!is_available(feedback = TRUE))
		return FALSE
	var/obj/item/mod/control/mod = target
	if(mod.malfunctioning && prob(75))
		mod.balloon_alert(usr, "button malfunctions!")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Deploy/Conceal a part of the MODsuit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/on_activate(mob/user, atom/target, trigger_flags)
	var/obj/item/mod/control/mod = target
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		mod.quick_deploy(usr)
	else
		mod.choose_deploy(usr)

/datum/action/item_action/mod/deploy/ai
	ai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Activate/Deactivate the MODsuit."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/on_activate(mob/user, atom/target, trigger_flags)
	if(!(trigger_flags & TRIGGER_SECONDARY_ACTION) && !ready)
		ready = TRUE
		button_icon_state = "activate-ready"
		update_buttons()
		addtimer(CALLBACK(src, PROC_REF(reset_ready)), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)
	update_buttons()

/datum/action/item_action/mod/activate/ai
	ai_action = TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/on_activate(mob/user, atom/target)
	var/obj/item/mod/control/mod = target
	mod.quick_module(usr)

/datum/action/item_action/mod/module/ai
	ai_action = TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/on_activate(mob/user, atom/target)
	var/obj/item/mod/control/mod = target
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/ai
	ai_action = TRUE

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A reference to the mob we are pinned to.
	var/mob/pinner
	/// Timer until we remove our cooldown overlay
	var/cooldown_timer

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	var/obj/item/mod/control/mod = Target
	if(user == mod.ai_assistant)
		ai_action = TRUE
	. = ..()
	module = linked_module
	pinner = user
	module.pinned_to[REF(user)] = src
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands and check conscious
		check_flags = NONE
	name = "Activate [capitalize(linked_module.name)]"
	desc = "Quickly activate [linked_module]."
	icon_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	RegisterSignals(linked_module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_USED,
	), PROC_REF(module_interacted_with))
	RegisterSignal(linked_module, COMSIG_MODULE_COOLDOWN_STARTED, PROC_REF(cooldown_started))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(pinner_deleted))

/datum/action/item_action/mod/pinned_module/Destroy()
	deltimer(cooldown_timer)
	UnregisterSignal(module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_COOLDOWN_STARTED,
		COMSIG_MODULE_USED,
	))
	module.pinned_to -= REF(pinner)
	module = null
	pinner = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	if(pinner != user)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/on_activate(mob/user, atom/target)
	module.on_select()

/datum/action/item_action/mod/pinned_module/apply_icon(atom/movable/screen/movable/action_button/current_button, force)
	. = ..(current_button, force = TRUE)
	if(override)
		return
	var/obj/item/mod/control/mod = master
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		current_button.add_overlay(image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_cooldown"))

/// If the guy whose UI we are pinned to got deleted
/datum/action/item_action/mod/pinned_module/proc/pinner_deleted()
	pinner = null
	qdel(src)

/datum/action/item_action/mod/pinned_module/proc/module_interacted_with(datum/source)
	SIGNAL_HANDLER

	update_buttons()

/datum/action/item_action/mod/pinned_module/proc/cooldown_started(datum/source, cooldown_time)
	SIGNAL_HANDLER

	deltimer(cooldown_timer)
	update_buttons()
	if (cooldown_time == 0)
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(update_buttons), UPDATE_BUTTON_OVERLAY), cooldown_time + 1, TIMER_STOPPABLE)
