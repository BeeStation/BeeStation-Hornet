/**
 * # Set/Reset Component (RS Latch)
 *
 * Sets the output to 1 on a set, and clears it to 0 on reset.
 */
/obj/item/circuit_component/gate/set_reset
	display_name = "Set/Reset Component (SR Latch)"
	desc = "Sets the output to 1 on a set, and clears it to 0 on reset."
	category = "Gates"

	/// Set the output
	var/datum/port/input/set_input
	/// Reset the output
	var/datum/port/input/reset_input

	/// Value Output
	var/datum/port/output/value

	/// Stores the State of the Gate
	var/current_state = FALSE

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/gate/set_reset/populate_ports()

	set_input = add_input_port("Set", PORT_TYPE_SIGNAL)
	reset_input = add_input_port("Reset", PORT_TYPE_SIGNAL)

	value = add_output_port("Value", PORT_TYPE_NUMBER)

/obj/item/circuit_component/gate/set_reset/input_received(datum/port/input/port)

	if(COMPONENT_TRIGGERED_BY(port, set_input))
		current_state = TRUE

	if(COMPONENT_TRIGGERED_BY(port, reset_input))
		current_state = FALSE

	value.set_output(current_state)
