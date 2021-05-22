/datum/orbital_object/shuttle
	name = "Shuttle"
	var/shuttle_port_id
	var/stealth = FALSE

/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	stealth = dock.hidden

/datum/orbital_object/shuttle/proc/commence_docking(list/z_level)
	return
