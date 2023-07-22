/obj/structure/scanner_gate_shell
	name = "circuit scanner gate"
	desc = "A gate able to perform mid-depth scans on any organisms who pass under it."
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate"
	var/scanline_timer

	var/locked = FALSE

	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 1
	light_on = FALSE

/obj/structure/scanner_gate_shell/Initialize()
	. = ..()
	set_scanline("passive")

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/scanner_gate()
	), SHELL_CAPACITY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/scanner_gate_shell/wrench_act(mob/living/user, obj/item/tool)
	if(locked)
		return
	anchored = !anchored
	tool.play_tool_sound(src)
	balloon_alert(user, "You [anchored?"secure":"unsecure"] [src].")
	return TRUE

/obj/structure/scanner_gate_shell/proc/on_entered(atom/movable/AM)
	SIGNAL_HANDLER
	set_scanline("scanning", 10)
	SEND_SIGNAL(src, COMSIG_SCANGATE_SHELL_PASS, AM)

/obj/structure/scanner_gate_shell/proc/set_scanline(type, duration)
	cut_overlays()
	deltimer(scanline_timer)
	add_overlay(type)
	if(duration)
		scanline_timer = addtimer(CALLBACK(src, PROC_REF(set_scanline), "passive"), duration, TIMER_STOPPABLE)

/obj/item/circuit_component/scanner_gate
	display_name = "Scanner Gate"
	desc = "A gate able to perform mid-depth scans on any object that pass through it."

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/output/scanned

	var/obj/structure/scanner_gate_shell/attached_gate

/obj/item/circuit_component/scanner_gate/populate_ports()
	scanned = add_output_port("Scanned Object", PORT_TYPE_ATOM)

/obj/item/circuit_component/scanner_gate/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/scanner_gate_shell))
		attached_gate = shell
		RegisterSignal(attached_gate, COMSIG_SCANGATE_SHELL_PASS, PROC_REF(on_trigger))
		RegisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED, PROC_REF(on_set_locked))
		attached_gate.locked = parent.locked

/obj/item/circuit_component/scanner_gate/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_gate, COMSIG_SCANGATE_SHELL_PASS)
	if(attached_gate)
		attached_gate.locked = FALSE
		UnregisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED)
	attached_gate = null
	return ..()

/obj/item/circuit_component/scanner_gate/proc/on_trigger(datum/source, atom/movable/passed)
	SIGNAL_HANDLER
	scanned.set_output(passed)
	trigger_output.set_output(COMPONENT_SIGNAL)

/**
 * Locks the attached bot when the circuit is locked.
 *
 * Arguments:
 * * new_value - A boolean that determines if the circuit is locked or not.
 **/
/obj/item/circuit_component/scanner_gate/proc/on_set_locked(datum/source, new_value)
	attached_gate.locked = new_value
