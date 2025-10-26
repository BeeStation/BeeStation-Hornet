/**
 * # Clock Component
 *
 * Fires every tick of the circuit timer SS
 */
/obj/item/circuit_component/clock
	display_name = "Clock"
	desc = "A component that repeatedly fires. Divider slows the clock down by a multiple of the tick rate. For example, a clock divider of 2 will fire twice as slowly. Must be greater than 1."
	category = "Utility"

	/// Whether the clock is on or not
	var/datum/port/input/on

	/// Clock Divider (Triggers on every X clocks. A divider of 2 would be 2x COMP_CLOCK_DELAY, 3 would be 3x COMP_CLOCK_DELAY)
	var/datum/port/input/divider_port

	/// The signal from this clock component
	var/datum/port/output/signal

	/// Sanity Checked Divider Value
	var/target_divider = 1

	/// Current Divider Count
	var/current_divider = 0

/obj/item/circuit_component/clock/get_ui_notices()
	. = ..()
	. += create_ui_notice("Base Clock Interval: [DisplayTimeText(COMP_CLOCK_DELAY)]", "blue", "clock")


/obj/item/circuit_component/clock/populate_ports()
	on = add_input_port("On", PORT_TYPE_NUMBER)

	divider_port = add_input_port("Clock Divider", PORT_TYPE_NUMBER)

	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/clock/input_received(datum/port/input/port)

	target_divider = max(target_divider, 1)

	if(on.value)
		start_process()
	else
		stop_process()

/obj/item/circuit_component/clock/Destroy()
	stop_process()
	return ..()

/obj/item/circuit_component/clock/process(delta_time)
	current_divider += 1
	if(current_divider >= target_divider)
		signal.set_output(COMPONENT_SIGNAL)
		current_divider = 0

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts ticking to send signals between periods of time
 */
/obj/item/circuit_component/clock/proc/start_process()
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Signals stop getting sent.
 */
/obj/item/circuit_component/clock/proc/stop_process()
	STOP_PROCESSING(SSclock_component, src)
