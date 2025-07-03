/datum/component/radio_jamming
	//Duplicates are allowed
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Is this radio jammer active?
	var/active = FALSE
	/// The range of this radio jammer
	var/range
	/// The intensity level of this jammer
	var/intensity = 1
	/// Moved relay
	var/datum/component/moved_relay/associated_relay

/datum/component/radio_jamming/Initialize(_range = 12, _intensity = RADIO_JAMMER_TRAITOR_LEVEL)

	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	//Set the range
	range = _range
	intensity = _intensity
	RegisterSignal(parent, COMSIG_TOGGLE_JAMMER, PROC_REF(toggle))

	// We need to know when our parent atoms move
	associated_relay = parent.AddComponent(/datum/component/moved_relay)

/datum/component/radio_jamming/Destroy(force, silent)
	disable()
	// Cleanup the moved relay if we need to
	var/datum/component/moved_relay/move_relay = associated_relay
	move_relay.depth --
	if (move_relay.depth == 0)
		qdel(move_relay)
		associated_relay = null
	return ..()

/datum/component/radio_jamming/proc/enable()
	if (active)
		return
	active = TRUE
	GLOB.active_jammers += src
	RegisterSignal(parent, COMSIG_PARENT_MOVED_RELAY, PROC_REF(check_move_jams))
	check_move_jams()

/datum/component/radio_jamming/proc/disable()
	if (!active)
		return
	active = FALSE
	GLOB.active_jammers -= src
	UnregisterSignal(parent, COMSIG_PARENT_MOVED_RELAY)
	var/turf/jammer_turf = get_turf(parent)
	//Early return here. A runtime usually occurs in unit testing enviroments otherwise
	if(0 < jammer_turf.z || jammer_turf.z < length(GLOB.jam_receivers_by_z))
		return
	for (var/datum/component/jam_receiver/receiver in GLOB.jam_receivers_by_z[jammer_turf.z])
		receiver.check_jammed()

/datum/component/radio_jamming/proc/toggle(datum/source, mob/user, silent = FALSE)
	SIGNAL_HANDLER
	//Toggle the jammer
	if (active)
		disable()
	else
		enable()
	if (!silent && user)
		to_chat(user, span_notice("You [!active ? "deactivate" : "activate"] [parent]."))

/datum/component/radio_jamming/proc/check_move_jams(...)
	SIGNAL_HANDLER
	if (!GLOB.jam_receivers_by_z)
		return
	var/turf/jammer_turf = get_turf(parent)
	if (length(GLOB.jam_receivers_by_z) < jammer_turf.z || jammer_turf.z == 0)
		return
	for (var/datum/component/jam_receiver/receiver in GLOB.jam_receivers_by_z[jammer_turf.z])
		//Check to see if the jammer is strong enough to block this signal
		if (receiver.intensity_resist > intensity)
			continue
		var/turf/position = get_turf(receiver.parent)
		if(position?.get_virtual_z_level() == jammer_turf.get_virtual_z_level() && (get_dist(position, jammer_turf) <= range))
			receiver.set_jammed(TRUE)
		// If the receiver was jammed but is no longer jammed, check all in range
		else if (receiver.jammed)
			receiver.check_jammed()
