/datum/component/radio_jamming
	//Duplicates are allowed
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Is this radio jammer active?
	var/active = FALSE
	/// The range of this radio jammer
	var/range
	/// The intensity level of this jammer
	var/intensity = 1

/datum/component/radio_jamming/Initialize(_range = 12, _intensity = RADIO_JAMMER_TRAITOR_LEVEL)
	//Set the range
	range = _range
	intensity = _intensity
	RegisterSignal(parent, COMSIG_TOGGLE_JAMMER, PROC_REF(toggle))

/datum/component/radio_jamming/Destroy(force, silent)
	disable()
	return ..()

/datum/component/radio_jamming/proc/enable()
	if (active)
		return
	active = TRUE
	GLOB.active_jammers += src

/datum/component/radio_jamming/proc/disable()
	if (!active)
		return
	active = FALSE
	GLOB.active_jammers -= src

/datum/component/radio_jamming/proc/toggle(datum/source, mob/user, silent = FALSE)
	SIGNAL_HANDLER
	//Toggle the jammer
	if (active)
		disable()
	else
		enable()
	if (!silent && user)
		to_chat(user, "<span class='notice'>You [!active ? "deactivate" : "activate"] [parent].</span>")
