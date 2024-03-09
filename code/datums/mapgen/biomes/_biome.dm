///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	///Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	///Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	///list of type paths of objects that can be spawned when the turf spawns flora
	var/list/flora_types = list(/obj/structure/flora/grass/jungle)
	///list of type paths of mobs that can be spawned when the turf spawns fauna
	var/list/fauna_types = list()
	///X and Y maximum pixel offsets posative and negative of flora
	var/flora_x_offset = 0
	var/flora_y_offset = 0

///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(var/turf/gen_turf)
	gen_turf.ChangeTurf(turf_type, null, CHANGETURF_DEFER_CHANGE)
	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pick(fauna_types)
		new fauna(gen_turf)

	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		flora = new flora(gen_turf)
		flora.pixel_x += rand(-flora_x_offset, flora_x_offset)
		flora.pixel_y += rand(-flora_y_offset, flora_y_offset)

//jungle
/datum/biome/mudlands
	turf_type = /turf/open/floor/plating/dirt/jungle/dark
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/rock/jungle, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 3

/datum/biome/plains
	turf_type = /turf/open/floor/grass/jungle
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/tree/jungle, /obj/structure/flora/rock/jungle, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b, /obj/structure/flora/junglebush/c, /obj/structure/flora/junglebush/large, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 15

/datum/biome/jungle
	turf_type = /turf/open/floor/grass/jungle
	flora_types = list(/obj/structure/flora/grass/jungle,/obj/structure/flora/grass/jungle/b, /obj/structure/flora/tree/jungle, /obj/structure/flora/rock/jungle, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b, /obj/structure/flora/junglebush/c, /obj/structure/flora/junglebush/large, /obj/structure/flora/rock/pile/largejungle)
	flora_density = 40

/datum/biome/jungle/deep
	flora_density = 65

/datum/biome/wasteland
	turf_type = /turf/open/floor/plating/dirt/jungle/wasteland

/datum/biome/water
	turf_type = /turf/open/water/air

/datum/biome/mountain
	turf_type = /turf/closed/mineral/random/jungle

//tundra
/datum/biome/frostwastes
	turf_type = /turf/open/floor/plating/asteroid/snow
	flora_types = list(/obj/structure/flora/rock/pile/icy, /obj/structure/flora/rock/icy,  /obj/structure/flora/grass/brown)
	flora_density = 5

/datum/biome/frostplains
	turf_type = /turf/open/floor/plating/asteroid/snow
	flora_types = list(/obj/structure/flora/grass/green, /obj/structure/flora/grass/brown,  /obj/structure/flora/grass/both)
	flora_density = 15

/datum/biome/frostlake
	turf_type = /turf/open/floor/plating/ice/smooth


/datum/biome/frostforest
	turf_type = /turf/open/floor/plating/asteroid/snow
	flora_types = list(/obj/structure/flora/grass/green, /obj/structure/flora/grass/brown,  /obj/structure/flora/bush, /obj/structure/flora/grass/both,  /obj/structure/flora/tree/dead,  /obj/structure/flora/tree/pine)
	flora_density = 30

/datum/biome/frostforest/deep
	flora_density = 60

/datum/biome/frostswamp //screw logic
	turf_type = /turf/open/floor/plating/ice/smooth
	flora_types = list(/obj/structure/flora/tree/dead,  /obj/structure/flora/tree/pine)
	flora_density = 20

/datum/biome/frostmountain
	turf_type = /turf/closed/mineral/snowmountain/cavern

//island

/datum/biome/grassedge
//	turf_type = /turf/open/floor/plating/dirt/grass
	flora_density = 90
	flora_x_offset = 8
	flora_y_offset = 8
	flora_types = list(
		/obj/structure/flora/tree/palm,
		/obj/structure/flora/ausbushes/fullgrass,
		/obj/structure/flora/ausbushes/sparsegrass,
		/obj/structure/flora/ausbushes/lavendergrass,
		/obj/structure/flora/ausbushes/ywflowers,
		/obj/structure/flora/rock/jungle,
		/obj/structure/flora/rock/pile
	)

/datum/biome/grasslush
//	turf_type = /turf/open/floor/plating/dirt/planetary
	flora_density = 120
	fauna_density = 5
	flora_x_offset = 8
	flora_y_offset = 8
	flora_types = list(
		/obj/structure/flora/tree/jungle/small,
		/obj/structure/flora/tree/jungle,
		/obj/structure/flora/junglebush/large,
		/obj/structure/flora/grass/jungle/b,
		/obj/structure/flora/ausbushes/fernybush,
		/obj/structure/flora/ausbushes/palebush,
		/obj/structure/flora/grass/jungle,
		/obj/structure/flora/junglebush,
		/obj/structure/flora/ausbushes/brflowers,
		/obj/structure/flora/ausbushes/grassybush,
		/obj/structure/flora/junglebush/b,
		/obj/structure/flora/junglebush/c,
		/obj/structure/flora/ausbushes/ppflowers,
		/obj/structure/flora/rock,
		/obj/structure/flora/rock/jungle,
		/obj/structure/flora/rock/pile,
		/obj/structure/flora/rock/pile/largejungle
	)
	fauna_types = list(
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/hostile/lizard,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/sloth,
		/mob/living/carbon/monkey
	)

/datum/biome/grassclearing
//	turf_type = /turf/open/floor/plating/dirt/grass
	flora_density = 80
	flora_x_offset = 8
	flora_y_offset = 8
	flora_types = list(
		/obj/structure/flora/grass/jungle/b,
		/obj/structure/flora/ausbushes/fernybush,
		/obj/structure/flora/ausbushes/palebush,
		/obj/structure/flora/grass/jungle,
		/obj/structure/flora/ausbushes/brflowers,
		/obj/structure/flora/ausbushes/ppflowers,
		/obj/structure/flora/rock,
		/obj/structure/flora/rock/jungle,
		/obj/structure/flora/rock/pile,
		/obj/structure/flora/rock/pile/largejungle
	)


/datum/biome/sand
//	turf_type = /turf/open/floor/plating/beach/sand
	flora_density = 30
	fauna_density = 3
	flora_x_offset = 8
	flora_y_offset = 8
	flora_types = list(
		/obj/structure/flora/tree/palm,
		/obj/structure/flora/ausbushes/fullgrass,
		/obj/structure/flora/ausbushes/sparsegrass,
		/obj/structure/flora/ausbushes/lavendergrass,
		/obj/structure/flora/ausbushes/ywflowers,
		/obj/effect/overlay/coconut,
		/obj/structure/flora/rock/pile
	)
	fauna_types = list(
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/hostile/lizard,
	)
