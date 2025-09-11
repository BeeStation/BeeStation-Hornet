/datum/export/singulo/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Invalid object detected."

/datum/export/singulo/tesla //see above
	unit_name = "energy ball"
	export_types = list(/obj/anomaly/energy_ball)

/datum/export/singulo/tesla/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Unscheduled energy ball delivery detected."
