/**
 * # Toggle Component (T Flip-Flop)
 *
 * Toggles the output from 0 to 1 to 0 after ever trigger.
 */
/obj/item/circuit_component/gate/toggle
	display_name = "Toggle Gate (T Flip-Flop)"
	desc = "Toggles the output from 0 to 1 to 0 after ever trigger."
	category = "Gates"

	/// Value Output
	var/datum/port/output/value

	/// Stores the State of the Gate
	var/current_state = FALSE

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/gate/toggle/populate_ports()
	value = add_output_port("Value", PORT_TYPE_NUMBER)

/obj/item/circuit_component/gate/toggle/input_received(datum/port/input/port)
	//Invert the Current output.
	current_state = !current_state

	//And output it.
	value.set_output(current_state)
