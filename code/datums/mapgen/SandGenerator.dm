/datum/map_generator/sand_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
		/datum/biome/sand
	)

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/sand_generator/generate_terrain(list/turfs, area/generate_in)
	. = ..()

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		// Get the only biome option
		var/datum/biome/selected_biome = possible_biomes[1]
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK
