/datum/export/singulo //failsafe in case someone decides to ship a live singularity to CentCom without the corresponding bounty
	cost = 1
	unit_name = "singularity"
	export_types = list(
		/obj/anomaly/singularity = TRUE,
	)
	include_subtypes = FALSE

/datum/export/singulo/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Invalid object detected."

/datum/export/singulo/tesla //see above
	unit_name = "energy ball"
	export_types = list(
		/obj/anomaly/energy_ball = TRUE,
	)

/datum/export/singulo/tesla/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Unscheduled energy ball delivery detected."
