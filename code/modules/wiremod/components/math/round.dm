/**
 * # Round Component
 *
 * This component can round, floor, and ceil number inputs.
 *
 */

/obj/item/circuit_component/round
	display_name = "Round"
	desc = "A component capable of cutting off messy decimal values off a number."
	category = "Math"

	/// The input port
	var/datum/port/input/input
	var/datum/port/input/option/options_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/round/populate_options()
	var/static/list/options = list(
		COMP_ROUND_ROUND,
		COMP_ROUND_FLOOR,
		COMP_ROUND_CEIL,
	)
	options_port = add_option_port("Operation", options)

/obj/item/circuit_component/round/populate_ports()

	input = add_input_port("Input", PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/round/Destroy()
	input = null
	output = null
	return ..()

/obj/item/circuit_component/round/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/value = input.value
	if(isnull(value))
		output.set_output(null) //Pass the null along
		return

	switch(options_port.value)
		if(COMP_ROUND_ROUND)
			value = round(value,1)
		if(COMP_ROUND_FLOOR)
			value = FLOOR(value,1)
		if(COMP_ROUND_CEIL)
			value = CEILING(value,1)

	output.set_output(value)
