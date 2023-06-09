/**
 * # Integrated Circuit Component
 *
 * A component that performs a function when given an input
 *
 * Can be attached to an integrated circuitboard, where it can then
 * be connected between other components to provide an output or to receive
 * an input. This is the base type of all components
 */
/obj/item/circuit_component
	name = COMPONENT_DEFAULT_NAME
	icon = 'icons/obj/module.dmi'
	icon_state = "component"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY

	/// The name of the component shown on the UI
	var/display_name = "Generic"

	/// The colour this circuit component appears in the UI
	var/ui_color = "blue"

	/// The integrated_circuit that this component is attached to.
	var/obj/item/integrated_circuit/parent

	/// A list that contains the outpurt ports on this component
	/// Used to connect between the ports
	var/list/datum/port/output/output_ports = list()

	/// A list that contains the components the input ports on this component
	/// Used to connect between the ports
	var/list/datum/port/input/input_ports = list()

	/// Generic trigger input for triggering this component
	var/datum/port/input/trigger_input
	var/datum/port/output/trigger_output

	/// The flags of the circuit to control basic generalised behaviour.
	var/circuit_flags = NONE

	/// Used to determine the x position of the component within the UI
	var/rel_x = 0
	/// Used to determine the y position of the component within the UI
	var/rel_y = 0

	/// The power usage whenever this component receives an input
	var/power_usage_per_input = 1

	/// Whether the component is removable or not. Only affects user UI
	var/removable = TRUE

	/// Defines which shells support this component. Only used as an informational guide, does not restrict placing these components in circuits.
	var/required_shells = null

	/// Determines the amount of space this circuit occupies in an integrated circuit.
	var/circuit_size = 1

	/// The UI buttons of this circuit component. An assoc list that has this format: "button_icon" = "action_name"
	var/ui_buttons = null

	/// How much this costs by itself. Keep this updated with /datum/design/integrated_circuit
	materials = list(/datum/material/glass = 500, /datum/material/copper = 150)

/// Called when the option ports should be set up
/obj/item/circuit_component/proc/populate_options()
	return

/// Called when the rest of the ports should be set up
/obj/item/circuit_component/proc/populate_ports()
	return

/// Extension of add_input_port. Simplifies the code to make an option port to reduce boilerplate
/obj/item/circuit_component/proc/add_option_port(name, list/list_to_use, order = 0, trigger = PROC_REF(input_received))
	return add_input_port(name, PORT_TYPE_OPTION, order = order, trigger = trigger, port_type = /datum/port/input/option, extra_args = list("possible_options" = list_to_use))

/obj/item/circuit_component/Initialize(mapload)
	. = ..()
	if(name == COMPONENT_DEFAULT_NAME)
		name = "[lowertext(display_name)] [COMPONENT_DEFAULT_NAME]"
	populate_options()
	populate_ports()
	if(circuit_flags & CIRCUIT_FLAG_INPUT_SIGNAL)
		trigger_input = add_input_port("Trigger", PORT_TYPE_SIGNAL, order = 2)
	if(circuit_flags & CIRCUIT_FLAG_OUTPUT_SIGNAL)
		trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL, order = 2)
	if(circuit_flags & CIRCUIT_FLAG_INSTANT)
		ui_color = "orange"


/obj/item/circuit_component/Destroy()
	if(parent)
		// Prevents a Destroy() recursion
		var/obj/item/integrated_circuit/old_parent = parent
		parent = null
		old_parent.remove_component(src)

	trigger_input = null
	trigger_output = null

	QDEL_LIST(output_ports)
	QDEL_LIST(input_ports)
	return ..()

/**
 * Called when a shell is registered from the component/the component is added to a circuit.
 *
 * Register all signals here on the shell.
 * Arguments:
 * * shell - Shell being registered
 */
/obj/item/circuit_component/proc/register_shell(atom/movable/shell)
	return

/**
 * Called when a shell is unregistered from the component/the component is removed from a circuit.
 *
 * Unregister all signals here on the shell.
 * Arguments:
 * * shell - Shell being unregistered
 */
