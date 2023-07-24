/***
* List Length Constructor
*
* Constructs an empty list with specified length
***/


/obj/item/circuit_component/list_length_constructor
	display_name = "List Length Constructor"
	desc = "A varient of the list constructor that makes an emtpy list with a specified length"

	power_usage_per_input = 10 //B I G cost

	//A specified length
	var/datum/port/input/input_length

	//The constructed list
	var/datum/port/output/output_port

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/list_length_constructor/populate_ports()
	input_length = add_input_port("Length", PORT_TYPE_NUMBER)
	output_port = add_output_port("Output", PORT_TYPE_LIST)

/obj/item/circuit_component/list_length_constructor/Destroy()
	input_length = null
	output_port = null

	return ..()

/obj/item/circuit_component/list_length_constructor/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/length = input_length.value
	var/list/new_list = null
	if(length > COMPONENT_MAXIMUM_LIST_SIZE)
		length = COMPONENT_MAXIMUM_LIST_SIZE
	if(length >= 0)
		new_list = new /list(length)
	output_port.set_output(new_list)
