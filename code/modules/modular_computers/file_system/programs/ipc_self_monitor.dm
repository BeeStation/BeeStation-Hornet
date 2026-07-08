/datum/computer_file/program/ipc_self_monitor
	filename = "borg_self_monitor"
	filedesc = "Cyborg Self-Monitoring"
	extended_desc = "A built-in app for cyborg self-management and diagnostics."
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

/datum/computer_file/program/ipc_self_monitor/on_start(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/tablet/ipc))
		to_chat(user, span_warning("A warning flashes across \the [computer]: Device Incompatible."))
		return FALSE
	return ..()

/datum/computer_file/program/ipc_self_monitor/ui_data(mob/user)
	var/list/data = list()
	if(!tablet.tablet_owner)
		return data
	var/charge = 0
	var/max_charge = 0
	if(istype(tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		var/obj/item/organ/stomach/battery/battery = tablet.tablet_owner.get_organ_slot(ORGAN_SLOT_STOMACH)
		charge = battery.charge
		max_charge = battery.max_charge

	data["name"] = tablet.tablet_owner.name
	data["charge"] = charge
	data["max_charge"] = charge
	data["upgrade_core"] = get_ipc_upgrade_by_slot(tablet.tablet_owner, UPGRADE_CORE).ui_data()
	data["upgrade_external"] = get_ipc_upgrade_by_slot(tablet.tablet_owner, UPGRADE_EXTERNAL).ui_data()
	data["upgrade_utility"] = get_ipc_upgrade_by_slot(tablet.tablet_owner, UPGRADE_UTILITY).ui_data()
	//data["control_circuit"] = tablet.tablet_owner.get_organ_slot() ? TRUE : FALSE
