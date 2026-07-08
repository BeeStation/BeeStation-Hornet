/obj/item/organ/cyberimp/ipc_control
	name = "IPC control module"
	desc = "A industrial grade FPGA designed to integrate with IPCs."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "bci"
	visual = FALSE
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

	light_range = 0

/obj/item/ipc_control/Initialize(mapload)
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
	var/datum/port/output/user_port
	var/datum/port/output/battery_port
	var/datum/weakref/user
	var/datum/weakref/battery

/obj/item/circuit_component/ipc_circuit/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	battery_port = add_output_port("Battery", PORT_TYPE_NUMBER)
	user_port = add_output_port("User", PORT_TYPE_ATOM)

/obj/item/circuit_component/ipc_circuit/register_shell(atom/movable/shell)
	return

/obj/item/circuit_component/ipc_circuit/unregister_shell(atom/movable/shell)
	return

/obj/item/circuit_component/ipc_circuit/should_receive_input(datum/port/input/port)
	return

/obj/item/circuit_component/ipc_circuit/input_received(datum/port/input/port)
	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	var/mob/living/carbon/resolved_owner = user?.resolve()
	if(isnull(resolved_owner))
		return

	if(resolved_owner.stat == DEAD)
		return

	to_chat(resolved_owner, "<i>System notification recieved: </i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/ipc_circuit/proc/on_installed(datum/source, mob/living/carbon/owner)
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_battery_added))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_battery_removed))
	RegisterSignal(owner, COMSIG_ORGAN_BATTERY_CHARGED, PROC_REF(battery_charged))
	user_port.set_output(owner)
	user = WEAKREF(owner)
	on_battery_added(owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/obj/item/circuit_component/ipc_circuit/proc/on_uninstalled(datum/source, mob/living/carbon/owner)
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	user_port.set_output(null)
	user = null
	battery = null

/obj/item/circuit_component/ipc_circuit/proc/on_battery_added(obj/item/organ/added)
	if(!istype(added, /obj/item/organ/stomach/battery))
		return
	battery = WEAKREF(added)

/obj/item/circuit_component/ipc_circuit/proc/on_battery_removed(obj/item/organ/removed)
	if(!istype(removed, /obj/item/organ/stomach/battery))
		return
	battery = null

/obj/item/circuit_component/ipc_circuit/proc/battery_charged(obj/item/organ/stomach/battery/adjusted_battery, amount)
	battery_port.set_output(adjusted_battery.charge)
