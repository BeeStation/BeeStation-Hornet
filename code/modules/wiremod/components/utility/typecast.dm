/**
 * # Typecast Component
 *
 * Checks the type of a value
 */
/obj/item/circuit_component/compare/typecast
	display_name = "Typecast"
	display_desc = "A component that checks and casts the type of its input."

	input_port_amount = 1

/obj/item/circuit_component/compare/typecast/populate_options()
	var/static/component_options = list(
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
		COMP_TYPECAST_MOB,
		COMP_TYPECAST_HUMAN,
	)
	options = component_options

/obj/item/circuit_component/compare/typecast/Initialize(mapload)
	. = ..()
	set_option(current_option)

/obj/item/circuit_component/compare/typecast/set_option(option)
	var/static/list/options_to_port_types = list(
		COMP_TYPECAST_MOB = PORT_TYPE_ATOM,
		COMP_TYPECAST_HUMAN = PORT_TYPE_ATOM,
	)

	//Change our results port to our correct type
	var/current_result_type = options_to_port_types[option] ? options_to_port_types[option] : option
	if(result.datatype != current_result_type)
		result.set_datatype(current_result_type)

	. = ..()

/obj/item/circuit_component/compare/typecast/do_comparisons(list/ports)

	if(!length(ports))
		return
	. = FALSE

	// We're only comparing the first port/value. There shouldn't be any more.
	var/datum/port/input/input_port = ports[1]
	var/input_val = input_port.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			return istext(input_val) ? input_val : null
		if(PORT_TYPE_NUMBER)
			return isnum(input_val) ? input_val : null
		if(PORT_TYPE_LIST)
			return islist(input_val) ? input_val : null
		if(PORT_TYPE_ATOM)
			return isatom(input_val) ? input_val : null
		if(COMP_TYPECAST_MOB)
			return ismob(input_val) ? input_val : null
		if(COMP_TYPECAST_HUMAN)
			return ishuman(input_val) ? input_val : null
