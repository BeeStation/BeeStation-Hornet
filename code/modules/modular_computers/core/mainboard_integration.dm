/// Allows movables to have mainboard (ModPC) integration.
/datum/component/modular_computer_integration

	/// The mainboard that handles all the logic. You know, the whole point of the integration?
	var/obj/item/mainboard/MB

	var/static/list/allowed_types = list(
		/obj/item/modular_computer,
		/obj/machinery/modular_computer
	)

/// This component is effectively like carving out a space inside whatever object "parent" is for a ModPC to fit.
///
/// If we don't include a mainboard to immediately put into that space its OK, the space is still there.
/datum/component/modular_computer_integration/Initialize(
	obj/item/mainboard/included_mb = null,
	create_mb = TRUE,
	datum/callback/install_hardware = null,
	datum/callback/install_software = null,
	max_hardware_size = 0,
	max_bays = 0
)
	if(!is_type_in_list(parent, allowed_types))
		return COMPONENT_INCOMPATIBLE

	if(!istype(included_mb))
		if(!create_mb && (!isnull(install_hardware) || isnull(install_software)))
			stack_trace("Created a modular_computer_integration for [parent], and explicity declined to include a mainboard. But you included hardware and software creation functions, what gives?")
		else if(!create_mb)
			return // do nothing
		included_mb = new (parent)
	else
		included_mb.forceMove(parent)

	if(!isnull(max_hardware_size))
		included_mb.max_hardware_w_class = max_hardware_size
	if(!isnull(max_bays))
		included_mb.max_bays = max_bays

	if(!can_insert_mb(included_mb, null))
		return COMPONENT_INCOMPATIBLE
	insert_mb(included_mb, install_hardware, install_software)

/datum/component/modular_computer_integration/proc/can_insert_mb(obj/item/mainboard/target, mob/user)
	for(var/obj/item/computer_hardware/component in target.all_components)
		if(!component.can_install_component(target, user))
			return FALSE
	return TRUE

/// Actually for real install the mainboard. Register Signals too while you're at it
/datum/component/modular_computer_integration/proc/insert_mb(obj/item/mainboard/target, datum/callback/install_hardware = null, datum/callback/install_software = null)
	MB = target
	MB.physical_holder = parent

	// Register the signals
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_AI, PROC_REF(on_attack_general))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_general))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(on_attack_general))
	RegisterSignal(parent, COMSIG_ATOM_ON_EMAG, PROC_REF(on_emag))
	RegisterSignal(parent, COMSIG_ATOM_SHOULD_EMAG, PROC_REF(should_emag))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_AltClick))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	RegisterSignal(MB, COMSIG_ATOM_UPDATE_ICON, PROC_REF(self_update_icon))

	var/obj/item/modular_computer/I = parent
	if(istype(I))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(on_attack_obj))
		I.mainboard = MB

	var/obj/machinery/modular_computer/M = parent
	if(istype(M))
		RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
		M.mainboard = MB

	// Handle installing hardware as needed
	if(install_hardware)
		install_hardware.Invoke(MB)
	if(install_software)
		var/obj/item/computer_hardware/hard_drive/hard_drive = MB.all_components[MC_HDD]
		if(istype(hard_drive))
			install_software.Invoke(hard_drive)
		else // sanity check
			stack_trace("Called insert_mb on [parent] with install_software argument, but no hard_drive was found.")

	// Start processing now
	START_PROCESSING(SSobj, MB)

/datum/component/modular_computer_integration/proc/delete_mb()
	STOP_PROCESSING(SSobj, MB)
	MB.turn_off(loud = FALSE)
	MB.physical_holder = null
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_AI,
		COMSIG_ATOM_ATTACK_GHOST,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_ON_EMAG,
		COMSIG_ATOM_SHOULD_EMAG,
		COMSIG_CLICK_ALT,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_PARENT_EXAMINE
	))
	UnregisterSignal(MB, COMSIG_ATOM_UPDATE_ICON)

	var/obj/item/modular_computer/I = parent
	if(istype(I))
		UnregisterSignal(parent, list(
			COMSIG_ITEM_ATTACK,
			COMSIG_ITEM_ATTACK_OBJ
		))
		I.mainboard = null

	var/obj/machinery/modular_computer/M = parent
	if(istype(M))
		UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER))
		M.mainboard = null

	QDEL_NULL(MB)

// Here be all the special interaction signal handlers
// NOTE: All of these assume that mainboard IS NOT NULL
// IF IT IS NULL, HOW ARE THESE PROCS BEING CALLED THEN? WHOS TRIGGERING THE SIGNALS?

