/obj/item/organ/cyberimp/ipc_control
	name = "IPC control module"
	desc = "A industrial grade FPGA designed to integrate with IPCs."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "bci"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	w_class = WEIGHT_CLASS_TINY

	light_range = 0

/obj/item/organ/cyberimp/ipc_control/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/ipc_circuit,
	), SHELL_CAPACITY_MEDIUM)

/obj/item/circuit_component/ipc_circuit
	display_name = "IPC control"
	desc = "Interfaces with the parent IPC."

	/// A reference to the action button to look at charge/get info
	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/upgrade_target
	var/datum/port/input/upgrade_core_toggle
	var/datum/port/input/upgrade_external_toggle
	var/datum/port/input/upgrade_utility_toggle
	var/datum/port/output/user_port
	var/datum/port/output/battery_port
	var/datum/weakref/user

/obj/item/circuit_component/ipc_circuit/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	upgrade_target = add_input_port("Upgrade Target", PORT_TYPE_ATOM)
	upgrade_core_toggle = add_input_port("Toggle Core Upgrade", PORT_TYPE_SIGNAL)
	upgrade_external_toggle = add_input_port("Toggle External Upgrade", PORT_TYPE_SIGNAL)
	upgrade_utility_toggle = add_input_port("Toggle Utility Upgrade", PORT_TYPE_SIGNAL)
	battery_port = add_output_port("Battery", PORT_TYPE_NUMBER)
	user_port = add_output_port("User", PORT_TYPE_ATOM)

/obj/item/circuit_component/ipc_circuit/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(upgrade_core_toggle, port))
		toggle_upgrade(UPGRADE_CORE)
	if(COMPONENT_TRIGGERED_BY(upgrade_external_toggle, port))
		toggle_upgrade(UPGRADE_EXTERNAL)
	if(COMPONENT_TRIGGERED_BY(upgrade_utility_toggle, port))
		toggle_upgrade(UPGRADE_UTILITY)
	if(COMPONENT_TRIGGERED_BY(send_message_signal, port))
		send_message()

/obj/item/circuit_component/ipc_circuit/proc/toggle_upgrade(slot)
	var/mob/living/carbon/resolved_owner = user?.resolve()
	if(!resolved_owner)
		return
	var/datum/status_effect/ipc_upgrade/upgrade = get_ipc_upgrade_by_slot(resolved_owner.status_effects, slot)
	if(!upgrade)
		return
	upgrade.toggle(upgrade_target.value)

/obj/item/circuit_component/ipc_circuit/proc/send_message()
	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	var/mob/living/carbon/resolved_owner = user?.resolve()
	if(isnull(resolved_owner))
		return

	if(resolved_owner.stat == DEAD)
		return

	to_chat(resolved_owner, "<i>System notification recieved: </i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/ipc_circuit/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_installed))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_uninstalled))

/obj/item/circuit_component/ipc_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))

/obj/item/circuit_component/ipc_circuit/proc/on_installed(datum/source, mob/living/carbon/owner)
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_battery_added))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_battery_removed))
	user_port.set_output(owner)
	user = WEAKREF(owner)
	on_battery_added(owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/obj/item/circuit_component/ipc_circuit/proc/on_uninstalled(datum/source, mob/living/carbon/owner)
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	user_port.set_output(null)
	user = null

/obj/item/circuit_component/ipc_circuit/proc/on_battery_added(obj/item/organ/added)
	if(!istype(added, /obj/item/organ/stomach/battery))
		return
	RegisterSignal(added, COMSIG_ORGAN_BATTERY_CHARGED, PROC_REF(battery_charged))

/obj/item/circuit_component/ipc_circuit/proc/on_battery_removed(obj/item/organ/removed)
	if(!istype(removed, /obj/item/organ/stomach/battery))
		return
	UnregisterSignal(removed, COMSIG_ORGAN_BATTERY_CHARGED)
	battery_port.set_output(0)

/obj/item/circuit_component/ipc_circuit/proc/battery_charged(obj/item/organ/stomach/battery/adjusted_battery, amount)
	battery_port.set_output(adjusted_battery.charge)
