/datum/status_effect/ipc_upgrade/tool_speedifier
	id = "ipc tool adaptor"
	name = "Tool Adaptor"
	slot = UPGRADE_UTILITY
	active_power_requirement = 10
	action_icon = "tool_speedifier"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	item_type = /obj/item/ipc_upgrade/tool_speedifier

/datum/status_effect/ipc_upgrade/tool_speedifier/on_activate(atom/target)
	owner.tool_proficiency *= 0.5

/datum/status_effect/ipc_upgrade/tool_speedifier/on_deactivate()
	owner.tool_proficiency /= 0.5
