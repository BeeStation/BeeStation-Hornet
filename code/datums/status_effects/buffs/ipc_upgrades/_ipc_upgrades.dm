//not so sure about making a global proc for this
/proc/get_ipc_upgrade_by_slot(list/datum/status_effect/effects, slot) as /datum/status_effect/ipc_upgrade
	if(!effects)
		return
	for(var/datum/status_effect/ipc_upgrade/upgrade in effects)
		if(upgrade.slot == slot)
			return upgrade

/datum/status_effect/ipc_upgrade
	id = "ipc upgrade"
	alert_type = null
	on_remove_on_mob_delete = TRUE
	abstract_type = /datum/status_effect/ipc_upgrade

	var/name = "Generic Upgrade"
	///What slot this occupies. Only one upgrade per slot.
	var/slot = UPGRADE_CORE
	///Passive power requirement
	var/active_power_requirement = 0
	///Activation power requirement
	var/power_requirement = 0
	///The battery this upgrade uses power from
	var/obj/item/organ/stomach/battery/battery
	///Whether this upgrade should activate once and reset (rather than making active = TRUE)
	var/singleton = FALSE
	///Whether this should process or not
	var/active = FALSE
	///The type of ipc_upgrade_action this upgrade uses, can be null for no action
	var/action_type = null
	///What the action icon_state will be. Does nothing if action_type is not specified
	var/action_icon = null
	///The actual action, created from action_type
	var/datum/action/innate/ipc_upgrade_action/action
	///The length of the cooldown between activations
	var/cooldown_length = 0

	var/overlay_file = 'icons/obj/ipc_upgrade_worn.dmi'
	///A nullable list containing the overlays to add
	var/upgrade_overlays = null
	///What item this will create when it is removed
	var/item_type = null

	var/list/mutable_appearance/mut_appearances = list()

	COOLDOWN_DECLARE(activated_cooldown) //You may be wondering why there is a cooldown when actions already have one. It is because wiremod ipc_control shells can activate upgrades directly, so we need to check cooldowns!

/datum/status_effect/ipc_upgrade/on_creation(mob/living/new_owner)
	if(!iscarbon(new_owner))
		stack_trace("An IPC upgrade has somehow been applied to a non-carbon mob!")
		qdel(src)
		return
	return ..()

