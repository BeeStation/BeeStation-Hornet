/*
* Moddable Assembly
*
* A shell that is also an assembly
*/

/obj/item/assembly/modular
	name = "modular assembly"
	desc = "a modified remote signalling device with its wiring removed and adapted for integrated circuitry."
	icon_state = "wiremod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	securable = FALSE //This item should only ever be used as an assembly and the shell datum uses screwdriver_act, might as well make it permanently unsecured

	var/datum/port/output/pulse_out

/obj/item/assembly/modular/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/assembly()
	), SHELL_CAPACITY_SMALL)

/obj/item/assembly/modular/Destroy()
	pulse_out = null
	return ..()

/obj/item/assembly/modular/activate()
	. = ..()
	if(!. || !pulse_out)
		return FALSE
	pulse_out.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/assembly
	display_name = "Moddable Assembly"
	display_desc = "Connects to an attached assembly"
	var/datum/port/input/pulse_in
	var/datum/port/output/pulse_out

/obj/item/circuit_component/assembly/Initialize(mapload)
	. = ..()
	pulse_in = add_input_port("Pulse", PORT_TYPE_SIGNAL)
	pulse_out = add_output_port("Pulsed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly/Destroy()
	pulse_in = null
	pulse_out = null
	return ..()

/obj/item/circuit_component/assembly/register_shell(atom/movable/shell)
	var/obj/item/assembly/modular/s = shell
	s.pulse_out = pulse_out

/obj/item/circuit_component/assembly/unregister_shell(atom/movable/shell)
	var/obj/item/assembly/modular/s = shell
	s.pulse_out = null

/obj/item/circuit_component/assembly/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/obj/item/assembly/modular/shell = parent.shell
	if(!shell)
		return

	shell.pulse(FALSE)

