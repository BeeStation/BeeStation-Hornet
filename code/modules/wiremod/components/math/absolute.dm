/**
 * # Abs Component
 *
 * This component outputs the absolute value of the input.
 */
/obj/item/circuit_component/abs
	display_name = "Absolute"
	desc = "A component that outputs the absolute value of the input."
	category = "Math"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/result
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/abs/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_NUMBER)

	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/abs/input_received(datum/port/input/port)
	result.set_output(abs(input_port.value))

