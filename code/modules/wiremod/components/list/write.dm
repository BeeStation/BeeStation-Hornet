/**
* Write Component
*
* Writes the given value to the specified index of a given table
**/
/obj/item/circuit_component/indexer/write
	display_name = "Write Component"
	display_desc = "A component that writes a given value to a given index in a given list. It then gives that new list back."

	/// The input ports
	var/datum/port/input/value_port

	/// The result from the output
	output_name = "New List"
	output_port_type = PORT_TYPE_LIST

/obj/item/circuit_component/indexer/write/Initialize(mapload)
	. = ..()
	value_port = add_input_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/indexer/write/Destroy()
	value_port = null
	return ..()

/obj/item/circuit_component/indexer/write/calculate_output(var/index, var/list/list_input)
	list_input[index] = value_port.input_value
	output.set_output(list_input)

