/**
 * # Scanner
 *
 * A handheld device which scans things.
 */
/obj/item/scanner
	name = "scanner"
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small_hook"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_range = FALSE

/obj/item/scanner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/scanner()
	), SHELL_CAPACITY_SMALL)

/obj/item/circuit_component/scanner
	display_name = "Scanner"
	display_desc = "Used to receive inputs from the scanner shell. Use the shell on something to scan it."

	/// Atom that was scanned.
	var/datum/port/output/scanned
	/// Called when scanner is used.
	var/datum/port/output/signal

/obj/item/circuit_component/scanner/Initialize(mapload)
	. = ..()
	scanned = add_output_port("Scanned", PORT_TYPE_ATOM)
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/scanner/Destroy()
	scanned = null
	signal = null
	return ..()

/obj/item/circuit_component/scanner/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_PRE_ATTACK, PROC_REF(send_trigger))

/obj/item/circuit_component/scanner/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ITEM_PRE_ATTACK)

/**
 * Called when the shell item is used on something.
 */
/obj/item/circuit_component/scanner/proc/send_trigger(atom/source, atom/target, mob/user)
	SIGNAL_HANDLER
	target.balloon_alert(user, "Scanned [target].")
	playsound(user, get_sfx("terminal_type"), 25, FALSE)
	. = COMPONENT_NO_ATTACK
	scanned.set_output(target)
	signal.set_output(COMPONENT_SIGNAL)