/// When the mainboard's parent was AltClicked
/datum/component/modular_computer_integration/proc/on_AltClick(datum/source, mob/user)
	SIGNAL_HANDLER

	if(issilicon(user) || !user.canUseTopic(parent, BE_CLOSE))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	var/obj/item/computer_hardware/id_slot/slot1 = MB.all_components[MC_ID_AUTH]
	var/obj/item/computer_hardware/id_slot/slot2 = MB.all_components[MC_ID_MODIFY]
	if(slot2?.try_eject(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(slot1?.try_eject(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// When the mainboard's parent was used to attack a mob
/datum/component/modular_computer_integration/proc/on_attack(datum/source, mob/target, mob/living/user)
	SIGNAL_HANDLER

	// Send to programs for processing - this should go LAST
	// Used to implement the physical scanner.
	for(var/datum/computer_file/program/thread in (MB.idle_threads + MB.active_program))
		if(thread.use_attack && thread.attack(target, user))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/// When the mainboard's parent was attacked by a ghost
/datum/component/modular_computer_integration/proc/on_attack_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER

	if(MB.enabled)
		INVOKE_ASYNC(MB, TYPE_PROC_REF(/datum, ui_interact), ghost)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	// TODO: Fix this to make it ASYNC
	// if(IsAdminGhost(ghost))
	// 	var/response = alert(ghost, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
	// 	if(response == "Yes")
	// 		MB.turn_on(ghost)

/// When the mawinboard's parent was attacked by silicons, or unarmed hands
/datum/component/modular_computer_integration/proc/on_attack_general(datum/source, mob/user)
	SIGNAL_HANDLER

	if(MB.enabled)
		INVOKE_ASYNC(MB, TYPE_PROC_REF(/datum, ui_interact), user)
	else
		MB.turn_on(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// When the mainboard's parent was used to attack an object
/datum/component/modular_computer_integration/proc/on_attack_obj(datum/source, obj/O, mob/user)
	SIGNAL_HANDLER

	// Send to programs for processing - this should go LAST
	// Used to implement the physical scanner.
	for(var/datum/computer_file/program/thread in (MB.idle_threads + MB.active_program))
		if(thread.use_attack_obj && thread.attack_obj(O, user))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/// When the mainboard's parent is attacked
/datum/component/modular_computer_integration/proc/on_attackby(datum/source, obj/item/I, mob/living/user, params)
	SIGNAL_HANDLER

	// Check for ID first
	if(istype(I, /obj/item/card/id)) // This is not inside of a try_insert() because we want to control the ordering of insertions
		var/obj/item/computer_hardware/id_slot/slot1 = MB.all_components[MC_ID_AUTH]
		if(istype(slot1) && slot1.try_insert(I))
			return TRUE

		var/obj/item/computer_hardware/id_slot/slot2 = MB.all_components[MC_ID_MODIFY]
		if(istype(slot2) && slot2.try_insert(I))
			return TRUE

		return FALSE

	if(iscash(I)) // This is not inside of a try_insert() because we want the money to go into our primary card's bank account
		var/obj/item/computer_hardware/id_slot/id_slot = MB.all_components[MC_ID_AUTH]
		// Check to see if we have an ID inside, and a valid input for money
		var/obj/item/card/id/id = id_slot?.GetID_parent()
		if(istype(id))
			INVOKE_ASYNC(id, TYPE_PROC_REF(/atom, attackby), I, user) //id.attackby(I, user) // If we do, try and put that attacking object in
			return TRUE

	// Try to insert items into any of the components
	for(var/component_name in MB.all_components)
		var/obj/item/computer_hardware/comp = MB.all_components[component_name]
		if(comp.try_insert(I, user))
			ui_update()
			return TRUE

	return FALSE

/datum/component/modular_computer_integration/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += MB.internal_parts_examine(user)

/datum/component/modular_computer_integration/proc/on_screwdriver_act(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	MB.screwdriver_act(user, I)

/// This one passes events the opposite direction to whatever our parent is
/datum/component/modular_computer_integration/proc/self_update_icon(datum/source)
	SIGNAL_HANDLER

	var/atom/movable/AM = parent
	AM.update_icon()

/// Return TRUE if we shouldn't be able to emag the mainboard's parent
/datum/component/modular_computer_integration/proc/should_emag(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!MB.enabled)
		to_chat(user, "<span class='warning'>Nothing happens. You'd need to turn \the [parent] on first.</span>")
		return TRUE
	return FALSE

/// When the mainboard's parent is emagged
/datum/component/modular_computer_integration/proc/on_emag(datum/source, mob/user)
	SIGNAL_HANDLER

	MB.emag_act_parent(user)
	return TRUE

