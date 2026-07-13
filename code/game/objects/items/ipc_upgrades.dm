/obj/item/ipc_upgrade
	icon = 'icons/obj/ipc_upgrade.dmi'

	var/datum/status_effect/ipc_upgrade/upgrade
	var/slot

/obj/item/ipc_upgrade/Initialize(mapload)
	. = ..()
	var/datum/status_effect/ipc_upgrade/upgrade_type = upgrade
	slot = upgrade_type.slot

/obj/item/ipc_upgrade/proc/insert(mob/living/carbon/owner)
	if(get_ipc_upgrade_by_slot(owner.status_effects, slot))
		return FALSE
	owner.apply_status_effect(upgrade)
	return TRUE
