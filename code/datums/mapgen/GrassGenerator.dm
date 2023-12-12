//the random offset applied to square coordinates, causes intermingling at biome borders
#define GRASS_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/island_generator_grass
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = rand(/datum/biome/grassedge, /datum/biome/grasslush, /datum/biome/grassclearing)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 30

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/island_generator_grass/generate_terrain(list/turfs)
	. = ..()
	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/datum/biome/selected_biome
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK

#undef GRASS_RANDOM_SQUARE_DRIFT