/obj/item/circuit_component/proc/unregister_shell(atom/movable/shell)
	return

/**
 * Disconnects a component from other components
 *
 * Disconnects both the input and output ports of the component
 */
/obj/item/circuit_component/proc/disconnect()
	for(var/datum/port/output/port_to_disconnect as anything in output_ports)
		port_to_disconnect.disconnect_all()

	for(var/datum/port/input/port_to_disconnect as anything in input_ports)
		port_to_disconnect.disconnect_all()

/**
 * Adds an input port and returns it
 *
 * Arguments:
 * * name - The name of the input port
 * * type - The datatype it handles
 * * trigger - Whether this input port triggers an update on the component when updated.
 */
/obj/item/circuit_component/proc/add_input_port(name, type, order = 1, trigger = PROC_REF(input_received), default = null, port_type = /datum/port/input, extra_args = null)
	var/list/arguments = list(src)
	arguments += args
	if(extra_args)
		arguments += extra_args
	var/datum/port/input/input_port = new port_type(arglist(arguments))
	input_ports += input_port
	sortTim(input_ports, /proc/cmp_port_order_asc)
	if(parent)
		SStgui.update_uis(parent)
	return input_port

/**
 * Removes an input port and deletes it. This will not cleanup any references made by derivatives of the circuit component
 *
 * Arguments:
 * * input_port - The input port to remove.
 */
/obj/item/circuit_component/proc/remove_input_port(datum/port/input/input_port)
	input_ports -= input_port
	qdel(input_port)
	if(parent)
		SStgui.update_uis(parent)

/**
 * Adds an output port and returns it
 *
 * Arguments:
 * * name - The name of the output port
 * * type - The datatype it handles.
 */
/obj/item/circuit_component/proc/add_output_port(name, type, order = 1)
	var/list/arguments = list(src)
	arguments += args
	var/datum/port/output/output_port = new(arglist(arguments))
	output_ports += output_port
	sortTim(output_ports, /proc/cmp_port_order_asc)
	return output_port

/**
 * Removes an output port and deletes it. This will not cleanup any references made by derivatives of the circuit component
 *
 * Arguments:
 * * output_port - The output port to remove.
 */
/obj/item/circuit_component/proc/remove_output_port(datum/port/output/output_port)
	output_ports -= output_port
	qdel(output_port)
	if(parent)
		SStgui.update_uis(parent)


/**
 * Called whenever an input is received from one of the ports.
 *
 * Return value indicates whether the trigger was successful or not.
 * Arguments:
 * * port - Can be null. The port that sent the input
 */
/obj/item/circuit_component/proc/trigger_component(datum/port/input/port, list/return_values)
	SHOULD_NOT_SLEEP(TRUE)
	pre_input_received(port)
	if(!should_receive_input(port))
		return FALSE

	var/result
	if(port)
		var/proc_to_call = port.trigger
		if(!proc_to_call)
			return FALSE
		result = call(src, proc_to_call)(port, return_values)
	else
		result = input_received(null, , return_values)

	if(result)
		return FALSE

	if(circuit_flags & CIRCUIT_FLAG_OUTPUT_SIGNAL)
		trigger_output.set_output(COMPONENT_SIGNAL)
	return TRUE

/obj/item/circuit_component/proc/set_circuit_size(new_size)
	if(parent)
		parent.current_size -= circuit_size

	circuit_size = new_size

	if(parent)
		parent.current_size += circuit_size

/**
 * Called whether this circuit component should receive an input.
 * If this returns false, the proc that is supposed to be triggered will not be called and an output signal will not be sent.
 * This is to only return false if flow of execution should be stopped because something bad has happened (e.g. no power)
 * Returning no value in input_received() is not an issue because it means flow of execution will continue even if the component failed to execute properly.
 *
 * Return value indicates whether or not a circuit part can recieve input
 * Arguments:
 * * port - Can be null. The port that sent the input
 */
