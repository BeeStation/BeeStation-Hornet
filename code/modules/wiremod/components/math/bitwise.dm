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
	var/input_port_amount =  2

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
	. = ..() //This is the reason why this isn't a subclass of arithmetic
	if(.)
		return

	var/list/ports = input_ports.Copy()
	var/datum/port/input/first_port = ports[1]
	ports -= first_port
	ports -= trigger_input
	var/result = round(first_port.input_value)

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.input_value
		if(isnull(value))
			continue

		value = round(value)

		switch(current_option)
			if(COMP_BITWISE_AND)
				result &= value
			if(COMP_BITWISE_OR)
				result |= value
			if(COMP_BITWISE_XOR)
				result ^= value
			if(COMP_BITWISE_LEFTSHIFT)
				result = round(result * 2**value) //Bitshifts are done with powers of two instead of the >> and << operators to allow negative shifts
			if(COMP_BITWISE_RIGHTSHIFT)
				result = round(result * 2**(-value))

	output.set_output(result)
