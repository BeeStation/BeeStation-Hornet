/datum/exoplanet_biome
	var/name

	//Rock face types
	var/deep_rock_type = /turf/closed/mineral/snowmountain/cavern
	var/shallow_rock_type = /turf/closed/mineral/snowmountain

	var/river_type = /turf/open/floor/plating/asteroid/snow/ice_normal
	var/beach_type = /turf/open/floor/plating/asteroid/snow

	var/plains_type = /turf/open/floor/plating/asteroid/snow
	var/list/plains_decoration = list()

	var/jungle_type = /turf/open/floor/plating/asteroid/snow
	var/list/jungle_decoration = list()

/turf/open/floor/plating/asteroid/snow/ice_normal
	name = "icy snow"
	desc = "Looks colder."
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	floor_variance = 0
	icon_state = "snow-ice"
	icon_plating = "snow-ice"
	environment_type = "snow_cavern"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
