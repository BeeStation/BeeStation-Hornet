/datum/map_generator/cave_generator/iceland
	weighted_open_turf_types = list(/turf/open/floor/plating/asteroid/snow = 15, /turf/open/floor/plating/ice/smooth = 2)
	weighted_closed_turf_types =  list(/turf/closed/mineral/random/snowmountain/cavern = 1)
	blacklisted_turf_types = list(/turf/open/lava) // Don't override lava rivers


	weighted_feature_spawn_list = list(/obj/structure/flora/rock/icy = 1, /obj/structure/flora/rock/pile/icy = 3)
	weighted_flora_spawn_list = list(/obj/structure/flora/grass/green = 2, /obj/structure/flora/grass/brown = 2,  /obj/structure/flora/grass/both = 1)
	weighted_mob_spawn_list = list(/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice = 2, /mob/living/simple_animal/hostile/poison/giant_spider/ice = 1)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3
	mob_spawn_chance = 0.5
