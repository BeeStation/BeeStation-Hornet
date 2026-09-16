/obj/item/organ/cyberimp/ipc_control
	name = "upgrade control module"
	desc = "A industrial grade FPGA designed to integrate with installed upgrades."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_implant"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	w_class = WEIGHT_CLASS_TINY
	slot = ORGAN_SLOT_UPGRADE_CONTROL
	light_range = 0

	var/datum/weakref/user

/obj/item/organ/cyberimp/ipc_control/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/ipc_circuit,
		new /obj/item/circuit_component/upgrade_setter/core,
		new /obj/item/circuit_component/upgrade_setter/external,
		new /obj/item/circuit_component/upgrade_setter/utility,
	), SHELL_CAPACITY_MEDIUM)
	RegisterSignal(src, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_installed))
	RegisterSignal(src, COMSIG_ORGAN_REMOVED, PROC_REF(on_uninstalled))

/obj/item/organ/cyberimp/ipc_control/Destroy()
	UnregisterSignal(src, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	. = ..()

/obj/item/organ/cyberimp/ipc_control/on_insert(mob/living/carbon/receiver)
	. = ..()
	// Organs are put in nullspace, but this breaks circuit interactions
	forceMove(receiver)

/obj/item/organ/cyberimp/ipc_control/attack(mob/living/target_mob, mob/living/user, params)
	if(isipc(target_mob))
		if(target_mob != user)
			to_chat(target_mob, span_warningbig("[user] is installing [src] into your control port!"))
		if(!do_after(user, 2 SECONDS, target_mob))
			return
		playsound(target_mob, 'sound/machines/terminal_insert_disc.ogg', 50)
		to_chat(user, span_notice("You insert \the [src] into [target_mob]."))
		Insert(target_mob)
		return TRUE
	. = ..()

/obj/item/organ/cyberimp/ipc_control/proc/on_installed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	user = WEAKREF(owner)

/obj/item/organ/cyberimp/ipc_control/proc/on_uninstalled(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	user = null

/obj/item/circuit_component/ipc_circuit
	display_name = "IPC Control"
	desc = "Interfaces with the parent IPC."

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/upgrade_external_set
	var/datum/port/input/upgrade_utility_set
	var/datum/port/output/user_port
	var/datum/port/output/battery_port
	var/datum/port/output/max_battery_port

	var/obj/item/organ/stomach/battery/battery
	var/obj/item/organ/cyberimp/ipc_control/controller

/obj/item/circuit_component/ipc_circuit/register_shell(atom/movable/shell)
	if(!istype(shell, /obj/item/organ/cyberimp/ipc_control))
		return
	controller = shell
	RegisterSignal(controller, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_installed))
	RegisterSignal(controller, COMSIG_ORGAN_REMOVED, PROC_REF(on_uninstalled))

/obj/item/circuit_component/ipc_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(controller, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	controller = null

/obj/item/circuit_component/ipc_circuit/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	battery_port = add_output_port("Battery Charge", PORT_TYPE_NUMBER)
	max_battery_port = add_output_port("Battery Max Charge", PORT_TYPE_NUMBER)
	user_port = add_output_port("User", PORT_TYPE_ATOM)

/obj/item/circuit_component/ipc_circuit/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(send_message_signal, port))
		send_message()

/obj/item/circuit_component/ipc_circuit/proc/on_installed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_battery_added))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_battery_removed))
	user_port.set_output(controller.user?.resolve())
	on_battery_added(owner, owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/obj/item/circuit_component/ipc_circuit/proc/on_uninstalled(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	user_port.set_output(null)
	on_battery_removed(owner, battery)

/obj/item/circuit_component/ipc_circuit/proc/send_message()
	var/sent_message = trim(message.value)
	if (!sent_message)
		return
	if(!controller)
		return
	var/mob/living/carbon/resolved_owner = controller.user?.resolve()
	if(isnull(resolved_owner))
		return

	if(resolved_owner.stat == DEAD)
		return

	to_chat(resolved_owner, "<i>System notification received: </i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/ipc_circuit/proc/on_battery_added(mob/living/carbon/owner, obj/item/organ/stomach/battery/added)
	SIGNAL_HANDLER
	if(!istype(added))
		return
	battery = added
	RegisterSignal(battery, COMSIG_ORGAN_BATTERY_CHARGED, PROC_REF(battery_charged))
	battery_port.set_output(battery.charge)
	max_battery_port.set_output(battery.max_charge)

/obj/item/circuit_component/ipc_circuit/proc/on_battery_removed(mob/living/carbon/owner, obj/item/organ/stomach/battery/removed)
	SIGNAL_HANDLER
	if(!istype(removed))
		return
	if(removed == battery)
		battery = null
	UnregisterSignal(removed, COMSIG_ORGAN_BATTERY_CHARGED)
	battery_port.set_output(0)
	max_battery_port.set_output(0)

/obj/item/circuit_component/ipc_circuit/proc/battery_charged(obj/item/organ/stomach/battery/adjusted_battery, amount)
	SIGNAL_HANDLER
	battery_port.set_output(adjusted_battery.charge)

/obj/item/circuit_component/upgrade_setter
	display_name = "IPC Setter"
	desc = "A component that allows setting the state of synth upgrades within an IPC."

	required_shells = list(/obj/item/organ/cyberimp/ipc_control)

	var/slot_to_set
	var/input_name

	var/datum/port/input/upgrade_on
	var/datum/port/input/upgrade_off
	var/datum/port/output/failure

	var/obj/item/organ/cyberimp/ipc_control/controller

/obj/item/circuit_component/upgrade_setter/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/ipc_control))
		controller = shell

/obj/item/circuit_component/upgrade_setter/unregister_shell(atom/movable/shell)
	controller = null

/obj/item/circuit_component/upgrade_setter/populate_ports()
	upgrade_on = add_input_port("Activate [input_name]", PORT_TYPE_SIGNAL)
	upgrade_off = add_input_port("Deactivate [input_name]", PORT_TYPE_SIGNAL)
	failure = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/upgrade_setter/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(upgrade_on, port))
		if(!set_upgrade(slot_to_set, TRUE))
			failure.set_output(COMPONENT_SIGNAL)
	if(COMPONENT_TRIGGERED_BY(upgrade_off, port))
		if(!set_upgrade(slot_to_set, FALSE))
			failure.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/upgrade_setter/proc/set_upgrade(slot, state)
	if(!controller)
		return FALSE
	var/mob/living/carbon/resolved_owner = controller.user?.resolve()
	if(!resolved_owner)
		return FALSE
	var/datum/status_effect/ipc_upgrade/upgrade = get_ipc_upgrade_by_slot(resolved_owner.status_effects, slot)
	if(!upgrade)
		return FALSE
	if(state && upgrade.can_activate())
		upgrade.activate()
		return TRUE
	if(!state && upgrade.can_deactivate())
		upgrade.deactivate()
		return TRUE
	return FALSE

/obj/item/circuit_component/upgrade_setter/core
	display_name = "Core Upgrade Setter"
	slot_to_set = UPGRADE_CORE
	input_name = "Core Upgrade"

/obj/item/circuit_component/upgrade_setter/external
	display_name = "External Upgrade Setter"
	slot_to_set = UPGRADE_EXTERNAL
	input_name = "External Upgrade"

/obj/item/circuit_component/upgrade_setter/utility
	display_name = "Utility Upgrade Setter"
	slot_to_set = UPGRADE_UTILITY
	input_name = "Utility Upgrade"
