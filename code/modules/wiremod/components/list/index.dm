/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/index
	display_name = "Index List"
	desc = "A component that returns the value of a list at a given index."
	category = "List"

	/// The input port
	var/datum/port/input/list_port

	/// The Input indices
	var/list/datum/port/input/index_ports = list()
	/// The result from the output
	var/list/datum/port/output/indexed_outputs = list()

	var/length = 0

	var/default_list_size = 1

	var/min_size = 1
	var/max_size = 20

	ui_buttons = list(
		"plus" = "increase",
		"minus" = "decrease"
	)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/index/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/index/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])

	return ..()

/obj/item/circuit_component/index/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port in index_ports)
			remove_input_port(port)
		for(var/datum/port/output/port in indexed_outputs)
			remove_output_port(port)
		index_ports = list()
		indexed_outputs = list()
		length = 0
		return

	while(length > new_size)
		var/index = length(index_ports)
		var/entry_port = index_ports[index]
		index_ports -= entry_port
		remove_input_port(entry_port)

		index = length(indexed_outputs)
		var/output_port = indexed_outputs[index]
		indexed_outputs -= output_port
		remove_output_port(output_port)

		length--

	while(length < new_size)
		length++
		var/index = length(input_ports)
		if(list_port)
			index -= 1
		if(trigger_input)
			index -= 1

		index_ports += add_input_port("Index [index+1]", PORT_TYPE_NUMBER)
		indexed_outputs += add_output_port("Value [index+1]", PORT_TYPE_ANY)

/obj/item/circuit_component/index/populate_ports()
	list_port = add_input_port("List", PORT_TYPE_LIST)
	set_list_size(default_list_size)

/obj/item/circuit_component/index/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_list_size(min(length + 1, max_size))
		if("decrease")
			set_list_size(max(length - 1, min_size))

/obj/item/circuit_component/index/input_received(datum/port/input/port)

	for(var/i in 1 to length(index_ports))
		var/datum/port/input/index_port = index_ports[i]
		var/datum/port/output/output_port = indexed_outputs[i]

		var/index = index_port.value
		var/list/list_input = list_port.value

		if(!islist(list_input))
			output_port.set_output(null)
			continue

		if(isnum(index) && (index < 1 || index > length(list_input)))
			output_port.set_output(null)
			continue

		output_port.set_output(list_input[index])
