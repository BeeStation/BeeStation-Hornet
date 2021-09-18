/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/index
	display_name = "Index List"
	display_desc = "A component that returns the value of a list at a given index."

	/// The input port
	var/datum/port/input/list_port
	var/datum/port/input/index_port

	var/option_flags = NONE

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/index/populate_options()
	options = list(
		COMP_INDEX_NONE,
		COMP_INDEX_INCREMENT,
		COMP_INDEX_LOOP,
		COMP_INDEX_BOTH
	)

/obj/item/circuit_component/index/set_option(option)
	. = ..()
	switch(current_option)
		if(COMP_INDEX_NONE)
			option_flags = NONE
		if(COMP_INDEX_INCREMENT)
			option_flags = COMP_INDEX_FLAG_INCREMENT
		if(COMP_INDEX_LOOP)
			option_flags = COMP_INDEX_FLAG_LOOP
		if(COMP_INDEX_BOTH)
			option_flags = COMP_INDEX_FLAG_INCREMENT|COMP_INDEX_FLAG_LOOP

/obj/item/circuit_component/index/Initialize()
	. = ..()
	index_port = add_input_port("Index", PORT_TYPE_ANY)
	list_port = add_input_port("List", PORT_TYPE_LIST)

	output = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/index/Destroy()
	list_port = null
	index_port = null
	output = null
	return ..()

/obj/item/circuit_component/index/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/index = index_port.input_value
	var/list/list_input = list_port.input_value

	if(!islist(list_input) || isnull(index))
		output.set_output(null)
		return

	//Common operations that can change how you work with lists, require index and list_input to not be null, and so go after the check
	if(option_flags & COMP_INDEX_FLAG_INCREMENT)
		index += 1 //This makes the first index in a table functionally 0 instead of 1, useful when working with bitwise operations
	if(option_flags & COMP_INDEX_FLAG_LOOP)
		index = MODULUS(index - 1, length(list_input)) + 1 //This makes an index that overflows or underflows loop back to the start of end of the list respectively, useful for when you want to continuously loop through the list

	if(isnum(index) && (index < 1 || index > length(list_input)))
		output.set_output(null)
		return

	output.set_output(list_input[index])
