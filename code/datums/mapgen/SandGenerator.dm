/datum/map_generator/island_generator_sand
	/datum/biome/sand

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/island_generator_sand/generate_terrain(list/turfs)
	. = ..()
	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/datum/biome/selected_biome
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK
