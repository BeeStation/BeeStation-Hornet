/**
 * # Compare Component
 *
 * Abstract component to build conditional components
 */
/obj/item/circuit_component/compare
	display_name = "Compare"
	category = "Abstract"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The trigger for the true/false signals
	var/datum/port/input/compare

	/// Signals sent on compare
	var/datum/port/output/true
	var/datum/port/output/false

	/// The result from the output
	var/datum/port/output/result

	var/list/datum/port/input/compare_ports = list()

/obj/item/circuit_component/compare/populate_ports()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		compare_ports += add_input_port(letter, PORT_TYPE_ANY)

	populate_custom_ports()
	compare = add_input_port("Compare", PORT_TYPE_SIGNAL)

	true = add_output_port("True", PORT_TYPE_SIGNAL)
	false = add_output_port("False", PORT_TYPE_SIGNAL)
	result = add_output_port("Result", PORT_TYPE_NUMBER)

/**
 * Used by derivatives to load their own ports in for custom use.
 */
/obj/item/circuit_component/compare/proc/populate_custom_ports()
	return

/obj/item/circuit_component/compare/input_received(datum/port/input/port)

	var/logic_result = do_comparisons(compare_ports)
	if(COMPONENT_TRIGGERED_BY(compare, port))
		if(logic_result)
			true.set_output(COMPONENT_SIGNAL)
		else
			false.set_output(COMPONENT_SIGNAL)
	result.set_output(logic_result)

/// Do the comparisons and return a result
/obj/item/circuit_component/compare/proc/do_comparisons(list/ports)
	return FALSE
