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

/obj/item/organ/cyberimp/ipc_control/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/ipc_circuit,
	), SHELL_CAPACITY_MEDIUM)

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

/obj/item/circuit_component/ipc_circuit
	display_name = "IPC control"
	desc = "Interfaces with the parent IPC."

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/upgrade_target
	var/datum/port/input/upgrade_core_toggle
	var/datum/port/input/upgrade_external_toggle
	var/datum/port/input/upgrade_utility_toggle
	var/datum/port/output/user_port
	var/datum/port/output/battery_port
	var/datum/weakref/user
	var/obj/item/organ/stomach/battery/battery

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

	to_chat(resolved_owner, "<i>System notification received: </i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/ipc_circuit/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_installed))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_uninstalled))

/obj/item/circuit_component/ipc_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))

/obj/item/circuit_component/ipc_circuit/proc/on_installed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_battery_added))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_battery_removed))
	user_port.set_output(owner)
	user = WEAKREF(owner)
	on_battery_added(owner, owner.get_organ_slot(ORGAN_SLOT_STOMACH))

/obj/item/circuit_component/ipc_circuit/proc/on_uninstalled(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	user_port.set_output(null)
	user = null
	on_battery_removed(owner, battery)

/obj/item/circuit_component/ipc_circuit/proc/on_battery_added(mob/living/carbon/owner, obj/item/organ/stomach/battery/added)
	SIGNAL_HANDLER
	if(!istype(added))
		return
	battery = added
	RegisterSignal(battery, COMSIG_ORGAN_BATTERY_CHARGED, PROC_REF(battery_charged))
	battery_port.set_output(battery.charge)

/obj/item/circuit_component/ipc_circuit/proc/on_battery_removed(mob/living/carbon/owner, obj/item/organ/stomach/battery/removed)
	SIGNAL_HANDLER
	if(!istype(removed))
		return
	if(removed == battery)
		battery = null
	UnregisterSignal(removed, COMSIG_ORGAN_BATTERY_CHARGED)
	battery_port.set_output(0)

/obj/item/circuit_component/ipc_circuit/proc/battery_charged(obj/item/organ/stomach/battery/adjusted_battery, amount)
	SIGNAL_HANDLER
	battery_port.set_output(adjusted_battery.charge)
