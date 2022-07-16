/datum/objective/protect_object
	name = "protect object"
	var/obj/protect_target

/datum/objective/protect_object/proc/set_protect_target(obj/O)
	protect_target = O
	update_explanation_text()

/datum/objective/protect_object/update_explanation_text()
	. = ..()
	if(protect_target)
		explanation_text = "Protect \the [protect_target] at all costs."
	else
		explanation_text = "Free objective."

/datum/objective/protect_object/check_completion()
	return !QDELETED(protect_target) || ..()
