/datum/shuttle_ai_pilot
	///Can the pilot be overriden? If not external shuttle consoles
	///will be unable to control the shuttle as the ai pilot will take over.
	var/overridable = TRUE

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/proc/handle_ai_action(datum/orbital_object/shuttle/shuttle)
	return

/datum/shuttle_ai_pilot/proc/get_target_name()
	return "null"

/datum/shuttle_ai_pilot/proc/try_toggle()
	return

/datum/shuttle_ai_pilot/proc/is_active()
	return TRUE
