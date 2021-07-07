/**
 * # Bitwise Component
 *
 * A component that preforms bitwise and, or and xor operations, as well as left shifts and right shifts
 * All input and output values are floored
 */
/obj/item/circuit_component/bitwise
	display_name = "Bitwise"
	display_desc = "A component that operates on the bits of integers. Any decimal values are ignored."

	/// The amount of input ports to have
	var/input_port_amount = 2

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/bitwise/populate_options()
	var/static/component_options = list(
		COMP_BITWISE_AND,
		COMP_BITWISE_OR,
		COMP_BITWISE_XOR,
		COMP_BITWISE_LEFTSHIFT,
		COMP_BITWISE_RIGHTSHIFT,
	)
	options = component_options

/obj/item/circuit_component/bitwise/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/bitwise/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/bitwise/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/result = input_ports[1].input_value
	var/second = input_ports[2].input_value

	if(isnull(result) && isnull(second))
		output.set_output(null) //Pass the null along
		return

	//I know nulls are typically treated as 0 in math operations, but I still want to be safe when it comes to bitwise stuff.
	if(isnull(result))
		result = 0
	result = round(result)

	if(isnull(second))
		second = 0
	second = round(second)

	switch(current_option)
		if(COMP_BITWISE_AND)
			result &= second
		if(COMP_BITWISE_OR)
			result |= second
		if(COMP_BITWISE_XOR)
			result ^= second
		if(COMP_BITWISE_LEFTSHIFT)
			result = round(result * 2**second)
		if(COMP_BITWISE_RIGHTSHIFT)
			result = round(result * 2**(-second))

	output.set_output(result)
