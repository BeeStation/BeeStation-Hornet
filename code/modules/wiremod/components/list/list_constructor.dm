/**
* List Constructor Component
*
* This component allows the construction of a list from other data
**/

/obj/item/circuit_component/arbitrary_input_amount/list_constructor
	display_name = "List Constructor"
	desc = "A component that creates a list from given inputs"

	power_usage_per_input = 5 //Large cost

	//Takes any inputs, makes a list out of them
	input_port_type = PORT_TYPE_ANY
	output_port_type = PORT_TYPE_LIST

	//This can be changed to whatever value is wanted
	input_port_amount = 4

/obj/item/circuit_component/arbitrary_input_amount/list_constructor/calculate_output(datum/port/input/port, datum/port/input/first_port, list/ports)
	. = list()
	ports.Insert(1, first_port)
	for(var/datum/port/input/input_port as anything in ports)
		. += islist(input_port.value) ? null : input_port.value
