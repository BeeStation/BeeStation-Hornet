/**
 * # Pull Component
 *
 * Tells the shell to start pulling on a designated atom. Only works on movable shells.
 */
/obj/item/circuit_component/pull
	display_name = "Start Pulling"
	display_desc = "A component that can force the shell to pull entities. Only works for drone shells."

	/// Frequency input
	var/datum/port/input/target
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/pull/Initialize(mapload)
	. = ..()
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/pull/Destroy()
	target = null
	return ..()

/obj/item/circuit_component/pull/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/atom/target_atom = target.input_value
	if(!target_atom)
		debug_world_log("clickednontarget!")
		return

	var/mob/living/circuit_drone/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_atom) > 1 || shell.z != target_atom.z)
		return

	shell.start_pulling(target_atom)
