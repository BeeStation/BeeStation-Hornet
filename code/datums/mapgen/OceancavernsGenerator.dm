/datum/map_generator/cave_generator/ocean
	open_turf_types = list(/turf/open/floor/plating/ocean/abyss = 1)
	closed_turf_types =  list(/turf/closed/mineral/random/ocean_wall = 1)
	blacklisted_turf_types = list(/turf/open/lava) // Don't override lava rivers


	flora_spawn_list = list(/obj/structure/flora/ocean/coral = 3, /obj/structure/flora/ocean/seaweed = 2, /obj/structure/flora/ocean/longseaweed = 2, /obj/structure/flora/ocean/glowweed = 1)
	mob_spawn_list = list(/mob/living/simple_animal/hostile/carp = 1, /mob/living/simple_animal/hostile/carp/megacarp = 0.1)

	initial_closed_chance = 45
	smoothing_iterations = 50
	birth_limit = 4
	death_limit = 3
	mob_spawn_chance = 0.3
	flora_spawn_chance = 5
