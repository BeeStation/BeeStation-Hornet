// ---------------------------------------------
//            DEBUG Holodeck Maps
// ---------------------------------------------
/datum/map_template/holodeck/debug

// I don't get why but unit test dislikes this failsafe.
#ifndef UNIT_TESTS
/datum/map_template/holodeck/debug/on_placement_completed(datum/async_map_generator/map_place/map_gen, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, register = TRUE, list/turfs)
	. = ..()
	var/static/warn_once = TRUE
	for(var/turf/each_turf in get_affected_turfs(T))
		each_turf.holodeck_compatible = TRUE
		if(warn_once && !istype(get_area(each_turf), /area/holodeck))
			message_admins("Holodeck template '[name]' does not have /area/template_noop")
			stack_trace("Holodeck template '[name]' does not have /area/template_noop")
			warn_once = FALSE
#endif

/datum/map_template/holodeck/debug/empty
	name = "Holodeck - Offline"
	template_id = "debug-offline"
	mappath = "_maps/holodeck/debug/empty.dmm"

/datum/map_template/holodeck/debug/chasm
	name = "Holodeck - Chasm (WARN: Flushes everything)"
	template_id = "debug-chasm"
	mappath = "_maps/holodeck/debug/chasm.dmm"

// ------------------------------------------------
//         List of real templates below:
// ------------------------------------------------
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

/datum/map_template/holodeck/debug/guns
	name = "Holodeck - Guns"
	template_id = "debug-guns"
	mappath = "_maps/holodeck/debug/guns.dmm"
