/// Makes an atom a shell that is able to take in an attached circuit.
/datum/component/shell
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The circuitboard attached to this shell
	var/obj/item/integrated_circuit/attached_circuit

	/// Flags containing what this shell can do
	var/shell_flags = NONE

	/// The capacity of the shell.
	var/capacity = INFINITY

	/// A list of components that cannot be removed
	var/list/obj/item/circuit_component/unremovable_circuit_components

	var/locked = FALSE

/datum/component/shell/Initialize(unremovable_circuit_components, capacity, shell_flags)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.shell_flags = shell_flags || src.shell_flags
	src.capacity = capacity || src.capacity
	src.unremovable_circuit_components = unremovable_circuit_components

	for(var/obj/item/circuit_component/circuit_component as anything in unremovable_circuit_components)
		circuit_component.removable = FALSE

/datum/component/shell/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attack_by))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost))
	if(!(shell_flags & SHELL_FLAG_CIRCUIT_FIXED))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))
		RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_object_deconstruct))
	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		RegisterSignal(parent, COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH, PROC_REF(on_unfasten))
	RegisterSignal(parent, COMSIG_ATOM_USB_CABLE_TRY_ATTACH, PROC_REF(on_atom_usb_cable_try_attach))

/datum/component/shell/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_ATTACK_GHOST,
		COMSIG_ATOM_USB_CABLE_TRY_ATTACH,
	))

	QDEL_NULL(attached_circuit)

/datum/component/shell/Destroy(force, silent)
	QDEL_LIST(unremovable_circuit_components)
	return ..()

/datum/component/shell/proc/on_object_deconstruct()
	SIGNAL_HANDLER
	remove_circuit()

/datum/component/shell/proc/on_attack_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	if(attached_circuit)
		INVOKE_ASYNC(attached_circuit, TYPE_PROC_REF(/datum, ui_interact), ghost)

/datum/component/shell/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!attached_circuit)
		examine_text += "<span class='notice'>There is no integrated circuit attached.</span>"
		return

	examine_text += "<span class='notice'>There is an integrated circuit attached. Use a multitool to access the wiring. Use a screwdriver to remove it from [source].</span>"
	examine_text += "<span class='notice'>The cover panel to the integrated circuit is [locked? "locked" : "unlocked"].</span>"
	var/obj/item/stock_parts/cell/cell = attached_circuit.cell
	examine_text += "<span class='notice'>The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.</span>"

	if (shell_flags & SHELL_FLAG_USB_PORT)
		examine_text += "<span class='notice'>There is a <b>USB port</b> on the front.</span>"


/**
 * Called when the shell is wrenched.
 *
 * Only applies if the shell has SHELL_FLAG_REQUIRE_ANCHOR.
 * Disables the integrated circuit if unanchored, otherwise enable the circuit.
 */
/datum/component/shell/proc/on_unfasten(atom/source, anchored)
	SIGNAL_HANDLER
	attached_circuit?.on = anchored
/**
 * Called when an item hits the parent. This is the method to add the circuitboard to the component.
 */
/datum/component/shell/proc/on_attack_by(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER

	if(istype(item, /obj/item/stock_parts/cell))
		source.balloon_alert(attacker, "Can't pull cell in directly!")
		return

	if(attached_circuit?.owner_id && item == attached_circuit.owner_id.resolve())
		locked = !locked
		source.balloon_alert(attacker, "[locked? "Locked" : "Unlocked"] [source]")
		return COMPONENT_NO_AFTERATTACK

	if(attached_circuit && istype(item, /obj/item/circuit_component))
		attached_circuit.add_component(item, attacker)
		return

	if(!istype(item, /obj/item/integrated_circuit))
		return
	var/obj/item/integrated_circuit/logic_board = item
	. = COMPONENT_NO_AFTERATTACK

	if(logic_board.shell) // I'll be surprised if this ever happens
		return

	if(attached_circuit)
		source.balloon_alert(attacker, "There is already a circuitboard inside!")
		return

	if(length(logic_board.attached_components) > capacity)
		source.balloon_alert(attacker, "This is too large to fit into [parent]!")
		return

	logic_board.inserter_mind = WEAKREF(attacker.mind)
	attach_circuit(logic_board, attacker)

/datum/component/shell/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	if(locked)
		if(shell_flags & SHELL_FLAG_ALLOW_FAILURE_ACTION)
			return
		source.balloon_alert(user, "It's locked!")
		return COMPONENT_BLOCK_TOOL_ATTACK

	attached_circuit.interact(user)
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Called when a screwdriver is used on the parent. Removes the circuitboard from the component.
 */
/datum/component/shell/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!attached_circuit)
		return

	if(locked)
		if(shell_flags & SHELL_FLAG_ALLOW_FAILURE_ACTION)
			return
		source.balloon_alert(user, "It's locked!")
		return COMPONENT_BLOCK_TOOL_ATTACK

	tool.play_tool_sound(parent)
	source.balloon_alert(user, "You unscrew [attached_circuit] from [parent].")
	remove_circuit()
	return COMPONENT_BLOCK_TOOL_ATTACK

