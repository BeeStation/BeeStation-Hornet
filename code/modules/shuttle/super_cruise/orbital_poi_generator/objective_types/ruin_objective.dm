/datum/orbital_objective/ruin
	var/datum/orbital_object/z_linked/beacon/ruin/linked_beacon

/datum/orbital_objective/ruin/on_assign(obj/machinery/computer/objective/objective_computer)
	. = ..()
	generate_attached_beacon()

/datum/orbital_objective/proc/generate_objective_stuff(turf/chosen_turf)
	return

/datum/orbital_objective/ruin/generate_attached_beacon()
	linked_beacon = new
	linked_beacon.name = "(OBJECTIVE) [linked_beacon.name]"
	linked_beacon.linked_objective = src
