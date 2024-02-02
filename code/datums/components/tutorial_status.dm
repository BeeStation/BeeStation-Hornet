/datum/component/tutorial_status
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// What the mob's current tutorial status is, displayed in the status panel
	var/tutorial_status = ""

/datum/component/tutorial_status/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/tutorial_status/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE, PROC_REF(update_objective))
	RegisterSignal(parent, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/datum/component/tutorial_status/proc/update_objective(datum/source, objective_text)
	SIGNAL_HANDLER

	tutorial_status = objective_text

/datum/component/tutorial_status/proc/get_status_tab_item(datum/source, list/status_tab_items)
	SIGNAL_HANDLER

	if(tutorial_status)
		status_tab_items += "Tutorial Objective: " + tutorial_status
