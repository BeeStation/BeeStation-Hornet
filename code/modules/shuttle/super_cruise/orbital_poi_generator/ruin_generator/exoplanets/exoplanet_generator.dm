/proc/generate_exoplanet(center_z)
	var/datum/space_level/space_level = SSmapping.get_level(center_z)
	space_level.generating = TRUE
	_generate_exoplanet(center_z, new /datum/exoplanet_biome/lavaland)
	space_level.generating = FALSE

/proc/_generate_exoplanet(center_z, datum/exoplanet_biome/biome)

	SSair.pause_z(center_z)

	var/perlin_noise_scale = 65
	var/river_height = 0.25
	var/beach_height = 0.32
	var/mountain_height = 0.7
	var/deepmountain_height = 0.8
	var/seed = rand(0, 999999)
	var/area/new_area = new biome.area_type
	new_area.setup("Alien Planet")
	for(var/turf/T as() in block(locate(1, 1, center_z), locate(world.maxx, world.maxy, center_z)))
		var/area/old_area = T.loc
		if(istype(old_area, /area/space) && new_area)
			T.change_area(old_area, new_area)

		if(isspaceturf(T))
			var/area_height = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
			if(area_height > deepmountain_height)
				T.ChangeTurf(biome.deep_rock_type, list(biome.plains_type, biome.river_type), CHANGETURF_IGNORE_AIR)
			else if(area_height > mountain_height)
				T.ChangeTurf(biome.shallow_rock_type, list(biome.plains_type, biome.river_type), CHANGETURF_IGNORE_AIR)
			//Normal biome
			else if(area_height > beach_height)
				var/biome_noise = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
				if(biome_noise > 0.5)
					T.ChangeTurf(biome.plains_type, list(biome.river_type), CHANGETURF_IGNORE_AIR)
					if(prob(20) && length(biome.plains_decoration))
						var/type_to_spawn = pick_weight(biome.plains_decoration)
						if(ispath(type_to_spawn))
							new type_to_spawn(T)
				else
					T.ChangeTurf(biome.jungle_type, list(biome.river_type), CHANGETURF_IGNORE_AIR)
					if(prob(60) && length(biome.plains_decoration))
						var/type_to_spawn = pick_weight(biome.jungle_decoration)
						if(ispath(type_to_spawn))
							new type_to_spawn(T)
			//beach
			else if(area_height > river_height)
				T.ChangeTurf(biome.beach_type, list(biome.river_type), CHANGETURF_IGNORE_AIR)
			//Wa'er
			else
				T.ChangeTurf(biome.river_type, list(biome.river_type), CHANGETURF_IGNORE_AIR)
		else
			T.baseturfs = list(biome.plains_type, biome.river_type)
		CHECK_TICK
	new_area.update_areasize()

	SSair.unpause_z(center_z)
