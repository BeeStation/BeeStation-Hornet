/datum/component/jam_receiver
	/// Will not be blocked by intensities lower than this
	var/intensity_resist
	/// Are we currently jammed?
	var/jammed = FALSE
	/// Moved relay
	var/datum/component/moved_relay/associated_relay
	/// used to track which z array of GLOB.jam_receivers_by_z this component is in.
	var/associated_z

/datum/component/jam_receiver/Initialize(_intensity_resist = JAMMER_PROTECTION_RADIO_BASIC)
	. = ..()

	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/turf/myturf = get_turf(parent)
	associated_z = myturf?.z

	// Register this receiver. Clump them together by Z since there will be more of them then jammers.
	add_self_to_list(associated_z)

	// We need to know when our parent atoms move
	associated_relay = parent.AddComponent(/datum/component/moved_relay)

	// Register a signal when we move to see if we enter the range of a jammer
	RegisterSignal(parent, COMSIG_PARENT_MOVED_RELAY, PROC_REF(on_move))
	// See if we are starting off jammed
	check_jammed()

/datum/component/jam_receiver/Destroy(force, silent)
	. = ..()
	// Cleanup the moved relay if we need to
	var/datum/component/moved_relay/move_relay = associated_relay
	move_relay.depth --
	if (move_relay.depth == 0)
		qdel(move_relay)
		associated_relay = null
	remove_self_from_list(associated_z)

/datum/component/jam_receiver/proc/on_move(...)
	SIGNAL_HANDLER
	check_z_changed()
	check_jammed()

/datum/component/jam_receiver/proc/check_z_changed()
	var/turf/myturf = get_turf(parent)
	var/current_z = myturf?.z
	if(current_z != associated_z) // z is changed. we change this.
		remove_self_from_list(associated_z)
		add_self_to_list(current_z)
		associated_z = current_z

/datum/component/jam_receiver/proc/add_self_to_list(target_z)
	while (length(GLOB.jam_receivers_by_z) < target_z)
		GLOB.jam_receivers_by_z += list(list())
	if(target_z > 0)
		GLOB.jam_receivers_by_z[target_z] += src

/datum/component/jam_receiver/proc/remove_self_from_list(target_z)
	if(target_z > 0)
		GLOB.jam_receivers_by_z[target_z] -= src

/datum/component/jam_receiver/proc/check_jammed()
	var/atom/atom_parent = parent
	var/new_state = atom_parent.is_jammed(intensity_resist)
	set_jammed(new_state)

/datum/component/jam_receiver/proc/set_jammed(new_state)
	if (new_state == jammed)
		return
	jammed = new_state
	if (jammed)
		SEND_SIGNAL(parent, COMSIG_ATOM_JAMMED)
	else
		SEND_SIGNAL(parent, COMSIG_ATOM_UNJAMMED)
