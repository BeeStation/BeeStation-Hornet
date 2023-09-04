/datum/component/jam_receiver
	/// Will not be blocked by intensities lower than this
	var/intensity_resist
	/// Are we currently jammed?
	var/jammed = FALSE
	/// Moved relay
	var/datum/component/moved_relay/associated_relay

/datum/component/jam_receiver/Initialize(_intensity_resist = JAMMER_PROTECTION_RADIO_BASIC)
	. = ..()

	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/parent_atom = parent
	// Register this receiver. Clump them together by Z since there will be more of them then jammers.
	while (length(GLOB.jam_receivers_by_z) < parent_atom.z)
		GLOB.jam_receivers_by_z += list(list())

	GLOB.jam_receivers_by_z[parent_atom.z] += src

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
		move_relay.RemoveComponent()
		associated_relay = null

/datum/component/jam_receiver/proc/on_move(...)
	SIGNAL_HANDLER
	check_jammed()

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
