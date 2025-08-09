/**
 * # String Trim Component
 *
 * Trims From Left or Right End of Strings
 */
/obj/item/circuit_component/trim
	display_name = "String Trim"
	desc = "A component that trims strings. Use a Negative Right Value to trim characters off the total length or a positive value to set the string length to a specific length."
	category = "String"

	//Trims characters off the left hand side of the string.
	var/datum/port/input/left_trim_input

	var/datum/port/input/string_input

	//Positive Values trims string to a total length (i.e. "string" with 3 = "str" )
	//Negative Values trims characters off the end (i.e. "string" with -1 = "strin" )
	var/datum/port/input/right_trim_input

	/// The result from the output
	var/datum/port/output/string_output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/trim/populate_ports()

	left_trim_input = add_input_port("Left Trim", PORT_TYPE_NUMBER)
	string_input = add_input_port("Input", PORT_TYPE_STRING)
	right_trim_input = add_input_port("Right Trim", PORT_TYPE_NUMBER)

	string_output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/trim/input_received(datum/port/input/port)

	var/left_trim_sanity = left_trim_input.value >= 1 ? left_trim_input.value : 1 /// Sanity Check. Must be greater than 1.

	var/right_trim_sanity = right_trim_input.value

	//We add one to make it easier to use. copytext uses the end as length+1, which results in having to set a string length of 2, to get one character out of the string.
	if(right_trim_sanity > 0)
		right_trim_sanity ++

	var/result = copytext(string_input.value, left_trim_sanity, right_trim_sanity)

	string_output.set_output(result)

