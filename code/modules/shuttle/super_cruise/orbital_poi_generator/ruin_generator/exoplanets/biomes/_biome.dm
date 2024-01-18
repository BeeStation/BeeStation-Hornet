/datum/exoplanet_biome
	var/name

	var/area_type = /area/planet

	//Rock face types
	var/deep_rock_type = /turf/closed/mineral/snowmountain/cavern
	var/shallow_rock_type = /turf/closed/mineral/snowmountain

	var/river_type = /turf/open/floor/plating/ice/smooth
	var/beach_type = /turf/open/floor/plating/asteroid/snow

	var/plains_type = /turf/open/floor/plating/asteroid/snow
	var/list/plains_decoration = list(/obj/structure/flora/tree/pine = 1)

	var/jungle_type = /turf/open/floor/plating/asteroid/snow
	var/list/jungle_decoration = list(/obj/structure/flora/tree/pine = 1)

/area/planet
	icon_state = "Unknown Planet"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LAVALAND
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	outdoors = TRUE
	max_ambience_cooldown = 220 SECONDS
	area_flags = NONE
	lighting_overlay_colour = "#93c3cf"
	lighting_overlay_opacity = 60
	luminosity = 1
