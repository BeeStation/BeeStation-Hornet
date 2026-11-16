/**
 * # Is Null
 *
 * Checks if an input is null.
 */
/obj/item/circuit_component/is_null
	display_name = "Is Null"
	desc = "A component that checks if an input is null."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The value to null check
	var/datum/port/input/value_to_null_check

	/// Output on null
	var/datum/port/output/is_null

	/// Output on Not null
	var/datum/port/output/is_not_null

/obj/item/circuit_component/is_null/populate_ports()
	value_to_null_check = add_input_port("Input", PORT_TYPE_ANY, trigger = null)
	is_null = add_output_port("Is Null", PORT_TYPE_SIGNAL)
	is_not_null = add_output_port("Not Null", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/is_null/input_received(datum/port/input/port)
	if(isnull(value_to_null_check.value))
		is_null.set_output(COMPONENT_SIGNAL)
	else
		is_not_null.set_output(COMPONENT_SIGNAL)
