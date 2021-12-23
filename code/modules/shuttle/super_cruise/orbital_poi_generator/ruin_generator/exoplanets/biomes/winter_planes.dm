/datum/exoplanet_biome/winter_planes
	name = "winter planes"

	area_type = /area/planet/winter_planes

	//Rock face types
	deep_rock_type = /turf/open/lava/plasma/ice_atmos
	shallow_rock_type = /turf/closed/mineral/snowmountain/cavern

	river_type = /turf/open/floor/plating/ice/smooth
	beach_type = /turf/open/floor/plating/asteroid/snow

	plains_type = /turf/open/floor/plating/asteroid/snow
	plains_decoration = list(\
		null = 150,\
		/obj/structure/flora/grass/both = 150,\
		/obj/structure/flora/stump = 150,\
		/obj/structure/flora/tree/pine = 130,\
		/obj/structure/flora/bush = 90,\
		/obj/structure/flora/tree/dead = 50,
		/mob/living/simple_animal/hostile/bear/snow = 2,\
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1,\
		/mob/living/simple_animal/hostile/asteroid/basilisk = 2,\
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing = 5,\
		/mob/living/simple_animal/hostile/asteroid/hivelord = 3,\
		/mob/living/simple_animal/hostile/asteroid/fugu = 1,\
	)

	jungle_type = /turf/open/floor/plating/asteroid/snow/ice/frozen_atmos
	jungle_decoration = list(\
		/obj/structure/geyser/random = 5,\
		null = 400,\
		/obj/structure/flora/rock/pile/icy = 20,\
		/obj/structure/flora/rock/icy = 15\
	)

/area/planet/winter_planes
	name = "Trundra Planes"
	lighting_overlay_colour = "#b6e7f3"
	lighting_overlay_opacity = 50
