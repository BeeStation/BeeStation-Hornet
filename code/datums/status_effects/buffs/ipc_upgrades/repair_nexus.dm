/datum/status_effect/ipc_upgrade/repair_nexus
	id = "ipc repair nexus"
	name = "Repair Nexus"
	active_power_requirement = 15
	item_type = /obj/item/ipc_upgrade/repair_nexus
	action_icon = "repair_nexus"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	var/overdrive = FALSE
	var/healing_power = 0.5

/datum/status_effect/ipc_upgrade/repair_nexus/tick(seconds_between_ticks)
	if(!should_process()) // doesnt call parent due to unique power handling
		return FALSE
	if((owner.stat != DEAD) && (owner.health < HEALTH_THRESHOLD_CRIT))
		if(!overdrive)
			to_chat(owner, span_warning("Your installed [src] has activated overdrive mode!"))
			overdrive = TRUE
	else
		if(overdrive)
			to_chat(owner, span_warning("Your installed [src] has deactived overdrive mode!"))
			overdrive = FALSE
	if(!drain_cell(active_power_requirement * seconds_between_ticks * (overdrive ? 3 : 1), overdrive))
		to_chat(owner, span_notice("The [name] runs out of power!"))
		playsound(owner, 'sound/machines/apc/PowerDown_001.ogg', 10)
		deactivate()
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	var/list/parts = carbon_owner.get_damaged_bodyparts(TRUE, TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	if(!parts.len)
		return FALSE
	var/healing_power_actual = healing_power * (overdrive ? 10 : 1)
	for(var/obj/item/bodypart/limb in parts)
		if(limb.heal_damage((healing_power_actual / parts.len) * seconds_between_ticks, (healing_power_actual / parts.len) * seconds_between_ticks, required_bodytype = BODYTYPE_ROBOTIC))
			owner.update_damage_overlays()
	return TRUE