/obj/item/circuit_component/proc/should_receive_input(datum/port/input/port)
	SHOULD_NOT_SLEEP(TRUE)
	if(!parent?.on)
		return FALSE

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	if(!cell?.use(power_usage_per_input))
		return FALSE

	if((circuit_flags & CIRCUIT_FLAG_INPUT_SIGNAL) && !COMPONENT_TRIGGERED_BY(trigger_input, port))
		return FALSE

	return TRUE

/// Called before input_received and should_receive_input. Used to perform behaviour that shouldn't care whether the input should be received or not.
/obj/item/circuit_component/proc/pre_input_received(datum/port/input/port)
	SHOULD_NOT_SLEEP(TRUE)
	return

/**
 * Called from trigger_component. General component behaviour should go in this proc. This is the default proc that is called if no trigger proc is specified.
 *
 * Return value indicates that the circuit should not send an output signal.
 * Arguments:
 * * port - Can be null. The port that sent the input
 * * return_values - Only defined if the component is receiving an input due to instant execution. Contains the values to be returned once execution has stopped.
 */
/obj/item/circuit_component/proc/input_received(datum/port/input/port, list/return_values)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// Called when this component is about to be added to an integrated_circuit.
/obj/item/circuit_component/proc/add_to(obj/item/integrated_circuit/added_to)
	return TRUE

/// Called when this component is removed from an integrated_circuit.
/obj/item/circuit_component/proc/removed_from(obj/item/integrated_circuit/removed_from)
	return

/**
 * Gets the UI notices to be displayed on the CircuitInfo panel.
 *
 * Returns a list of buttons in the following format
 * list(
 *   "icon" = ICON(string)
 *   "content" = CONTENT(string)
 *   "color" = COLOR(string, not a hex)
 * )
 */
/obj/item/circuit_component/proc/get_ui_notices()
	. = list()

	if(circuit_flags & CIRCUIT_FLAG_INSTANT)
		. += create_ui_notice("Instant Execution", "red", "tachometer-alt")

	if(!removable)
		. += create_ui_notice("Unremovable", "red", "lock")

	if(length(required_shells))
		. += create_ui_notice("Supported Shells:", "green", "notes-medical")
		for(var/atom/movable/shell as anything in required_shells)
			. += create_ui_notice(initial(shell.name), "green", "plus-square")

	if(length(input_ports))
		. += create_ui_notice("Power Usage Per Input: [power_usage_per_input]", "orange", "bolt")

/**
 * Called when a special button is pressed on this component in the UI.
 *
 * Arguments:
 * * user - Interacting mob
 * * action - A string for which action is being performed. No parameters passed because it's only a button press.
 */
/obj/item/circuit_component/proc/ui_perform_action(mob/user, action)
	return

/**
 * Creates a UI notice entry to be used in get_ui_notices()
 *
 * Returns a list that can then be added to the return list in get_ui_notices()
 */
/obj/item/circuit_component/proc/create_ui_notice(content, color, icon)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	return list(list(
		"icon" = icon,
		"content" = content,
		"color" = color,
	))

/obj/item/circuit_component/ui_host(mob/user)
	if(parent)
		return parent.ui_host()
	return ..()

/**
 * Creates a table UI notice entry to be used in get_ui_notices()
 *
 * Returns a list that can then be added to the return list in get_ui_notices()
 * Used by components to list their available columns. Recommended to use at the end of get_ui_notices()
 */
/obj/item/circuit_component/proc/create_table_notices(list/entries)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = list()
	. += create_ui_notice("Available Columns:", "grey", "question-circle")


	for(var/entry in entries)
		. += create_ui_notice("Column Name: '[entry]'", "grey", "columns")

/obj/item/circuit_component/proc/register_usb_parent(atom/movable/parent)
	return

/obj/item/circuit_component/proc/unregister_usb_parent(atom/movable/parent)
	return

/obj/item/circuit_component/proc/get_material_cost()
	. = list()
	for(var/mat in materials)
		.[mat] += materials[mat]
