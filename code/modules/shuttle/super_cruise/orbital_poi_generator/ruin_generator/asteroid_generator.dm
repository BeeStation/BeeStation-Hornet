//Generates an asteroid around a point with max radius r
//weight_offset - Affects the probability of a rock spawning (between -1 and 1)
//if this number is negative, asteroids will be smaller.
//if this number is positive asteroids will be larger and more likely
/proc/generate_asteroids(center_x, center_y, center_z, min_radius, max_radius, weight_offset = 0, scale = 65, biome = list(/turf/closed/mineral/random = 0), ores_list = null)
	var/datum/space_level/space_level = SSmapping.get_level(center_z)
	space_level.generating = TRUE
	. = _generate_asteroids(center_x, center_y, center_z, min_radius, max_radius, weight_offset, scale, biome, ores_list)
	space_level.generating = FALSE

/proc/_generate_asteroids(center_x, center_y, center_z, min_radius, max_radius, weight_offset = 0, scale = 65, biome = list(/turf/closed/mineral/random = 0), ores_list = null)

	SSair.pause_z(center_z)

	var/perlin_noise_scale = scale
	var/seed = rand(0, 999999)
	var/turf/z_center = locate(center_x, center_y, center_z)
	var/list/high_value_turfs = list()
	var/generated_string = rustg_cnoise_generate("45", "20", "4", "3", "[world.maxx]", "[world.maxy]") //Generate the raw CA data

	var/static/area/asteroid_area = new /area/asteroid/generated()

	var/list/output = list(world.maxx, world.maxy, 1, 1)

	for(var/turf/open/space/T in block(locate(max(world.maxx / 2 - max_radius, 1), max(world.maxy / 2 - max_radius, 1), center_z), locate(min(world.maxx / 2 + max_radius, world.maxx), min(world.maxy / 2 + max_radius, world.maxy), center_z)))
		if(!T)
			continue
		//Calculate distance to edge
		var/distance = z_center.Distance(T)
		if(distance > max_radius)
			continue
		// 0 at the center, 1 at the edge
		var/distance_falloff = CLAMP01((distance - min_radius) / (max_radius - min_radius))
		//Change area
		T.change_area(T.loc, asteroid_area)
		//Check if we are closed or not (Cave generation)
		var/closed = text2num(generated_string[world.maxx * (T.y - 1) + T.x])
		var/noise_at_coord = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
		var/plant_value = distance_falloff + (weight_offset + 0.3) * (1 - distance_falloff)
		var/rock_value = distance_falloff + (weight_offset + 0.1) * (1 - distance_falloff)
		var/sand_value = distance_falloff + weight_offset * (1 - distance_falloff)
		if(noise_at_coord >= rock_value && closed)
			// Get some noise for the ores
			var/noise_ore = text2num(rustg_noise_get_at_coordinates("[seed + 1]", "[T.x / (perlin_noise_scale / 3)]", "[T.y / (perlin_noise_scale / 3)]"))
			// Determine the turf to use
			var/turf_ratio = noise_ore
			for (var/i in length(biome) to 1 step -1)
				var/turf = biome[i]
				var/proportion = biome[turf]
				if (turf_ratio > proportion)
					var/spawned_ore = null
					// Try to change to the correct ore type
					if (!isnull(ores_list))
						for (var/j in length(ores_list) to 1 step -1)
							var/ore_type = ores_list[j]
							var/ore_proportion = ores_list[ore_type]
							if (turf_ratio > ore_proportion)
								spawned_ore = ore_type
								break
					if (ispath(spawned_ore, /turf))
						T.ChangeTurf(spawned_ore, list(/turf/open/floor/plating/asteroid/airless), CHANGETURF_IGNORE_AIR)
					else
						T.ChangeTurf(turf, list(/turf/open/floor/plating/asteroid/airless), CHANGETURF_IGNORE_AIR)
						var/turf/closed/mineral/mineral_rock = T
						if (spawned_ore && istype(mineral_rock))
							mineral_rock.Change_Ore(spawned_ore)
					break
			output[1] = min(output[1], T.x)
			output[2] = min(output[2], T.y)
			output[3] = max(output[3], T.x)
			output[4] = max(output[4], T.y)
		else if(noise_at_coord >= sand_value)
			var/turf/newT = T.ChangeTurf(/turf/open/floor/plating/asteroid/airless, flags = CHANGETURF_IGNORE_AIR)
			output[1] = min(output[1], T.x)
			output[2] = min(output[2], T.y)
			output[3] = max(output[3], T.x)
			output[4] = max(output[4], T.y)
			if(noise_at_coord >= plant_value)
				high_value_turfs += newT
				//Cave plants
				if(prob(max(30 - (plant_value * 30), 0)))
					var/plant_type = pick(/obj/structure/flora/rock/pile, /obj/structure/flora/ausbushes/brflowers,
						/obj/structure/flora/ausbushes/fullgrass, /obj/structure/flora/ausbushes/ppflowers,
						/obj/structure/flora/ausbushes/sparsegrass, /obj/structure/flora/ausbushes/ywflowers,
						/obj/structure/flora/bush, /obj/structure/flora/junglebush, /obj/structure/flora/junglebush/b,
						/obj/structure/flora/junglebush/c, /obj/structure/glowshroom/glowcap, /obj/structure/flora/ash/cap_shroom,
						/obj/structure/flora/ash/stem_shroom, /obj/structure/flora/ash/cacti)
					new plant_type(T)
		CHECK_TICK
	//Spawn tendrils and other cave stuff
	for(var/i in 1 to min(length(high_value_turfs), rand(0, 3)))
		var/turf/T = pick_n_take(high_value_turfs)
		if(locate(/obj/structure/spawner/lavaland) in range(3, T))
			continue
		var/type_to_spawn = pick(/obj/structure/spawner/lavaland/hivelord, /obj/structure/spawner/lavaland/gutlunch,
			/obj/structure/spawner/lavaland/asteroid_goliath, /obj/structure/spawner/lavaland/fugu,
			/obj/structure/spawner/lavaland/basilisk, /obj/structure/spawner/lavaland,
			/obj/structure/spawner/lavaland/goliath, /obj/structure/spawner/lavaland/legion)
		new type_to_spawn(T)

	SSair.unpause_z(center_z)

	return output

//Spawner types
/obj/structure/spawner/lavaland/basilisk
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk)

/obj/structure/spawner/lavaland/fugu
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/fugu)

/obj/structure/spawner/lavaland/asteroid_goliath
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath)

/obj/structure/spawner/lavaland/gutlunch
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/gutlunch)

/obj/structure/spawner/lavaland/hivelord
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)

/area/asteroid/generated
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	outdoors = TRUE