/datum/status_effect/ipc_upgrade/on_apply()
	. = ..()
	if(action_type)
		action = new action_type(src)
		if(action_icon)
			action.button_icon_state = action_icon
		action.Grant(owner)
	if(upgrade_overlays && overlay_file)
		for(var/overlay in upgrade_overlays)
			var/mut_appearance = mutable_appearance(overlay_file, overlay, CALCULATE_MOB_OVERLAY_LAYER(upgrade_overlays[overlay]))
			mut_appearances += mut_appearance
			owner.add_overlay(mut_appearance)
		owner.update_appearance(UPDATE_ICON)
	RegisterSignal(owner, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))
	RegisterSignal(owner, COMSIG_CARBON_SPECIESCHANGE, PROC_REF(species_change))
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_battery_added))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_battery_removed))
	on_battery_added(owner, owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/datum/status_effect/ipc_upgrade/on_remove()
	if(active)
		deactivate()
	for(var/mutable_appearance/mut_appearance in mut_appearances)
		owner.cut_overlay(mut_appearance)
	QDEL_NULL(action)
	QDEL_LIST(mut_appearances)
	UnregisterSignal(owner, list(COMSIG_ATOM_EMP_ACT, COMSIG_CARBON_SPECIESCHANGE, COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	on_battery_removed(owner, owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/datum/status_effect/ipc_upgrade/tick(seconds_between_ticks)
	if(!should_process())
		return FALSE
	if(drain_cell(active_power_requirement * seconds_between_ticks))
		return TRUE
	to_chat(owner, span_notice("The [name] runs out of power!"))
	playsound(owner, 'sound/machines/apc/PowerDown_001.ogg', 10)
	deactivate()
	return FALSE

/datum/status_effect/ipc_upgrade/proc/should_process()
	return active

/datum/status_effect/ipc_upgrade/proc/can_activate()
	return !active && COOLDOWN_FINISHED(src, activated_cooldown) && can_drain_cell(power_requirement + active_power_requirement)

/datum/status_effect/ipc_upgrade/proc/toggle(atom/target)
	if(!active)
		activate(target)
	else
		deactivate()

/datum/status_effect/ipc_upgrade/proc/activate(atom/target)
	if(!can_activate())
		playsound(owner, 'sound/machines/buzz-sigh.ogg', 10)
		to_chat(owner, span_notice("The [name] failed to activate!"))
		return FALSE
	if(!singleton)
		active = TRUE
	COOLDOWN_START(src, activated_cooldown, cooldown_length)
	drain_cell(power_requirement)
	on_activate(target)
	return TRUE

/// Called by activate(). target can and will be null, sometimes even for targeted upgrades.
/datum/status_effect/ipc_upgrade/proc/on_activate(atom/target)
	return

/datum/status_effect/ipc_upgrade/proc/deactivate()
	if(!active)
		return
	if(action)
		action.deactivate(owner) // kinda bad to call this twice (once when they click, once when the upgrade itself deactivates) but no good way to change action.active externally
	active = FALSE
	on_deactivate()

/datum/status_effect/ipc_upgrade/proc/on_deactivate()
	return

/datum/status_effect/ipc_upgrade/proc/can_drain_cell(amount, dangerous = FALSE)
	if(!amount)
		return TRUE
	if(!battery)
		return FALSE
	if(dangerous)
		if(battery.charge < amount)
			return FALSE
	else
		if((battery.charge - UPGRADE_LOW_POWER_THRESHOLD) < amount)
			return FALSE
	return TRUE

/datum/status_effect/ipc_upgrade/proc/drain_cell(amount, dangerous = FALSE)
	if(!amount)
		return TRUE
	if(!can_drain_cell(amount, dangerous))
		return FALSE
	battery.adjust_charge(-amount)
	return TRUE

/datum/status_effect/ipc_upgrade/proc/extract()
	if(item_type)
		new item_type(get_turf(owner))
	owner.remove_status_effect(src.type)

/datum/status_effect/ipc_upgrade/proc/emp_act(severity, protection)
	SIGNAL_HANDLER
	return

/datum/status_effect/ipc_upgrade/proc/species_change(new_race)
	SIGNAL_HANDLER
	if(UPGRADE_CAN_HAVE(owner))
		return
	extract()

/datum/status_effect/ipc_upgrade/proc/on_battery_added(mob/living/carbon/owner, obj/item/organ/stomach/battery/added)
	SIGNAL_HANDLER
	if(!istype(added))
		return
	battery = added
	RegisterSignal(battery, COMSIG_ORGAN_BATTERY_CHARGED, PROC_REF(battery_charged))

/datum/status_effect/ipc_upgrade/proc/on_battery_removed(mob/living/carbon/owner, obj/item/organ/stomach/battery/removed)
	SIGNAL_HANDLER
	if(!istype(removed))
		return
	UnregisterSignal(removed, COMSIG_ORGAN_BATTERY_CHARGED)
	battery = null

/datum/status_effect/ipc_upgrade/proc/battery_charged(obj/item/organ/stomach/battery/adjusted_battery, amount)
	SIGNAL_HANDLER
	if(action)
		action.update_buttons()

/datum/status_effect/ipc_upgrade/ui_data()
	var/list/data = list()
	data["name"] = name
	data["active"] = active
	data["power_req"] = power_requirement
	data["active_power_req"] = active_power_requirement
	return data

/datum/action/innate/ipc_upgrade_action
	name = "Generic Upgrade Action"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "shoulder_gun_off"
	var/datum/status_effect/ipc_upgrade/upgrade = null
	var/has_activate_text = TRUE
	var/has_deactivate_text = TRUE
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/ipc_upgrade_action/New(datum/status_effect/ipc_upgrade/new_upgrade)
	name = "Activate [new_upgrade.name]"
	enable_text = has_activate_text ? "Activated [new_upgrade.name]!" : null
	disable_text = has_deactivate_text ? "Deactivated [new_upgrade.name]!" : null
	cooldown_time = new_upgrade.cooldown_length
	upgrade = new_upgrade

/datum/action/innate/ipc_upgrade_action/is_available(feedback = FALSE)
	if(!..())
		return FALSE
	if(upgrade.active)
		return TRUE
	if(!upgrade.can_activate())
		return FALSE
	return TRUE

/datum/action/innate/ipc_upgrade_action/toggleable
	toggleable = TRUE

/datum/action/innate/ipc_upgrade_action/toggleable/on_activate(mob/user, atom/target)
	..()
	. = upgrade.activate(target)
	update_buttons()

/datum/action/innate/ipc_upgrade_action/toggleable/on_deactivate(mob/user, atom/target)
	..()
	. = upgrade.deactivate()
	update_buttons()

/datum/action/innate/ipc_upgrade_action/toggleable/update_button(atom/movable/screen/movable/action_button/button, status_only, force)
	if(upgrade.action_icon)
		button_icon_state = upgrade.active ? "[upgrade.action_icon]_on" : "[upgrade.action_icon]_off"
	return ..()

/datum/action/innate/ipc_upgrade_action/toggleable/no_text
	has_activate_text = FALSE
	has_deactivate_text = FALSE

/datum/action/innate/ipc_upgrade_action/targeted
	requires_target = TRUE
	toggleable = FALSE
	has_deactivate_text = FALSE

/datum/action/innate/ipc_upgrade_action/targeted/on_activate(mob/user, atom/target)
	..()
	return upgrade.activate(target)

/datum/action/innate/ipc_upgrade_action/untargeted
	toggleable = FALSE
	has_deactivate_text = FALSE

/datum/action/innate/ipc_upgrade_action/untargeted/on_activate(mob/user, atom/target)
	..()
	return upgrade.activate()
