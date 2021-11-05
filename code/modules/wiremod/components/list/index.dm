/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/indexer/index
	display_name = "Index List"
	display_desc = "A component that returns the value of a list at a given index."

	/// The result from the output
	output_name = "Value"
	output_port_type = PORT_TYPE_ANY

/obj/item/circuit_component/indexer/index/calculate_output(var/index, var/list/list_input)

	output.set_output(list_input[index])
