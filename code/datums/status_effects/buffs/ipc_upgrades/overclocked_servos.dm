/datum/movespeed_modifier/overclocked_servos
	multiplicative_slowdown = -0.35

/datum/status_effect/ipc_upgrade/overclocked_servos
	id = "ipc overclocked servos"
	name = "Overclocked Servos"
	slot = UPGRADE_CORE
	active_power_requirement = 50
	action_icon = "overclocked_servos"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	item_type = /obj/item/ipc_upgrade/overclocked_servos

/datum/status_effect/ipc_upgrade/overclocked_servos/on_activate(atom/target)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/overclocked_servos)

/datum/status_effect/ipc_upgrade/overclocked_servos/on_deactivate()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/overclocked_servos)
