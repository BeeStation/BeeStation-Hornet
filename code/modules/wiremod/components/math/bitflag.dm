/*

bitflag component

This is a component that checks if a specific bit in a number is a one or zero.
Its best use is to combine it with the bitwise component to put multiple booleans in one number.

*/


/obj/item/circuit_component/compare/bitflag
	display_name = "Bitflag"
	desc = "A component that can determine if a specified bit of a number is on or off."

	//default compare ports aren't used
	input_port_amount = 0

	//The number containing the flags
	var/datum/port/input/input
	//The bit that needs to be checked
	var/datum/port/input/bit

/obj/item/circuit_component/compare/bitflag/populate_custom_ports()
	input = add_input_port("Input", PORT_TYPE_NUMBER)
	bit = add_input_port("Bit", PORT_TYPE_NUMBER)

/obj/item/circuit_component/compare/bitflag/Destroy()
	input = null
	bit = null
	return ..()

/obj/item/circuit_component/compare/bitflag/do_comparisons(list/ports)

	var/value = round(input.value)
	var/bit_value = round(bit.value)

	return (value >> bit_value) & 1



