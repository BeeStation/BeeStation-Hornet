///public
///Sets the AI pilot of the shuttle to an AI pilot datum, handling
/datum/orbital_object/shuttle/proc/set_pilot(datum/shuttle_ai_pilot/pilot)
	if(ai_pilot)
		UnregisterSignal(ai_pilot, COMSIG_PARENT_QDELETING)
	ai_pilot = pilot
	if(ai_pilot)
		RegisterSignal(ai_pilot, COMSIG_PARENT_QDELETING, .proc/on_pilot_deleted)

///private
///Signal handler that handles dereferencing the ai_pilot when it is deleted
/datum/orbital_object/shuttle/proc/on_pilot_deleted(datum/source, force)
	PRIVATE_PROC(TRUE)
	UnregisterSignal(ai_pilot, COMSIG_PARENT_QDELETING)
	ai_pilot = null

///Public
///Attempts to override the current AI pilot
/datum/orbital_object/shuttle/proc/try_override_pilot(forced = FALSE)
	if(!ai_pilot)
		return TRUE
	if(!ai_pilot.overridable)
		return FALSE
	qdel(ai_pilot)
	SEND_SIGNAL(src, COMSIG_ORBITAL_BODY_MESSAGE, "Autopilot disabled.")
	return TRUE
