/**
 * # Bitwise Component
 *
 * A component that preforms bitwise and, or and xor operations, as well as left shifts and right shifts
 * All input and output values are floored
 */
/obj/item/circuit_component/arbitrary_input_amount/bitwise
	display_name = "Bitwise"
	desc = "A component that operates on the bits of integers. Any decimal values are ignored."

	var/datum/port/input/first_input_port
	var/datum/port/input/second_input_port
	var/datum/port/input/option/options_port



/obj/item/circuit_component/arbitrary_input_amount/bitwise/populate_ports()
	first_input_port = add_input_port("Input", PORT_TYPE_NUMBER)
	second_input_port = add_input_port("Input", PORT_TYPE_NUMBER)

	output_port = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/arbitrary_input_amount/bitwise/populate_options()
	var/static/list/options = list(
		COMP_BITWISE_AND,
		COMP_BITWISE_OR,
		COMP_BITWISE_XOR,
		COMP_BITWISE_LEFTSHIFT,
		COMP_BITWISE_RIGHTSHIFT,
	)
	options_port = add_option_port("Operation", options)

/obj/item/circuit_component/arbitrary_input_amount/bitwise/calculate_output(datum/port/input/port, datum/port/input/first_port, list/ports)

	. = FLOOR(first_input_port.value, 1)
	var/value = second_input_port.value
	if(isnull(value))
		return

	value = FLOOR(value, 1)

	switch(options_port.value)
		if(COMP_BITWISE_AND)
			. &= second_input_port.value
		if(COMP_BITWISE_OR)
			. |= value
		if(COMP_BITWISE_XOR)
			. ^= value
		if(COMP_BITWISE_LEFTSHIFT)
			. = FLOOR(. * 2**value, 1) //Bitshifts are done with powers of two instead of the >> and << operators to allow negative shifts
		if(COMP_BITWISE_RIGHTSHIFT)
			. = FLOOR(. * 2**(-value), 1)
