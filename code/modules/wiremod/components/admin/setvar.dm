/**
 * # Set Variable Component
 *
 * A component that sets a variable on an object
 */
/obj/item/circuit_component/set_variable
	display_name = "Set Variable"
	desc = "A component that sets a variable on an object."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// Entity to set variable of
	var/datum/port/input/entity

	/// Variable name
	var/datum/port/input/variable_name

	/// New value to set the variable name to.
	var/datum/port/input/new_value


/obj/item/circuit_component/set_variable/Initialize()
	. = ..()
	entity = add_input_port("Target", PORT_TYPE_ATOM)
	variable_name = add_input_port("Variable Name", PORT_TYPE_STRING)
	new_value = add_input_port("New Value", PORT_TYPE_ANY)

/obj/item/circuit_component/set_variable/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return
	var/atom/object = entity.value
	var/var_name = variable_name.value
	if(!var_name || !object)
		return

	object.vv_edit_var(var_name, new_value.value)
