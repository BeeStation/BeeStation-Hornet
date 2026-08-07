/**
 * # No Operation
 *
 * A block which does nothing except pass a trigger through. Useful for gathering lots of signals into one bundle.
 * Includes a comment line so you can comment about the signal path
 */
/obj/item/circuit_component/noop
	display_name = "No Operation Component"
	desc = "Use this to gather multiple output signals into one for organization. The comment string does nothing."
	category = "Utility"

	power_usage_per_input = 0 //This does nothing, so consumes no power.
	circuit_size = 0 //This does nothing, it should take no space.

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL | CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/comment // A comment String for the part. Does Nothing


/obj/item/circuit_component/noop/populate_ports()

	comment = add_input_port("Comment", PORT_TYPE_STRING)
