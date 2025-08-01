/**
 * # Concatenate Component
 *
 * General string concatenation component. Puts strings together.
 */
/obj/item/circuit_component/concat
	display_name = "Concatenate"
	desc = "A component that combines strings."
	category = "String"

	/// The inputs to concatenate
	var/list/datum/port/input/entry_ports = list()

	/// The result from the output
	var/datum/port/output/output

	/// The amount of input ports to have
	var/length = 0

	var/default_list_size = 4

	var/min_size = 1
	var/max_size = 20

	ui_buttons = list(
		"plus" = "increase",
		"minus" = "decrease"
	)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/concat/populate_ports()
	set_list_size(default_list_size)
	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/concat/input_received(datum/port/input/port)

	var/result = ""
	for(var/datum/port/input/input_port as anything in entry_ports)
		var/value = input_port.value
		if(isnull(value))
			continue

		result += "[value]"

	output.set_output(result)

/obj/item/circuit_component/concat/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/concat/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])
	return ..()

/obj/item/circuit_component/concat/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port in entry_ports)
			remove_input_port(port)
		entry_ports = list()
		length = 0
		return

	while(length > new_size)
		var/index = length(entry_ports)
		var/entry_port = entry_ports[index]
		entry_ports -= entry_port
		remove_input_port(entry_port)
		length--

	while(length < new_size)
		length++
		var/index = length(input_ports)
		if(trigger_input)
			index -= 1
		entry_ports += add_input_port("Index [index+1]", PORT_TYPE_STRING)

/obj/item/circuit_component/concat/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_list_size(min(length + 1, max_size))
		if("decrease")
			set_list_size(max(length - 1, min_size))
