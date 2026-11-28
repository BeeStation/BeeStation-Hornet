/**
 * # For-Each Component
 *
 * Iterates through a stored list
 */
/obj/item/circuit_component/foreach
	display_name = "For Each"
	desc = "Iterates through a stored list"
	category = "List"

	/// The list to iterate.
	var/datum/port/input/input_list_port
	/// When this input fires, store the list and reset the iterations
	var/datum/port/input/store_list_port

	/// Iterate input
	var/datum/port/input/iterate_port

	/// Value Output
	var/datum/port/output/value_port
	/// Index Output
	var/datum/port/output/index_port
	/// Length of List Output
	var/datum/port/output/length_port

	/// Trigger Output
	var/datum/port/output/on_iterate
	/// Rollover Output
	var/datum/port/output/end_of_list

	/// Stores the Count of the Iterator
	var/list/list_to_iterate = list()
	var/current_index = 1

/obj/item/circuit_component/foreach/get_ui_notices()
	. = ..()
	. += create_ui_notice("Store List: Stores the list to iterate, and outputs the first item in the list.", "blue")
	. += create_ui_notice("Iterate: Iterates to the next item in the list.", "blue")
	. += create_ui_notice("End of List: Triggers after entire list has been iterated.", "teal")

/obj/item/circuit_component/foreach/populate_ports()

	/// No need to trigger on the list changing, only do that when we store the list
	input_list_port = add_input_port("List To Iterate", PORT_TYPE_LIST, trigger = null)
	store_list_port = add_input_port("Store List", PORT_TYPE_SIGNAL)

	/// The Port which iterates forward
	iterate_port = add_input_port("Iterate", PORT_TYPE_SIGNAL)

	/// The item in the list
	value_port = add_output_port("Value", PORT_TYPE_ANY)
	/// The Index of the item in the list
	index_port = add_output_port("Index", PORT_TYPE_NUMBER)
	/// The total length of the list
	length_port = add_output_port("Length", PORT_TYPE_NUMBER)

	/// Triggered for every update of value/index.
	on_iterate = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	/// Triggered when we hit the end of the list
	end_of_list = add_output_port("End of List", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/foreach/input_received(datum/port/input/port)

	/// If we are triggered by storing the list to start...
	if( COMPONENT_TRIGGERED_BY(port, store_list_port) )

		//input_value of an input port isn't typecasted to a list, so it doesn't recognize Copy() until you put it in a typed var
		var/list/cast_list = input_list_port.value
		cast_list = cast_list?.Copy()

		/// Make sure we have a list to store
		if(!length(cast_list))
			/// Bad list, nothing to output.
			value_port.set_output(null)
			index_port.set_output(null)
			length_port.set_output(null)
			return

		list_to_iterate = cast_list
		current_index = 1 /// reset counter to initial index

		//If there's something to output in the list, output it.
		value_port.set_output(cast_list[current_index])
		index_port.set_output(current_index)
		length_port.set_output(length(cast_list))
		on_iterate.set_output(COMPONENT_SIGNAL)
		/// No matter what happens, always return from this trigger.
		return

	/// Everything beyond is just iteration stuff. Early return guard.
	if( !COMPONENT_TRIGGERED_BY(port, iterate_port) )
		return

	/// Make sure we have a list to iterate
	if(!length(list_to_iterate))
		value_port.set_output(null)
		index_port.set_output(null)
		return

	current_index += 1 /// Increment the current index

	if( current_index > length(list_to_iterate) )
		/// we are at the end, set the outputs to null and trigger the end of list output.
		value_port.set_output(null)
		index_port.set_output(null)
		end_of_list.set_output(COMPONENT_SIGNAL)
		current_index = length(list_to_iterate) /// Make sure the current_index doesn't overflow by resetting it to the current size.
		return /// All done.

	value_port.set_output(list_to_iterate[current_index])
	index_port.set_output(current_index)
	on_iterate.set_output(COMPONENT_SIGNAL)
