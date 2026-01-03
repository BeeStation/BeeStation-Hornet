/***
* Append Component
*
* Appends a value onto a list, increasing its size by 1
***/
/obj/item/circuit_component/append
	display_name = "Append Component"
	desc = "A component that appends a value to a list."
	category = "List"

	//Input ports
	var/datum/port/input/list_port
	var/datum/port/input/value_port

	//Output port
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/append/populate_ports()
	list_port = add_input_port("List", PORT_TYPE_LIST)
	value_port = add_input_port("Value", PORT_TYPE_ANY)

	output = add_output_port("New List", PORT_TYPE_LIST)

/obj/item/circuit_component/append/Destroy()
	list_port = null
	value_port = null
	output = null
	return ..()

/obj/item/circuit_component/append/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/value = value_port.value
	var/list/input_list = list_port.value
	input_list = input_list?.Copy() //input_value of an input port isn't typecasted to a list, so it doesn't reconize Copy() until you put it in a typed var

	//appending a null value onto a list is a reasonable thing to do if the goal is only to change the length of the list, therefore, isnull(value) isn't checked
	if(isnull(input_list))
		output.set_output(null)
		return

	if(input_list.len < COMPONENT_MAXIMUM_LIST_SIZE && !islist(value)) //Prevents lists from growing too large and prevents recursive lists
		input_list += value
	output.set_output(input_list)


