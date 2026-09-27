/datum/status_effect/ipc_upgrade/cooling_system
	id = "ipc cooling system"
	name = "Cooling System"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	action_icon = "cooling_system"
	slot = UPGRADE_EXTERNAL
	active_power_requirement = 25
	item_type = /obj/item/ipc_upgrade/cooling_system

/datum/status_effect/ipc_upgrade/cooling_system/tick(seconds_between_ticks)
	if(!..())
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon = owner
	carbon.adjust_bodytemperature(-BODYTEMP_HEATING_MAX * 3 * seconds_between_ticks, BODYTEMP_NORMAL) // good for a few firestacks
	return TRUE
