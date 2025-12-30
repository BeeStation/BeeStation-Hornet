/**
* Write Component
*
* Writes the given value to the specified index of a given table
**/
/obj/item/circuit_component/indexer/write
	display_name = "Write Component"
	desc = "A component that writes a given value to a given index in a given list. It then gives that new list back."
	category = "List"

	/// The input ports
	var/datum/port/input/value_port

	/// The result from the output
	output_name = "New List"
	output_port_type = PORT_TYPE_LIST

/obj/item/circuit_component/indexer/write/populate_ports()
	. = ..()
	value_port = add_input_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/indexer/write/Destroy()
	value_port = null
	return ..()

/obj/item/circuit_component/indexer/write/calculate_output(index, list/list_input)
	list_input[index] = islist(value_port.value) ? null : value_port.value
	output.set_output(list_input)

