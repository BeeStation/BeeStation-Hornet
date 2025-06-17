/datum/map_generator/grass_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
		BIOME_LOW_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/grassedge,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/grassedge,  // Replaced /datum/biome/mudlands with /datum/biome/grassclearing
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/grassclearing,  // Replaced /datum/biome/mudlands with /datum/biome/grassclearing
			BIOME_HIGH_HUMIDITY = /datum/biome/grassclearing
		),
		BIOME_LOWMEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/grassedge,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/grasslush,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/grasslush,
			BIOME_HIGH_HUMIDITY = /datum/biome/grassclearing  // Replaced /datum/biome/mudlands with /datum/biome/grassclearing
		),
		BIOME_HIGHMEDIUM_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/grassedge,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/grassclearing,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/grasslush,
			BIOME_HIGH_HUMIDITY = /datum/biome/grasslush
		),
		BIOME_HIGH_HEAT = list(
			BIOME_LOW_HUMIDITY = /datum/biome/grassedge,
			BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/grassclearing,
			BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/grasslush,
			BIOME_HIGH_HUMIDITY = /datum/biome/grasslush
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/grass_generator/generate_terrain(list/turfs, area/generate_in)
	. = ..()
	var/height_seed = rand(0, 50000)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/BIOME_RANDOM_SQUARE_DRIFT = 2
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))


		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.25)
					heat_level = BIOME_LOW_HEAT
				if(0.25 to 0.5)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.5 to 0.75)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.75 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.25)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.25 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.75)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.75 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a clearing
			selected_biome = /datum/biome/grassclearing
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK
