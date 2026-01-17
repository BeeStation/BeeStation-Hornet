/**
 * # Switch Case
 *
 * A multi-comparison component which compares an input to a variable list of inputs, routing the signal to a matching value.
 */
/obj/item/circuit_component/switch_case
	display_name = "Switch Case"
	desc = "A component that compares an input to an array of values, outputting a signal to the matching index, or a default port if no value matches."
	category = "Utility"

	/// The values to check against
	var/list/datum/port/input/case_ports = list()
	/// List of the output signals
	var/list/datum/port/output/output_signals = list()

	/// The input to compare against
	var/datum/port/input/input_port
	/// If no values matches, output the signal here
	var/datum/port/output/default_port

	/// The amount of input ports to have
	var/length = 0

	var/default_list_size = 4

	var/min_size = 1
	var/max_size = 20

	ui_buttons = list(
		"plus" = "increase",
		"minus" = "decrease"
	)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

/obj/item/circuit_component/switch_case/populate_ports()
	input_port = add_input_port("Switch", PORT_TYPE_NUMBER)
	default_port = add_output_port("Default Output", PORT_TYPE_SIGNAL)
	set_list_size(default_list_size)

/obj/item/circuit_component/switch_case/input_received(datum/port/input/port)

	for(var/i in 1 to length(case_ports))
		var/datum/port/input/case = case_ports[i]
		var/datum/port/output/output_signal = output_signals[i]
		var/value = case.value
		if(isnull(value))
			continue
		/// If we match the input signal, trigger the matching output signal, and then exit.
		if(value == input_port.value)
			output_signal.set_output(COMPONENT_SIGNAL)
			return

	/// We got through all the cases without equalling, so set the default port
	default_port.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/switch_case/save_data_to_list(list/component_data)
	. = ..()
	component_data["length"] = length

/obj/item/circuit_component/switch_case/load_data_from_list(list/component_data)
	set_list_size(component_data["length"])
	return ..()

/obj/item/circuit_component/switch_case/proc/set_list_size(new_size)
	if(new_size <= 0)
		for(var/datum/port/input/port in case_ports)
			remove_input_port(port)
		for(var/datum/port/output/port in output_signals)
			remove_output_port(port)
		case_ports = list()
		output_signals = list()
		length = 0
		return

	while(length > new_size)
		var/index = length(case_ports)
		var/entry_port = case_ports[index]
		case_ports -= entry_port
		remove_input_port(entry_port)

		index = length(output_signals)
		var/output_port = output_signals[index]
		output_signals -= output_port
		remove_output_port(output_port)

		length--

	while(length < new_size)
		length++
		var/index = length(case_ports)

		case_ports += add_input_port("Case [index+1]", PORT_TYPE_NUMBER)
		output_signals += add_output_port("Output [index+1]", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/switch_case/ui_perform_action(mob/user, action)
	switch(action)
		if("increase")
			set_list_size(min(length + 1, max_size))
		if("decrease")
			set_list_size(max(length - 1, min_size))
