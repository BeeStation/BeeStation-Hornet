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

/datum/map_template/holodeck/debug/engi
	name = "---Engineering---"

/datum/map_template/holodeck/debug/engi/fusion
	name = "Holodeck - Engineering Fusion"
	template_id = "debug-engi-fusion"
	mappath = "_maps/holodeck/debug/engi-fusion.dmm"

/datum/map_template/holodeck/debug/engi/rbmk
	name = "Holodeck - Engineering RBMK"
	template_id = "debug-rbmk"
	mappath = "_maps/holodeck/debug/engi-rbmk.dmm"

/datum/map_template/holodeck/debug/engi/sm/n2
	name = "Holodeck - Engineering N2 SM"
	template_id = "debug-engi-n2-sm"
	mappath = "_maps/holodeck/debug/engi-sm-n2.dmm"

/datum/map_template/holodeck/debug/engi/sm/co2
	name = "Holodeck - Engineering CO2 SM"
	template_id = "debug-engi-co2-sm"
	mappath = "_maps/holodeck/debug/engi-sm-co2.dmm"

/datum/map_template/holodeck/debug/engi/tesla
	name = "Holodeck - Engineering Tesla and Singularity"
	template_id = "debug-engi-tesla"
	mappath = "_maps/holodeck/debug/engi-tesla.dmm"

/datum/map_template/holodeck/debug/engi/turbine
	name = "Holodeck - Engineering Turbine"
	template_id = "debug-turbine"
	mappath = "_maps/holodeck/debug/engi-turbine.dmm"

/datum/map_template/holodeck/debug/engi/teg
	name = "Holodeck - Engineering TEG"
	template_id = "debug-engi-teg"
	mappath = "_maps/holodeck/debug/engi-teg.dmm"

/datum/map_template/holodeck/debug/holodeck
	name = "Holodeck - Holodeck"
	template_id = "debug-holodeck"
	mappath = "_maps/holodeck/debug/holodeck.dmm"

/datum/map_template/holodeck/debug/med
	name = "Holodeck - Medical"
	template_id = "debug-med"
	mappath = "_maps/holodeck/debug/med.dmm"

/datum/map_template/holodeck/debug/sci
	name = "---Science---"

/datum/map_template/holodeck/debug/sci/robotics
	name = "Holodeck - Science Robotics"
	template_id = "debug-sci-rob"
	mappath = "_maps/holodeck/debug/sci-robotics.dmm"

/datum/map_template/holodeck/debug/sci/xenobio
	name = "Holodeck - Science Xenobiology"
	template_id = "debug-sci-xenobio"
	mappath = "_maps/holodeck/debug/sci-xenobio.dmm"

/datum/map_template/holodeck/debug/sci/xenoarch
	name = "Holodeck - Science Xenoarchology"
	template_id = "debug-sci-xenoarch"
	mappath = "_maps/holodeck/debug/sci-xenoarch.dmm"

/datum/map_template/holodeck/debug/serv/botany
	name = "---Service---"

/datum/map_template/holodeck/debug/serv/botany
	name = "Holodeck - Service Botany"
	template_id = "debug-serv-botany"
	mappath = "_maps/holodeck/debug/serv-botany.dmm"

/datum/map_template/holodeck/debug/serv/kitchen
	name = "Holodeck - Service Kitchen"
	template_id = "debug-serv-kitchen"
	mappath = "_maps/holodeck/debug/serv-kitchen.dmm"

/datum/map_template/holodeck/debug/syndicates
	name = "Holodeck - Syndicates"
	template_id = "debug-syndicates"
	mappath = "_maps/holodeck/debug/syndicates.dmm"
