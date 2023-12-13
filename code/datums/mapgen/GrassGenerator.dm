/datum/map_generator/grass_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
		/datum/biome/grassedge,
		/datum/biome/grasslush,
		/datum/biome/grassclearing
	)

	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/jungle_generator/generate_terrain(list/turfs, area/generate_in)
	. = ..()

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/datum/biome/selected_biome = pick(possible_biomes)// Get a random biome from the possible_biomes list
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK
