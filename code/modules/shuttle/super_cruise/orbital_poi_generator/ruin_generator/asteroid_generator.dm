//Generates an asteroid around a point with max radius r
//weight_offset - Affects the probability of a rock spawning (between -1 and 1)
//if this number is negative, asteroids will be smaller.
//if this number is positive asteroids will be larger and more likely
/proc/generate_asteroids(center_x, center_y, center_z, max_radius, weight_offset = 0, scale = 65)
	var/datum/space_level/space_level = SSmapping.get_level(center_z)
	space_level.generating = TRUE
	try
		_generate_asteroids(center_x, center_y, center_z, max_radius, weight_offset, scale)
	catch(var/exception/e)
		message_admins("Asteroid failed to generate!")
		stack_trace("Asteroid failed to generate! [e] on [e.file]:[e.line]")
	space_level.generating = FALSE

/proc/_generate_asteroids(center_x, center_y, center_z, max_radius, weight_offset = 0, scale = 65)
	var/perlin_noise_scale = scale
	var/seed = rand(0, 999999)
	var/turf/z_center = locate(center_x, center_y, center_z)
	for(var/turf/open/space/T in block(locate(1, 1, center_z), locate(world.maxx, world.maxy, center_z)))
		if(!T)
			return
		//Calculate distance to edge
		var/distance = z_center.Distance(T)
		if(distance > max_radius)
			continue
		var/noise_at_coord = text2num(rustg_noise_get_at_coordinates("[seed]", "[T.x / perlin_noise_scale]", "[T.y / perlin_noise_scale]"))
		var/rock_value = (distance / max_radius) + weight_offset + 0.1
		var/sand_value = (distance / max_radius) + weight_offset
		if(noise_at_coord >= rock_value)
			T.ChangeTurf(/turf/closed/mineral/random, list(/turf/open/floor/plating/asteroid/airless), CHANGETURF_IGNORE_AIR)
		else if(noise_at_coord >= sand_value)
			T.ChangeTurf(/turf/open/floor/plating/asteroid/airless, flags = CHANGETURF_IGNORE_AIR)
		CHECK_TICK
