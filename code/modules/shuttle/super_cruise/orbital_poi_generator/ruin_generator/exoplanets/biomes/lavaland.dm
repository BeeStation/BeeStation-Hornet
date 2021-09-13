/datum/exoplanet_biome/lavaland
	name = "lavaland"

	area_type = /area/planet/lavaland

	//Rock face types
	deep_rock_type = /turf/closed/mineral/random/volcanic
	shallow_rock_type = /turf/closed/mineral/random/volcanic

	river_type = /turf/open/lava/smooth/lava_land_surface
	beach_type = /turf/open/floor/plating/lavaland

	plains_type = /turf/open/floor/plating/lavaland
	plains_decoration = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 1, /mob/living/simple_animal/hostile/asteroid/goliath = 5, /mob/living/simple_animal/hostile/asteroid/basilisk = 4, /mob/living/simple_animal/hostile/asteroid/hivelord = 3, /obj/structure/flora/ash/leaf_shroom = 20, /obj/structure/flora/ash/cap_shroom = 20, /obj/structure/flora/ash/stem_shroom = 20 , /obj/structure/flora/ash/cacti = 10, /obj/structure/flora/ash/tall_shroom = 20)

	jungle_type = /turf/open/floor/plating/ashplanet/rocky
	jungle_decoration = list(/obj/structure/geyser/random = 30, null = 60, /mob/living/simple_animal/hostile/megafauna/dragon = 4, /mob/living/simple_animal/hostile/megafauna/colossus = 2, /mob/living/simple_animal/hostile/megafauna/bubblegum = 6)

/area/planet/lavaland
	lighting_overlay_colour = "#cfb793"
