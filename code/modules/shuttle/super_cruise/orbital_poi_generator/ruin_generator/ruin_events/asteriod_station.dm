/datum/ruin_event/asteriod_station
	probability = 3

/datum/ruin_event/asteriod_station/post_spawn(list/floor_turfs, z_value)
	var/perlin_noise_scale = 65
	var/seed = rand(0, 999999)
	var/turf/z_center = locate(world.maxx * 0.5, world.maxy * 0.5, z_value)
	for(var/turf/open/space/T in block(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value)))
		//Calculate distance to edge
		var/distance = z_center.Distance(T)
		if(distance > 120)
			continue
		var/noise_at_coord = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
		var/rock_value = (distance / 120) + 0.1
		var/sand_value = (distance / 120)
		if(noise_at_coord >= rock_value)
			T.ChangeTurf(/turf/closed/mineral/random, list(/turf/open/floor/plating/asteroid/airless), CHANGETURF_IGNORE_AIR)
		else if(noise_at_coord >= sand_value)
			T.ChangeTurf(/turf/open/floor/plating/asteroid/airless, flags = CHANGETURF_IGNORE_AIR)
		CHECK_TICK
