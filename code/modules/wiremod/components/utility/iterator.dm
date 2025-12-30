/**
 * # Iterator Component
 *
 * Iterates through a range of numbers when the iterate input is triggered.
 */
/obj/item/circuit_component/iterator
	display_name = "Iterator"
	desc = "Iterates through a range of numbers"
	category = "Utility"

	/// The Initial Value the Loop will start at
	var/datum/port/input/initial_value
	/// The Final Value the Loop will rollover at
	var/datum/port/input/final_value
	/// The Step the internal variable will take on each Iterate trigger
	var/datum/port/input/step_value

	/// Resets the loop to the initial value.
	var/datum/port/input/reset_input
	/// Triggers the variable to iterate.
	var/datum/port/input/step_input

	/// Value Output
	var/datum/port/output/value

	/// Trigger Output
	var/datum/port/output/on_triggered
	/// Rollover Output
	var/datum/port/output/on_rollover

	/// Stores the Count of the Iterator
	var/current_value = 0

/obj/item/circuit_component/iterator/populate_ports()

	initial_value = add_input_port("Initial Value", PORT_TYPE_NUMBER)
	final_value = add_input_port("Final Value", PORT_TYPE_NUMBER)

	/// No need to trigger when the step value changes.
	step_value = add_input_port("Step Value", PORT_TYPE_NUMBER, trigger = null)

	reset_input = add_input_port("Reset", PORT_TYPE_SIGNAL)
	step_input = add_input_port("Step", PORT_TYPE_SIGNAL)

	value = add_output_port("Value", PORT_TYPE_NUMBER)
	on_triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	on_rollover = add_output_port("Rollover", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/iterator/input_received(datum/port/input/port)

	/// If we don't have any values for the iterator, or
	/// if the initial value and final values are equivalent
	if(initial_value.value == final_value.value || !step_value.value)
		current_value = initial_value.value
		value.set_output(current_value)
		return

	/// Depending on the bounds of the iterator, we need to either iterate in a positive direction or a negative direction.
	/// To ensure that we iterate in the correct direction, take the abs of the iterator, and either add or subtract depending on
	/// direction of iteration. This way silly spacemen can't screw up the sign on the iterator.
	var/iterate_positive = abs(step_value.value)

	/// Used to determine if we increment or decrement, and bounds
	var/pos_iter = initial_value.value < final_value.value

	/// when we update the initial and final values, we need to ensure the current value gets bounded to the new range..
	/// If we are iterating upwards, the current value can't be less than the initial value.
	/// If we are iterating upwards, the current value can't be greater than the final value.
	/// If we are iterating downwards, the current value can't be greater than the initial value.
	/// If we are iterating downwards, the current value can't be less than the final value.
	/// Truncate it to the new bound, and silently update it without the rollover signal.
	if(COMPONENT_TRIGGERED_BY(port, initial_value) || COMPONENT_TRIGGERED_BY(port, final_value))
		if(pos_iter)
			if(current_value < initial_value.value)
				current_value = initial_value.value
				value.set_output(current_value)
			if(current_value > final_value.value)
				current_value = final_value.value
				value.set_output(current_value)
		else
			if(current_value > initial_value.value)
				current_value = initial_value.value
				value.set_output(current_value)
			if(current_value < final_value.value)
				current_value = final_value.value
				value.set_output(current_value)
		return


	/// Reset the Internal Value if the initialization port triggers
	if(COMPONENT_TRIGGERED_BY(port, reset_input))
		current_value = initial_value.value
		value.set_output(current_value)
		on_triggered.set_output(COMPONENT_SIGNAL)
		return

	/// Let's get iterating
	if(COMPONENT_TRIGGERED_BY(port, step_input))
		if(pos_iter)
			current_value += iterate_positive
			/// We've gone over the final value, return to the initial
			if(current_value > final_value.value)
				current_value = initial_value.value
				/// and send the rollover signal
				on_rollover.set_output(COMPONENT_SIGNAL)
		else
			/// Going negative, so subtract instead of negative.
			current_value -= iterate_positive
			if(current_value < final_value.value)
				current_value = initial_value.value
				/// and send the rollover signal
				on_rollover.set_output(COMPONENT_SIGNAL)

		value.set_output(current_value)
		on_triggered.set_output(COMPONENT_SIGNAL)
		return
