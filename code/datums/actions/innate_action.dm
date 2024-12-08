//Preset for toggled actions
/datum/action/innate
	check_flags = NONE
	/// Whether we're active or not, if we're a innate - toggle action.
	var/active = FALSE
	/// If we're a click action, the text shown on enable
	var/enable_text
	/// If we're a click action, the text shown on disable
	var/disable_text

/datum/action/innate/Trigger()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!..())
		return FALSE
	if(active)
		Deactivate()
	else
		Activate()

	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return
