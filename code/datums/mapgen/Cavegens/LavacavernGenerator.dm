/datum/map_generator/cave_generator/lavacavern
	//simular to lavaland but less lethal
	open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/Iceland_surface = 1)
	closed_turf_types =  list(/turf/closed/mineral/snowmountain/cavern = 1)
	blacklisted_turf_types = list(/turf/open/lava) // Don't override lava rivers


	feature_spawn_list = list(/obj/structure/geyser/random = 1, /obj/structure/flora/rock = 1, /obj/structure/flora/rock/pile = 2)
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50, /obj/structure/spawner/lavaland/goliath = 3, \
	/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40, /mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,)
	flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2 , /obj/structure/flora/ash/cap_shroom = 2 , /obj/structure/flora/ash/stem_shroom = 2 , /obj/structure/flora/ash/cacti = 1, /obj/structure/flora/ash/tall_shroom = 2, /obj/structure/flora/ash/strange = 1)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3
