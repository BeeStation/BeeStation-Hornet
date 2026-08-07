/***
* Indexer Component
*
* An abstract component to provide some common functionality for component at access a specified index of a list
***/
/obj/item/circuit_component/indexer
	display_name = "Indexer Component"
	desc = "A component base used to access specified indexes of a list; it doesn't work by itself."
	category = "Abstract"

	/// The input port
	var/datum/port/input/list_port
	var/datum/port/input/index_port
	var/datum/port/input/option/option_port

	// Changes functionality based on current option
	var/option_flags = NONE

	/// The result from the output
	var/datum/port/output/output
	var/output_name = "Output"
	var/output_port_type = PORT_TYPE_ANY

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL


/obj/item/circuit_component/indexer/populate_options()
	var/static/list/index_options = list(
		COMP_INDEXER_NONE,
		COMP_INDEXER_INCREMENT,
		COMP_INDEXER_LOOP,
		COMP_INDEXER_BOTH
	)
	option_port = add_option_port("Options", index_options)


/obj/item/circuit_component/indexer/populate_ports()
	list_port = add_input_port("List", PORT_TYPE_LIST)
	index_port = add_input_port("Index", PORT_TYPE_NUMBER)

	output = add_output_port(output_name, output_port_type)

/obj/item/circuit_component/indexer/Destroy()
	list_port = null
	index_port = null
	output = null
	return ..()

/obj/item/circuit_component/indexer/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/index = index_port.value
	var/list/list_input = list_port.value
	list_input = list_input?.Copy() //input_value of an input port isn't typecasted to a list, so it doesn't reconize Copy() until you put it in a typed var

	if(isnull(index))
		index = 0
	if(!islist(list_input))
		output.set_output(null)
		return

	//Common operations that can change how you work with lists, require index and list_input to not be null, and so go after the check
	if(option_flags & COMP_INDEXER_FLAG_INCREMENT)
		index += 1 //This makes the first index in a table functionally 0 instead of 1, useful when working with bitwise operations
	if(option_flags & COMP_INDEXER_FLAG_LOOP)
		index = MODULUS(index - 1, length(list_input)) + 1 //This makes an index that overflows or underflows loop back to the start of end of the list respectively, useful for when you want to continuously loop through the list

	if(isnum(index) && (index < 1 || index > length(list_input)))
		output.set_output(null)
		return

	calculate_output(index, list_input)

/obj/item/circuit_component/indexer/proc/calculate_output(index, list/list_input)
	return
