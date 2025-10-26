/datum/export/singulo //failsafe in case someone decides to ship a live singularity to CentCom without the corresponding bounty
	cost = 1
	unit_name = "singularity"
	export_types = list(/obj/anomaly/singularity)
	include_subtypes = FALSE

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

//artisanal exports for the mom and pops
/datum/export/soap
	cost = CARGO_CRATE_VALUE * 0.15
	unit_name = "soap"
	export_types = list(/obj/item/soap)

/datum/export/soap/homemade
	cost = CARGO_CRATE_VALUE * 0.15
	unit_name = "artisanal soap"
	export_types = list(/obj/item/soap/homemade)

/datum/export/candle
	cost = CARGO_CRATE_VALUE * 0.05
	unit_name = "candle"
	export_types = list(/obj/item/candle)
