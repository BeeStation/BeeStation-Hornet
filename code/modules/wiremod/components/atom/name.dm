/**
 * # Get Name Component
 *
 * Return the name of an atom
 */
/obj/item/circuit_component/get_name
	display_name = "Get Name"
	desc = "A component that returns the name of a mob."

	/// The input port
	var/datum/port/input/entity_input

	/// The name in question
	var/datum/port/output/name_output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 5

/obj/item/circuit_component/get_name/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/get_name/populate_options()
	entity_input = add_input_port("Mob", PORT_TYPE_ATOM)

	name_output = add_output_port("Name", PORT_TYPE_STRING)

/obj/item/circuit_component/get_name/input_received(datum/port/input/port)
	var/mob/thing = entity_input.value
	var/turf/current_turf = get_turf(src)
	if(!istype(thing) || get_dist(current_turf, thing) > max_range || current_turf.get_virtual_z_level() != thing.get_virtual_z_level())
		name_output.set_output(null)
		return

	name_output.set_output(thing.name)
