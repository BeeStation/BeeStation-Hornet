/*
It's like a regular ol' straight pipe, but you can turn it on and off.
*/

/obj/machinery/atmospherics/components/binary/valve
	icon_state = "mvalve_map-3"

	name = "manual valve"
	desc = "A pipe with a valve that can be used to disable flow of gas through it."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_OPEN //Intentionally no allow_silicon flag
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	var/frequency = 0
	var/id = null

	var/valve_type = "m" //lets us have a nice, clean, OOP update_icon_nopipes()

	construction_type = /obj/item/pipe/binary
	pipe_state = "mvalve"

	var/switching = FALSE

/obj/machinery/atmospherics/components/binary/valve/Destroy()
	//Should only happen on extreme circumstances
	if(on)
		//Let's give presumably now-severed pipenets a chance to scramble for what's happening at next SSair fire()
		if(parents[1])
			parents[1].update = PIPENET_UPDATE_STATUS_RECONCILE_NEEDED
		if(parents[2])
			parents[2].update = PIPENET_UPDATE_STATUS_RECONCILE_NEEDED
	. = ..()

/obj/machinery/atmospherics/components/binary/valve/update_icon_nopipes(animation = FALSE)
	normalize_cardinal_directions()
	if(animation)
		flick("[valve_type]valve_[on][!on]-[set_overlay_offset(piping_layer)]", src)
	icon_state = "[valve_type]valve_[on ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/**
 * Called by finish_interact(), switch between open and closed, reconcile the air between two pipelines
 */
/obj/machinery/atmospherics/components/binary/valve/proc/set_open(to_open)
	if(on == to_open)
		return
	SEND_SIGNAL(src, COMSIG_VALVE_SET_OPEN, to_open)
	. = on
	on = to_open
	if(on)
		update_icon_nopipes()
		update_parents()
		var/datum/pipeline/parent1 = parents[1]
		parent1.reconcile_air()
		investigate_log("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	else
		update_icon_nopipes()
		investigate_log("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/components/binary/valve/interact(mob/user)
	add_fingerprint(usr)
	if(switching)
		return
	update_icon_nopipes(TRUE)
	switching = TRUE
	addtimer(CALLBACK(src, .proc/finish_interact), 10)

/obj/machinery/atmospherics/components/binary/valve/proc/finish_interact()
	set_open(!on)
	switching = FALSE


/obj/machinery/atmospherics/components/binary/valve/digital // can be controlled by AI
	icon_state = "dvalve_map-3"

	name = "digital valve"
	desc = "A digitally controlled valve."
	valve_type = "d"
	pipe_state = "dvalve"

	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OPEN_SILICON

/obj/machinery/atmospherics/components/binary/valve/digital/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/digital_valve))

/obj/item/circuit_component/digital_valve
	display_name = "Digital Valve"
	display_desc = "The interface for communicating with a digital valve."

	var/obj/machinery/atmospherics/components/binary/valve/digital/attached_valve

	/// Opens the digital valve
	var/datum/port/input/open
	/// Closes the digital valve
	var/datum/port/input/close

	/// Whether the valve is currently open
	var/datum/port/output/is_open
	/// Sent when the valve is opened
	var/datum/port/output/opened
	/// Sent when the valve is closed
	var/datum/port/output/closed

/obj/item/circuit_component/digital_valve/Initialize(mapload)
	. = ..()
	open = add_input_port("Open", PORT_TYPE_SIGNAL)
	close = add_input_port("Close", PORT_TYPE_SIGNAL)

	is_open = add_output_port("Is Open", PORT_TYPE_NUMBER)
	opened = add_output_port("Opened", PORT_TYPE_SIGNAL)
	closed = add_output_port("Closed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/digital_valve/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/valve/digital))
		attached_valve = shell
		RegisterSignal(attached_valve, COMSIG_VALVE_SET_OPEN, .proc/handle_valve_toggled)

/obj/item/circuit_component/digital_valve/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(attached_valve, COMSIG_VALVE_SET_OPEN)
	attached_valve = null
	return ..()

/obj/item/circuit_component/digital_valve/proc/handle_valve_toggled(datum/source, on)
	is_open.set_output(on)
	if(on)
		opened.set_output(COMPONENT_SIGNAL)
	else
		closed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/digital_valve/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!attached_valve)
		return

	if(COMPONENT_TRIGGERED_BY(open, port) && !attached_valve.on)
		attached_valve.set_open(TRUE)
	if(COMPONENT_TRIGGERED_BY(close, port) && attached_valve.on)
		attached_valve.set_open(FALSE)


/obj/machinery/atmospherics/components/binary/valve/digital/update_icon_nopipes(animation)
	if(!is_operational)
		normalize_cardinal_directions()
		icon_state = "dvalve_nopower-[set_overlay_offset(piping_layer)]"
		return
	..()

/obj/machinery/atmospherics/components/binary/valve/layer2
	piping_layer = 2
	icon_state = "mvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/layer4
	piping_layer = 4
	icon_state = "mvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/on/layer2
	piping_layer = 2
	icon_state = "mvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/on/layer4
	piping_layer = 4
	icon_state = "mvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/digital/layer2
	piping_layer = 2
	icon_state = "dvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/digital/layer4
	piping_layer = 4
	icon_state = "dvalve_map-4"

/obj/machinery/atmospherics/components/binary/valve/digital/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer2
	piping_layer = 2
	icon_state = "dvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer4
	piping_layer = 4
	icon_state = "dvalve_map-4"
