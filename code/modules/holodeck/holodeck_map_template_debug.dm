// ---------------------------------------------
//            DEBUG Holodeck Maps
// ---------------------------------------------
/datum/map_template/holodeck/debug

/datum/map_template/holodeck/debug/on_placement_completed(datum/async_map_generator/map_place/map_gen, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, register = TRUE, list/turfs)
	. = ..()
	var/static/warn_once = TRUE
	for(var/turf/each_turf in get_affected_turfs(T))
		each_turf.holodeck_compatible = TRUE
		if(warn_once && !istype(get_area(each_turf), /area/holodeck))
			message_admins("Holodeck template '[name]' does not have /area/template_noop")
			stack_trace("Holodeck template '[name]' does not have /area/template_noop")
			warn_once = FALSE

/datum/map_template/holodeck/debug/empty
	name = "Holodeck - Offline"
	template_id = "debug-offline"
	mappath = "_maps/holodeck/debug/empty.dmm"

/datum/map_template/holodeck/debug/space
	name = "Holodeck - Space"
	template_id = "debug-space"
	mappath = "_maps/holodeck/debug/space.dmm"

// ------------------------------------------------
//         List of real templates below:
// ------------------------------------------------
/datum/map_template/holodeck/debug/rbmk
	name = "Holodeck - Engineering RBMK"
	template_id = "debug-rbmk"
	mappath = "_maps/holodeck/debug/engi-rbmk.dmm"

/datum/map_template/holodeck/debug/n2
	name = "Holodeck - Engineering N2 SM"
	template_id = "debug-engi-n2-sm"
	mappath = "_maps/holodeck/debug/engi-sm-n2.dmm"

/datum/map_template/holodeck/debug/co2
	name = "Holodeck - Engineering CO2 SM"
	template_id = "debug-engi-co2-sm"
	mappath = "_maps/holodeck/debug/engi-sm-co2.dmm"

/datum/map_template/holodeck/debug/tesla
	name = "Holodeck - Engineering Tesla and Singularity"
	template_id = "debug-engi-tesla"
	mappath = "_maps/holodeck/debug/engi-tesla.dmm"

/datum/map_template/holodeck/debug/robotics
	name = "Holodeck - Science Robotics"
	template_id = "debug-sci-rob"
	mappath = "_maps/holodeck/debug/sci-robotics.dmm"

/datum/map_template/holodeck/debug/syndicates
	name = "Holodeck - Syndicates"
	template_id = "debug-syndicates"
	mappath = "_maps/holodeck/debug/syndicates.dmm"
