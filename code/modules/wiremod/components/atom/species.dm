/**
 * # Get Species Component
 *
 * Return the species of a mob
 */
/obj/item/circuit_component/species
	display_name = "Get Species"
	display_desc = "A component that returns the species of its input."

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/species/Initialize(mapload)
	. = ..()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	output = add_output_port("Species", PORT_TYPE_STRING)

/obj/item/circuit_component/species/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/species/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/human = input_port.input_value
	if(!istype(human) || !human.has_dna())
		output.set_output(null)
		return

	output.set_output(human.dna.species.name)
