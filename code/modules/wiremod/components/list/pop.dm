/***
* Pop Component
*
* Pops the last entry of a list off as if it were a stack or retrieves the first entry like a queue.
***/

/obj/item/circuit_component/pop
	display_name = "Pop Component"
	desc = "Removes the last or first entry of a list and returns it."
	category = "List"

	//The list port
	var/datum/port/input/list_port
	var/datum/port/input/option/options_port

	//The output
	var/datum/port/output/output_value
	var/datum/port/output/output_list

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/pop/populate_options()
	var/static/list/options = list(
		COMP_POP_POP,
		COMP_POP_DEQUEUE
	)
	options_port = add_option_port("Mode", options, 0, COMP_POP_POP)


/obj/item/circuit_component/pop/populate_ports()
	list_port = add_input_port("List", PORT_TYPE_LIST)
	output_list = add_output_port("New List", PORT_TYPE_LIST)
	output_value = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/pop/Destroy()
	list_port = null
	output_value = null
	output_list = null
	return ..()

/obj/item/circuit_component/pop/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/list/input_list = list_port.value
	input_list = input_list?.Copy() //Same as in the append component
	var/result = null

	if(input_list)
		switch(options_port.value)
			if(COMP_POP_POP)
				result = pop(input_list)
			if(COMP_POP_DEQUEUE)
				result = popleft(input_list)

	output_value.set_output(result)
	output_list.set_output(input_list)
