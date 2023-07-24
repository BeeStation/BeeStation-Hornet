/**
 * # Thought Listener Component
 *
 * Allows user to input a string.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/thought_listener
	display_name = "Thought Listener"
	desc = "A component that allows the user to input a string using their mind. Requires a BCI shell."

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/input_name
	var/datum/port/input/input_desc

	var/datum/port/output/output
	var/datum/port/output/failure

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/cyberimp/bci/bci
	var/ready = TRUE

/obj/item/circuit_component/thought_listener/populate_ports()
	input_name = add_input_port("Input Name", PORT_TYPE_STRING)
	input_desc = add_input_port("Input Description", PORT_TYPE_STRING)
	output = add_output_port("Recieved Thought", PORT_TYPE_STRING)
	trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	failure = add_output_port("On Failure", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/thought_listener/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/thought_listener/unregister_shell(atom/movable/shell)
	bci = null

/obj/item/circuit_component/thought_listener/input_received(datum/port/input/port)
	if(!ready)
		failure.set_output(COMPONENT_SIGNAL)
		return

	if(!bci)
		failure.set_output(COMPONENT_SIGNAL)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client)
		failure.set_output(COMPONENT_SIGNAL)
		return

	INVOKE_ASYNC(src, PROC_REF(thought_listen), owner)
	ready = FALSE

/obj/item/circuit_component/thought_listener/proc/thought_listen(mob/living/owner)
	var/message = tgui_input_text(owner, input_desc.value ? input_desc.value : "", input_name.value ? input_name.value : "Thought Listener", "")
	output.set_output(message)
	trigger_output.set_output(COMPONENT_SIGNAL)
	ready = TRUE
