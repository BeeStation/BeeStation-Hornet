/datum/computer_file/program/ipc_self_monitor
	filename = "ipc_self_monitor"
	filedesc = "IPC Self-Monitoring"
	extended_desc = "A built-in app for IPC self-management and diagnostics."
	ui_header = "borg_self_monitor.gif" //DEBUG -- new icon before PR
	program_icon_state = "command"
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	unsendable = TRUE
	undeletable = TRUE
	size = 5
	tgui_id = "NtosIpcSelfMonitor"
	power_consumption = 0
	///A typed reference to the computer, specifying the ipc tablet type
	var/obj/item/modular_computer/tablet/ipc/tablet

/datum/computer_file/program/ipc_self_monitor/Destroy()
	tablet = null
	return ..()

/datum/computer_file/program/ipc_self_monitor/on_start(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/tablet/ipc))
		to_chat(user, span_warning("A warning flashes across \the [computer]: Device Incompatible."))
		return FALSE
	tablet = computer
	return ..()

/datum/computer_file/program/ipc_self_monitor/ui_data(mob/user)
	var/list/data = list()
	//TODO: fix runtime here
	if(!tablet.tablet_owner)
		return data
	var/charge = 0
	var/max_charge = 0
	if(istype(tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		var/obj/item/organ/stomach/battery/battery = tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_STOMACH)
		charge = battery.charge
		max_charge = battery.max_charge

	data["name"] = tablet.tablet_owner.real_name
	data["charge"] = charge
	data["max_charge"] = max_charge
	data["upgrade_core"] = get_ipc_upgrade_by_slot(tablet.tablet_owner.status_effects, UPGRADE_CORE)?.ui_data()
	data["upgrade_external"] = get_ipc_upgrade_by_slot(tablet.tablet_owner.status_effects, UPGRADE_EXTERNAL)?.ui_data()
	data["upgrade_utility"] = get_ipc_upgrade_by_slot(tablet.tablet_owner.status_effects, UPGRADE_UTILITY)?.ui_data()
	data["control_circuit"] = tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_UPGRADE_CONTROL) ? TRUE : FALSE

	return data

/datum/computer_file/program/ipc_self_monitor/ui_act(action, list/params)
	. = ..()
	switch(action)
		if("eject_control")
			var/obj/item/organ/control = tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_UPGRADE_CONTROL)
			if(istype(control))
				control.Remove(tablet.tablet_owner)
				control.forceMove(get_turf(tablet.tablet_owner))
				playsound(tablet.tablet_owner, 'sound/machines/terminal_insert_disc.ogg', 50)
				return TRUE


