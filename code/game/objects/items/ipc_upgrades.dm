/obj/item/organ/ipc_upgrade/
	name = "ipc upgrade module"
	desc = "Does nothing"
	icon = 'icons/obj/module.dmi'
	icon_state = "cell"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_UPGRADE_CORE

	organ_flags = ORGAN_ROBOTIC

	///Passive power requirement
	var/active_power_requirement = 0
	///Activation power requirement
	var/power_requirement = 0
	var/active = FALSE
	///The type of ipc_upgrade_action this upgrade uses, can be null for no action
	var/action_type = null

/obj/item/organ/ipc_upgrade/Initialize(mapload)
	. = ..()
	if(action_type)
		add_item_action(new action_type(src))

/obj/item/organ/ipc_upgrade/Destroy()
	return ..()

/obj/item/organ/ipc_upgrade/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(active)
		deactivate()

/obj/item/organ/ipc_upgrade/proc/should_process()
	return can_drain_cell(power_requirement) && active

/obj/item/organ/ipc_upgrade/proc/can_activate()
	return can_drain_cell(power_requirement) && !active

/obj/item/organ/ipc_upgrade/proc/activate()
	if(!can_activate())
		return
	active = TRUE

/obj/item/organ/ipc_upgrade/proc/deactivate()
	active = FALSE

/obj/item/organ/ipc_upgrade/proc/can_drain_cell(amount, obj/item/organ/stomach/battery/battery)
	if(!battery)
		if(!owner)
			return FALSE
		if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
			return FALSE
		battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(battery.charge < amount)
		return FALSE
	return TRUE

/obj/item/organ/ipc_upgrade/proc/drain_cell(amount)
	if(!owner)
		return FALSE
	if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		return FALSE
	var/obj/item/organ/stomach/battery/battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!can_drain_cell(amount, battery))
		return FALSE
	battery.adjust_charge(-amount)
	return TRUE

/datum/action/innate/ipc_upgrade_action
	name = "Generic Upgrade Action"
	var/obj/item/organ/ipc_upgrade/upgrade = null

/datum/action/innate/ipc_upgrade_action/New(obj/item/organ/ipc_upgrade/new_upgrade)
	..()
	name = "Activate [new_upgrade.name]"
	upgrade = new_upgrade

/datum/action/innate/ipc_upgrade_action/is_available(feedback = FALSE)
	if(!..())
		return FALSE
	if(!upgrade.can_activate())
		return FALSE
	return TRUE

/datum/action/innate/ipc_upgrade_action/on_activate(mob/user, atom/target)
	upgrade.activate()

/obj/item/organ/ipc_upgrade/repair_nexus
	name = "repair nexus"
	desc = "Uses power to repair IPC frames"
	power_requirement = 5
	var/healing_power = 0.5
	action_type = /datum/action/innate/ipc_upgrade_action

/obj/item/organ/ipc_upgrade/repair_nexus/process(delta_time)
	if(!should_process())
		return
	if(!owner)
		return
	var/list/parts = owner.get_damaged_bodyparts(TRUE, TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	if(!parts.len)
		return
	for(var/obj/item/bodypart/limb in parts)
		if(limb.heal_damage(healing_power / parts.len, healing_power / parts.len, null, BODYTYPE_ROBOTIC))
			owner.update_damage_overlays()