/**
 * Checks for when the circuitboard moves. If it moves, removes it from the component.
 */
/datum/component/shell/proc/on_circuit_moved(obj/item/integrated_circuit/circuit, atom/new_loc)
	SIGNAL_HANDLER
	if(new_loc != parent)
		remove_circuit()

/**
 * Checks for when the circuitboard deletes so that it can be unassigned.
 */
/datum/component/shell/proc/on_circuit_delete(datum/source)
	SIGNAL_HANDLER
	remove_circuit()

/datum/component/shell/proc/on_circuit_add_component_manually(atom/source, obj/item/circuit_component/added_comp, mob/living/user)
	SIGNAL_HANDLER

	if(locked)
		source.balloon_alert(user, "It's locked!")
		return COMPONENT_CANCEL_ADD_COMPONENT

	if(length(attached_circuit.attached_components) - length(unremovable_circuit_components) >= capacity)
		source.balloon_alert(user, "It's at maximum capacity!")
		return COMPONENT_CANCEL_ADD_COMPONENT

/**
 * Attaches a circuit to the parent. Doesn't do any checks to see for any existing circuits so that should be done beforehand.
 */
/datum/component/shell/proc/attach_circuit(obj/item/integrated_circuit/circuitboard, mob/living/user)
	if(!user.transferItemToLoc(circuitboard, parent))
		return
	locked = FALSE
	attached_circuit = circuitboard
	RegisterSignal(circuitboard, COMSIG_MOVABLE_MOVED, PROC_REF(on_circuit_moved))
	RegisterSignal(circuitboard, COMSIG_PARENT_QDELETING, PROC_REF(on_circuit_delete))
	for(var/obj/item/circuit_component/to_add as anything in unremovable_circuit_components)
		to_add.forceMove(attached_circuit)
		attached_circuit.add_component(to_add)
	RegisterSignal(circuitboard, COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY, PROC_REF(on_circuit_add_component_manually))
	attached_circuit.set_shell(parent)
	user.balloon_alert(user, "Attached [circuitboard] to [parent]")

	if(shell_flags & SHELL_FLAG_REQUIRE_ANCHOR)
		var/atom/movable/parent_atom = parent
		on_unfasten(parent_atom, parent_atom.anchored)

/**
 * Removes the circuit from the component. Doesn't do any checks to see for an existing circuit so that should be done beforehand.
 */
/datum/component/shell/proc/remove_circuit()
	attached_circuit.on = TRUE
	attached_circuit.remove_current_shell()
	UnregisterSignal(attached_circuit, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
		COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY,
	))
	if(attached_circuit.loc == parent)
		var/atom/parent_atom = parent
		attached_circuit.forceMove(parent_atom.drop_location())

	for(var/obj/item/circuit_component/to_remove as anything in unremovable_circuit_components)
		attached_circuit.remove_component(to_remove)
		to_remove.moveToNullspace()
	attached_circuit = null

/datum/component/shell/proc/on_atom_usb_cable_try_attach(atom/source, obj/item/usb_cable/usb_cable, mob/user)
	SIGNAL_HANDLER

	if (!(shell_flags & SHELL_FLAG_USB_PORT))
		source.balloon_alert(user, "This shell has no usb ports")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	if (isnull(attached_circuit))
		source.balloon_alert(user, "No circuit inside")
		return COMSIG_CANCEL_USB_CABLE_ATTACK

	usb_cable.attached_circuit = attached_circuit
	return COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT
