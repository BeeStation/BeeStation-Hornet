/**
 * # Get relative coords Component
 *
 * Returns relative coordinates to target atom.
 */
/obj/item/circuit_component/relative_coords
	display_name = "Get relative coords"
	desc = "A component that returns relative coordinates to target. Requires line of sight."
	category = "Entity"

	/// Atom that we are trying to get relative coordinates to.
	var/datum/port/input/target

	/// Signals
	var/datum/port/input/calculate
	var/datum/port/output/calculated
	var/datum/port/output/failed

	/// Relative coordinates to target.
	var/datum/port/output/relative_x
	var/datum/port/output/relative_y

/obj/item/circuit_component/relative_coords/populate_ports()
	target = add_input_port("Target Atom", PORT_TYPE_ATOM)
	calculate = add_input_port("Calculate", PORT_TYPE_SIGNAL)

	relative_x = add_output_port("Relative X", PORT_TYPE_NUMBER)
	relative_y = add_output_port("Relative Y", PORT_TYPE_NUMBER)

	calculated = add_output_port("Calculated", PORT_TYPE_SIGNAL)
	failed = add_output_port("Failed", PORT_TYPE_SIGNAL)



/obj/item/circuit_component/relative_coords/input_received(datum/port/input/port, list/return_values)
	if(COMPONENT_TRIGGERED_BY(calculate, port))
		var/atom/target_atom = get_turf(target.value)
		var/atom/source = get_turf(parent)
		if(can_see(parent, target_atom)) // requires line of sight
			relative_x.set_output(target_atom.x - source.x)
			relative_y.set_output(target_atom.y - source.y)
			calculated.set_output(COMPONENT_SIGNAL)
		else
			failed.set_output(COMPONENT_SIGNAL)



