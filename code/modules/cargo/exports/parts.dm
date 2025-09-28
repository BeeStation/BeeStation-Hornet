// Circuit boards, spare parts, etc.

/datum/export/solar/assembly
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "solar panel assembly"
	export_types = list(/obj/item/solar_assembly)

/datum/export/solar/tracker_board
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "solar tracker board"
	export_types = list(/obj/item/electronics/tracker)

/datum/export/solar/control_board
	cost = CARGO_CRATE_VALUE * 0.3
	unit_name = "solar panel control board"
	export_types = list(/obj/item/circuitboard/computer/solar_control)

/datum/export/swarmer
	cost = CARGO_CRATE_VALUE * 4
	unit_name = "deactivated alien deconstruction drone"
	export_types = list(/obj/item/deactivated_swarmer)
