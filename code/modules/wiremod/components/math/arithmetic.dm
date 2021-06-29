/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/arithmetic
	display_name = "Arithmetic"
	display_desc = "General arithmetic component with arithmetic capabilities."

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/arithmetic/populate_options()
	var/static/component_options = list(
		COMP_ARITHMETIC_ADD,
		COMP_ARITHMETIC_SUBTRACT,
		COMP_ARITHMETIC_MULTIPLY,
		COMP_ARITHMETIC_DIVIDE,
		COMP_ARITHMETIC_MIN,
		COMP_ARITHMETIC_MAX,
	)
	options = component_options

/obj/item/circuit_component/arithmetic/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, PORT_TYPE_NUMBER)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/arithmetic/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/arithmetic/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/list/ports = input_ports.Copy()
	var/datum/port/input/first_port = ports[1]
	ports -= first_port
	ports -= trigger_input
	var/result = first_port.input_value

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.input_value
		if(isnull(value))
			continue

		switch(current_option)
			if(COMP_ARITHMETIC_ADD)
				result += value
			if(COMP_ARITHMETIC_SUBTRACT)
				result -= value
			if(COMP_ARITHMETIC_MULTIPLY)
				result *= value
			if(COMP_ARITHMETIC_DIVIDE)
				// Protect from div by zero errors.
				if(value == 0)
					result = null
					break
				result /= value
			if(COMP_ARITHMETIC_MAX)
				result = max(result, value)
			if(COMP_ARITHMETIC_MIN)
				result = min(result, value)

	output.set_output(result)
