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

/datum/component/music_listener/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/music_listener/proc/parent_moved()
	SIGNAL_HANDLER
	// Update our listener
	var/atom/movable/parent_atom = parent
	var/turf/location = get_turf(parent_atom)
	if (location)
		panel.update_listener_position(location.x, location.y, location.z)
	else
		panel.update_listener_position(0, 0, 0)
