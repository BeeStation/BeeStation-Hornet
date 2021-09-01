/**
 * # Arithmetic Component
 *
 * General arithmetic unit with add/sub/mult/divide capabilities
 * This one only works with numbers.
 */
/obj/item/circuit_component/arbitrary_input_amount/arithmetic
	display_name = "Arithmetic"
	display_desc = "General arithmetic component with arithmetic capabilities."

	//The type of port
	port_type = PORT_TYPE_NUMBER

	/// The amount of input ports to have
	input_port_amount = 4

/obj/item/circuit_component/arbitrary_input_amount/arithmetic/populate_options()
	options = list(
		COMP_ARITHMETIC_ADD,
		COMP_ARITHMETIC_SUBTRACT,
		COMP_ARITHMETIC_MULTIPLY,
		COMP_ARITHMETIC_DIVIDE,
		COMP_ARITHMETIC_MODULO,
		COMP_ARITHMETIC_MIN,
		COMP_ARITHMETIC_MAX,
	)

/obj/item/circuit_component/arbitrary_input_amount/arithmetic/calculate_output(datum/port/input/port, datum/port/input/first_port, list/ports)

	. = first_port.input_value

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.input_value
		if(isnull(value))
			continue

		switch(current_option)
			if(COMP_ARITHMETIC_ADD)
				. += value
			if(COMP_ARITHMETIC_SUBTRACT)
				. -= value
			if(COMP_ARITHMETIC_MULTIPLY)
				. *= value
			if(COMP_ARITHMETIC_DIVIDE)
				// Protect from div by zero errors.
				if(value == 0)
					. = null
					break
				. /= value
			if(COMP_ARITHMETIC_MODULO)
				//Another protect from divide by zero.
				if(value == 0)
					. = null
					break
				//BYOND's built in modulus operator doesn't work well with decimals, so I'm using this method instead
				var/multiples = FLOOR(. / value, 1)
				. -= multiples * value
			if(COMP_ARITHMETIC_MAX)
				. = max(., value)
			if(COMP_ARITHMETIC_MIN)
				. = min(., value)
