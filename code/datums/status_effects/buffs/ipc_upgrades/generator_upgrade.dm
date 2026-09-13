/datum/status_effect/ipc_upgrade/ipc_generator
	id = "ipc rtg generator"
	name = "Isotope Decay Generator"
	action_icon = "generator"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	item_type = /obj/item/ipc_upgrade/ipc_generator
	var/power_generation = 5

/datum/status_effect/ipc_upgrade/ipc_generator/tick(seconds_between_ticks)
	if(!should_process())
		return FALSE
	if(!battery)
		return FALSE
	if(!can_generate())
		to_chat(owner, span_warning("Your installed [src] is out of fuel!"))
		playsound(owner, 'sound/machines/click.ogg', 50)
		deactivate()
		return FALSE
	battery.adjust_charge(power_generation * seconds_between_ticks)
	return TRUE

/datum/status_effect/ipc_upgrade/ipc_generator/ui_data()
	var/list/data = ..()
	data["active_power_req"] = -power_generation
	return data

/datum/status_effect/ipc_upgrade/ipc_generator/proc/can_generate()
	return TRUE

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator
	id = "ipc fuel generator"
	name = "Plasmatic Generator"
	power_generation = 10
	item_type = /obj/item/ipc_upgrade/fuel_generator
	var/fuel_consumption = 50
	var/datum/component/material_container/materials

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/on_apply()
	. = ..()
	materials = owner._AddComponent(list(/datum/component/material_container, list(/datum/material/plasma), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE / 2, allowed_types = /obj/item/stack))

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/on_remove()
	. = ..()
	qdel(materials)

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/can_generate()
	if(!materials.use_amount_mat(fuel_consumption, /datum/material/plasma))
		return FALSE
	return TRUE
