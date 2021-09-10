//This component is to create common methods for components that can function with any specified amount of inputs
/obj/item/circuit_component/arbitrary_input_amount
	display_name = "Arbitrary Input Amount"
	display_desc = "A modular component base that allows component designs to contain an arbitrary amount of inputs"

	//The type of port to use
	var/port_type = PORT_TYPE_ANY

	/// The amount of input ports to have
	var/input_port_amount = 2

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/arbitrary_input_amount/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, port_type)

	output = add_output_port("Output", port_type)

/obj/item/circuit_component/arbitrary_input_amount/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/arbitrary_input_amount/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/list/ports = input_ports.Copy()
	var/datum/port/input/first_port = ports[1]
	ports -= first_port
	ports -= trigger_input

	output.set_output(calculate_output(port,first_port,ports))

//This should return the value to be set on input_received, first_port should be the first port, and ports should be every input port except the first and signal ports
/obj/item/circuit_component/arbitrary_input_amount/proc/calculate_output(datum/port/input/port, datum/port/input/first_port, list/ports)
