/**
 * # Round Component
 *
 * This component can round, floor, and ceil number inputs.
 *
 */

/obj/item/circuit_component/round
	display_name = "Round"
	display_desc = "A component capable of cutting off messy decimal values off a number."

	/// The input port
	var/datum/port/input/input

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/round/populate_options()
	options = list(
		COMP_ROUND_ROUND,
		COMP_ROUND_FLOOR,
		COMP_ROUND_CEIL,
	)

/obj/item/circuit_component/round/Initialize()
	. = ..()

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

	var/value = input.input_value
	if(isnull(value))
		output.set_output(null) //Pass the null along
		return

	switch(current_option)
		if(COMP_ROUND_ROUND)
			value = round(value,1)
		if(COMP_ROUND_FLOOR)
			value = FLOOR(value,1)
		if(COMP_ROUND_CEIL)
			value = CEILING(value,1)

	output.set_output(value)
