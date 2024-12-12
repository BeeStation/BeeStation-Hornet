/**
 * Attaches to a mob, associates with a TGUI panel
 * and will inform the TGUI panel about updates to the listener's positon.
 */
/datum/component/music_listener
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE
	var/datum/tgui_panel/panel

/datum/component/music_listener/Initialize(datum/tgui_panel/panel)
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.panel = panel

/datum/component/music_listener/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(parent_logout))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_DEAF), PROC_REF(lose_hearing))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_DEAF), PROC_REF(gain_hearing))
	panel.set_can_hear(!HAS_TRAIT(parent, TRAIT_DEAF))
	// Send over initial positional data
	parent_moved()

/datum/component/music_listener/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_DEAF))
	UnregisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_DEAF))

/datum/component/music_listener/proc/parent_moved()
	SIGNAL_HANDLER
	// We are no longer needed
	if (!panel.needs_spatial_audio)
		qdel(src)
		return
	// Update our listener
	var/atom/movable/parent_atom = parent
	var/turf/location = get_turf(parent_atom)
	if (location)
		panel.update_listener_position(location.x, location.y, location.z)
	else
		panel.update_listener_position(0, 0, 0)

/datum/component/music_listener/proc/parent_logout()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/music_listener/proc/lose_hearing()
	SIGNAL_HANDLER
	panel.set_can_hear(FALSE)

/datum/component/music_listener/proc/gain_hearing()
	SIGNAL_HANDLER
	panel.set_can_hear(TRUE)
