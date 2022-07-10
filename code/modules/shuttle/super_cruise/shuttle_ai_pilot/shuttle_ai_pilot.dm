/datum/shuttle_ai_pilot
	///Can the pilot be overriden? If not external shuttle consoles
	///will be unable to control the shuttle as the ai pilot will take over.
	var/overridable = TRUE
	///The shuttle data we are attached to
	var/datum/shuttle_data/shuttle_data

/datum/shuttle_ai_pilot/npc/process(delta_time)
	handle_ai_combat_action()

///Called every shuttle tick that the AI is in combat
/datum/shuttle_ai_pilot/proc/handle_ai_combat_action()
	return

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/proc/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	return

/datum/shuttle_ai_pilot/proc/get_target_name()
	return "null"

/datum/shuttle_ai_pilot/proc/try_toggle()
	return

/datum/shuttle_ai_pilot/proc/is_active()
	return TRUE

/datum/shuttle_ai_pilot/proc/attach_to_shuttle(datum/shuttle_data/shuttle_data)
	src.shuttle_data = shuttle_data
	RegisterSignal(shuttle_data, COMSIG_PARENT_QDELETING, .proc/on_shuttle_data_deleted)

/datum/shuttle_ai_pilot/proc/on_shuttle_data_deleted(datum/source, force)
	UnregisterSignal(shuttle_data, COMSIG_PARENT_QDELETING)
	shuttle_data = null
	qdel(src)
