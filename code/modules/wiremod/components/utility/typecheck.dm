/**
 * # Typecheck Component
 *
 * Checks the type of a value
 */
/obj/item/circuit_component/compare/typecheck
	display_name = "Typecheck"
	display_desc = "A component that checks the type of its input."

	input_port_amount = 1

GLOBAL_LIST_INIT(comp_typecheck_options, list(
	PORT_TYPE_STRING,
	PORT_TYPE_NUMBER,
	PORT_TYPE_LIST,
	PORT_TYPE_ATOM,
	COMP_TYPECHECK_MOB,
	COMP_TYPECHECK_HUMAN,
))

/obj/item/circuit_component/compare/typecheck/populate_options()
	var/static/component_options = list(
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
		COMP_TYPECHECK_MOB,
		COMP_TYPECHECK_HUMAN,
	)
	options = component_options

/obj/item/circuit_component/compare/typecheck/do_comparisons(list/ports)
	if(!length(ports))
		return
	. = FALSE

	// We're only comparing the first port/value. There shouldn't be any more.
	var/datum/port/input/input_port = ports[1]
	var/input_val = input_port.input_value
	switch(current_option)
		if(PORT_TYPE_STRING)
			return istext(input_val)
		if(PORT_TYPE_NUMBER)
			return isnum(input_val)
		if(PORT_TYPE_LIST)
			return islist(input_val)
		if(PORT_TYPE_ATOM)
			return isatom(input_val)
		if(COMP_TYPECHECK_MOB)
			return ismob(input_val)
		if(COMP_TYPECHECK_HUMAN)
			return ishuman(input_val)
